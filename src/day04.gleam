import gleam/function
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// String, width Int, height Int
pub type Crossword {
  Crossword(String, Int, Int)
}

type Line =
  List(Coord)

type FourByFour {
  FourByFour(Crossword, Int, Int)
}

type ThreeByThree {
  ThreeByThree(Crossword, Int, Int)
}

fn new_4x4(crossword, x, y) -> Result(FourByFour, Error) {
  case crossword {
    Crossword(_, width, height)
      if x < 0 || y < 0 || x >= width - 3 || y >= height - 3
    -> Error(OOB)
    _ -> Ok(FourByFour(crossword, x, y))
  }
}

fn new_3x3(crossword, x, y) -> Result(ThreeByThree, Error) {
  case crossword {
    Crossword(_, width, height)
      if x < 0 || y < 0 || x >= width - 2 || y >= height - 2
    -> Error(OOB)
    _ -> Ok(ThreeByThree(crossword, x, y))
  }
}

type Coord {
  Coord(Int, Int)
}

type Error {
  OOB
}

fn relative_to_absolute(relative_point, x, y) {
  let Coord(a, b) = relative_point
  Coord(a + x, b + y)
}

fn get_lines_3x3(table: ThreeByThree) -> List(Line) {
  let ThreeByThree(_, x_offset, y_offset) = table
  let diag_down = [Coord(0, 0), Coord(1, 1), Coord(2, 2)]
  let diag_up = [Coord(2, 0), Coord(1, 1), Coord(0, 2)]
  [diag_down, diag_up]
  |> list.map(list.map(_, relative_to_absolute(_, x_offset, y_offset)))
}

fn get_lines_4x4(table: FourByFour) -> List(Line) {
  let FourByFour(_, x_offset, y_offset) = table
  let rows =
    list.range(0, 3)
    |> list.map(fn(y) {
      list.range(0, 3)
      |> list.map(Coord(_, y))
    })

  let cols =
    list.range(0, 3)
    |> list.map(fn(x) {
      list.range(0, 3)
      |> list.map(Coord(x, _))
    })
  let diag_down = [Coord(0, 0), Coord(1, 1), Coord(2, 2), Coord(3, 3)]
  let diag_up = [Coord(3, 0), Coord(2, 1), Coord(1, 2), Coord(0, 3)]

  [diag_down, diag_up, ..list.append(rows, cols)]
  |> list.map(list.map(_, relative_to_absolute(_, x_offset, y_offset)))
}

fn line_to_string(crossword, line) -> String {
  let indices = list.map(line, convert_coord_to_index(crossword, _))
  let Crossword(raw, _, _) = crossword
  list.map(indices, string.slice(raw, _, 1))
  |> string.join("")
}

fn xmas_p(fbf, line: Line) -> Bool {
  let FourByFour(crossword, _, _) = fbf
  line
  |> line_to_string(crossword, _)
  |> fn(x) { x == "XMAS" || x == "SAMX" }
}

fn x_mas_p(tbt) -> Bool {
  let ThreeByThree(crossword, _, _) = tbt
  case get_lines_3x3(tbt) |> list.map(line_to_string(crossword, _)) {
    [up, down]
      if { up == "MAS" || up == "SAM" } && { down == "MAS" || down == "SAM" }
    -> True
    _ -> False
  }
}

fn get_xmas_lines(input: FourByFour) -> List(Line) {
  get_lines_4x4(input)
  |> list.filter(xmas_p(input, _))
}

fn index_4x4_p(crossword, coord) {
  let Crossword(_, width, height) = crossword
  case coord {
    Coord(x, y) if x < 0 || x >= width - 3 || y < 0 || y >= height - 3 -> False
    _ -> True
  }
}

fn index_3x3_p(crossword, coord) {
  let Crossword(_, width, height) = crossword
  case coord {
    Coord(x, y) if x < 0 || x >= width - 2 || y < 0 || y >= height - 2 -> False
    _ -> True
  }
}

fn index_for_4x4_p(crossword, index) {
  convert_index_to_coord(crossword, index)
  |> index_4x4_p(crossword, _)
}

fn index_for_3x3_p(crossword, index) {
  convert_index_to_coord(crossword, index)
  |> index_3x3_p(crossword, _)
}

fn crossword_to_4x4(
  crossword: Crossword,
  index: Int,
) -> Result(FourByFour, Error) {
  let coord = convert_index_to_coord(crossword, index)
  let Coord(x, y) = coord
  case index_4x4_p(crossword, coord) {
    False -> Error(OOB)
    True -> new_4x4(crossword, x, y)
  }
}

fn crossword_to_3x3(
  crossword: Crossword,
  index: Int,
) -> Result(ThreeByThree, Error) {
  let coord = convert_index_to_coord(crossword, index)
  let Coord(x, y) = coord
  case index_3x3_p(crossword, coord) {
    False -> Error(OOB)
    True -> new_3x3(crossword, x, y)
  }
}

fn convert_index_to_coord(crossword, idx: Int) -> Coord {
  let Crossword(_, width, _) = crossword
  let x = idx % width
  let y = idx / width
  Coord(x, y)
}

fn convert_coord_to_index(crossword: Crossword, coord: Coord) -> Int {
  let Coord(x, y) = coord
  let Crossword(_, width, _) = crossword
  x + y * width
}

fn parse_input(input) {
  let lines =
    string.split(input, "\n")
    |> list.filter(fn(x) { !string.is_empty(x) })
  case lines {
    [] -> None
    [head, ..] ->
      Some(Crossword(
        string.join(lines, ""),
        string.length(head),
        list.length(lines),
      ))
  }
}

fn part1_process(crossword) {
  let Crossword(_, width, height) = crossword
  list.range(0, width * { height - 4 } + { width - 4 })
  |> list.filter(index_for_4x4_p(crossword, _))
  |> list.map(fn(x) {
    crossword_to_4x4(crossword, x)
    |> result.map(get_xmas_lines)
    |> result.unwrap([])
  })
  |> list.reduce(list.append)
  |> result.unwrap([])
  |> list.unique()
  |> list.length()
}

fn part2_process(crossword) {
  let Crossword(_, width, height) = crossword
  list.range(0, width * { height - 3 } + { width - 3 })
  |> list.filter(index_for_3x3_p(crossword, _))
  |> list.map(fn(x) {
    crossword_to_3x3(crossword, x)
    |> result.map(x_mas_p)
    |> result.unwrap(False)
  })
  |> list.filter(function.identity)
  |> list.length()
}

pub fn part1(input) {
  let crossword =
    input
    |> parse_input

  crossword
  |> option.map(part1_process)
}

pub fn part2(input) {
  let crossword =
    input
    |> parse_input

  crossword
  |> option.map(part2_process)
}
