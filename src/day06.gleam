import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/task
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

/// The maximum number of times to iterate states
const maximum_iterations: Int = 10_000

/// Timeout for parallel processes
const maximum_wait: Int = 1000

/// For parallel processing, the size of each chunk
const default_chunk_size: Int = 200

type Coord {
  Coord(x: Int, y: Int)
}

type PathHistory {
  PathHistory(Set(Coord))
}

type Map {
  Map(obstacles: Set(Coord), width: Int, length: Int)
}

type Dir {
  N
  S
  E
  W
}

type GuardState {
  GuardState(pos: Coord, dir: Dir)
}

type State {
  State(map: Map, current: GuardState, history: PathHistory)
}

pub type Error {
  ExceedMaxIterations(Int)
  DirParseError
  LineParseError(String)
  MultipleGuards
  EmptyInput(Nil)
  MissingGuard
  TimeOut(Int)
  NoResultsFromParallelProcessing
}

// parsing 

fn string_to_dir(s: String) -> Result(Dir, Error) {
  case s {
    "^" -> Ok(N)
    ">" -> Ok(E)
    "v" -> Ok(S)
    "<" -> Ok(W)
    _ -> Error(DirParseError)
  }
}

fn parse_line(
  line: String,
  y: Int,
) -> Result(#(Set(Coord), Option(GuardState)), Error) {
  let chars = string.to_graphemes(line)
  use acc, char, x_index <- list.index_fold(chars, Ok(#(set.new(), None)))
  case char {
    "^" | ">" | "v" | "<" -> {
      use res <- result.try(acc)
      let #(obs, guard) = res
      use <- bool.guard(option.is_some(guard), Error(MultipleGuards))
      use g <- result.map(string_to_dir(char))
      #(obs, Some(GuardState(Coord(x_index, y), g)))
    }
    "#" -> {
      use res <- result.map(acc)
      use a <- pair.map_first(res)
      set.insert(a, Coord(x_index, y))
    }
    "." -> acc
    str -> Error(LineParseError(str))
  }
}

fn parse_input(input: String) -> Result(State, Error) {
  let lines =
    input |> string.split("\n") |> list.filter(fn(x) { !string.is_empty(x) })
  use head <- result.try(
    list.first(lines)
    |> result.map_error(EmptyInput),
  )
  let width = string.length(head)
  let height = list.length(lines)
  let res =
    list.index_fold(lines, Ok(#(set.new(), None)), fn(acc, line, line_index) {
      use acc_unwrapped <- result.try(acc)
      let #(acc_obs, g) = acc_unwrapped
      case parse_line(line, line_index), g {
        Error(x), _ -> Error(x)
        Ok(#(_, Some(_))), Some(_) -> Error(MultipleGuards)
        Ok(#(obstacles, None)), None ->
          Ok(#(set.union(obstacles, acc_obs), None))
        Ok(#(obstacles, _)), Some(guard) | Ok(#(obstacles, Some(guard))), _ ->
          Ok(#(set.union(obstacles, acc_obs), Some(guard)))
      }
    })
  use x <- result.try(res)
  case x {
    #(_, None) -> Error(MissingGuard)
    #(obs, Some(g)) -> Ok(new(Map(obs, width, height), g))
  }
}

// business logic 

/// rotates the guard 90 degrees clockwise
fn guard_turn(guard: GuardState) -> GuardState {
  let GuardState(pos, dir) = guard
  case dir {
    N -> E
    E -> S
    S -> W
    W -> N
  }
  |> GuardState(pos, _)
}

fn forward_coord(guard: GuardState) -> Coord {
  let GuardState(Coord(x, y), dir) = guard
  let x_adjust = case dir {
    N | S -> 0
    E -> 1
    W -> -1
  }
  let y_adjust = case dir {
    E | W -> 0
    S -> 1
    N -> -1
  }
  Coord(x + x_adjust, y + y_adjust)
}

fn guard_next_step(state: State) -> State {
  let State(Map(map, _, _), current, PathHistory(history)) = state
  let peek = forward_coord(current)
  case set.contains(map, peek) {
    True -> guard_next_step(State(..state, current: guard_turn(current)))
    False ->
      State(
        ..state,
        current: GuardState(..current, pos: peek),
        history: PathHistory(set.insert(history, peek)),
      )
  }
}

fn terminal_state_p(state: State) -> Bool {
  let State(Map(_, width, height), GuardState(Coord(x, y), _), _) = state
  x < 0 || x >= width || y < 0 || y >= height
}

fn new(obstacles: Map, guard: GuardState) -> State {
  let GuardState(pos, _) = guard
  State(
    map: obstacles,
    current: guard,
    history: set.new() |> set.insert(pos) |> PathHistory,
  )
}

fn distinct_positions(state: State) -> Int {
  let State(_, _, PathHistory(s)) = state
  set.size(s) - 1
  // one less because it includes the spot stepped out
}

fn simulate_guard_helper(state: State, max: Int, i: Int) -> State {
  case i >= max || terminal_state_p(state) {
    True -> state
    False -> simulate_guard_helper(guard_next_step(state), max, i + 1)
  }
}

fn simulate_guard(state: State, max: Int) -> Result(State, Error) {
  let result = simulate_guard_helper(state, max, 1)
  use <- bool.guard(!terminal_state_p(result), Error(ExceedMaxIterations(max)))
  Ok(result)
}

pub fn part1(input: String) -> Result(Int, Error) {
  use parsed <- result.try(parse_input(input))
  use result <- result.try(simulate_guard(parsed, maximum_iterations))
  Ok(distinct_positions(result))
}

fn add_obstacle(state: State, coord: Coord) -> State {
  let State(map, _, _) = state
  let Map(obs, _, _) = map
  State(..state, map: Map(..map, obstacles: set.insert(obs, coord)))
}

fn simulate_with_new_obstacle(state: State, coord: Coord) -> Int {
  let new_state = add_obstacle(state, coord)
  case simulate_guard(new_state, maximum_iterations) {
    Error(_) -> 1
    _ -> 0
  }
}

fn get_coord_list(final_state: State) -> List(Coord) {
  let State(Map(_, width, height), _, PathHistory(coords)) = final_state
  coords
  |> set.to_list
  |> list.filter(fn(coord) {
    let Coord(x, y) = coord
    x >= 0 && x < width && y >= 0 && y < height
  })
}

fn part2_parallel(state, coord_list, chunk_size) -> Result(Int, Error) {
  let handles =
    list.map(list.sized_chunk(coord_list, chunk_size), fn(chunk) {
      task.async(fn() {
        chunk
        |> list.fold(0, fn(acc, new_obs) {
          acc + simulate_with_new_obstacle(state, new_obs)
        })
      })
    })

  use values <- result.map(
    task.try_await_all(handles, maximum_wait)
    |> result.all()
    |> result.map_error(fn(_) { TimeOut(maximum_wait) }),
  )
  list.fold(values, 0, int.add)
}

pub fn part2(input: String) -> Result(Int, Error) {
  use parsed <- result.try(parse_input(input))
  use end_state <- result.try(simulate_guard(parsed, maximum_iterations))
  get_coord_list(end_state)
  |> part2_parallel(parsed, _, default_chunk_size)
}
