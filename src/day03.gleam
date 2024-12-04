import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/regexp.{Match}

pub type Instruction {
  Mul(Int, Int)
  Do
  Dont
}

pub type Input =
  List(Instruction)

// Parser

fn parse_input(input: String, regex: String) -> Input {
  let assert Ok(re) = regexp.from_string(regex)
  regexp.scan(re, input)
  |> list.map(extract_instructions)
  |> option.values()
}

const part1_regexp = "mul[(]([0-9]+),([0-9]+)[)]"

const part2_regexp = "(don[']t[(][)])|(do[(][)])|(mul[(]([0-9]+),([0-9]+)[)])"

fn extract_instructions(result) {
  case result {
    Match("don't()", _) -> Some(Dont)
    Match("do()", _) -> Some(Do)
    Match(_, [_, _, _, Some(num1), Some(num2)])
    | Match(_, [Some(num1), Some(num2)]) -> parse_ints(num1, num2)
    _ -> None
  }
}

fn parse_ints(a: String, b: String) -> Option(Instruction) {
  case int.parse(a), int.parse(b) {
    Ok(x), Ok(y) -> Some(Mul(x, y))
    _, _ -> None
  }
}

// Business Logic

pub fn part1(input: String) -> Int {
  input
  |> parse_input(part1_regexp)
  |> list.map(run_instruction)
  |> list.fold(0, int.add)
}

fn run_instruction(inst: Instruction) -> Int {
  case inst {
    Mul(x, y) -> x * y
    _ -> 0
  }
}

pub fn part2(input: String) -> Int {
  input
  |> parse_input(part2_regexp)
  |> list.fold(#(DoState, 0), iterate)
  |> pair.second
}

type State {
  DoState
  DontState
}

fn iterate(state: #(State, Int), instruction: Instruction) {
  let #(curr, total) = state
  case instruction, curr {
    Do, _ -> #(DoState, total)
    Dont, _ -> #(DontState, total)
    Mul(x, y), DoState -> #(DoState, total + x * y)
    _, _ -> #(curr, total)
  }
}
