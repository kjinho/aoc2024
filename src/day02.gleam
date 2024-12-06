import gleam/function
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import nibble
import nibble/lexer

type Level =
  Int

type Report =
  List(Level)

type Input =
  List(Report)

// parser 

type Token {
  Num(Int)
  Newline
}

fn lexer() -> lexer.Lexer(Token, Nil) {
  lexer.simple([
    lexer.int(Num),
    lexer.token("\n", Newline),
    lexer.spaces(Nil) |> lexer.ignore,
  ])
}

fn level_parser() -> nibble.Parser(Level, Token, a) {
  use tok <- nibble.take_map("expected number")
  case tok {
    Num(num) -> Some(num)
    _ -> None
  }
}

fn report_parser() -> nibble.Parser(Report, Token, a) {
  use row <- nibble.do(nibble.many1(level_parser()))
  use _ <- nibble.do(nibble.token(Newline))
  nibble.return(row)
}

fn input_parser() -> nibble.Parser(Input, Token, b) {
  use rows <- nibble.do(nibble.many1(report_parser()))
  nibble.return(rows)
}

pub fn parse_input(input: String) -> Option(Input) {
  case lexer.run(input, lexer()) {
    Ok(a) ->
      nibble.run(a, input_parser())
      |> option.from_result()
    _ -> None
  }
}

// business logic 

pub fn part1(input: String) -> Option(Int) {
  part_runner(input, safe_p)
}

pub fn part2(input: String) -> Option(Int) {
  part_runner(input, safe_dampened_p)
}

fn part_runner(input: String, safe_fn: fn(Report) -> Bool) -> Option(Int) {
  use parsed_input <- option.map(parse_input(input))
  parsed_input
  |> list.map(safe_fn)
  |> list.count(function.identity)
}

pub fn safe_p(input: Report) -> Bool {
  within_range_p(input, ascending_comparator)
  || within_range_p(input, descending_comparator)
}

pub fn ascending_comparator(first: Level, second: Level) -> Bool {
  first < second && first + 3 >= second
}

pub fn descending_comparator(first: Level, second: Level) -> Bool {
  ascending_comparator(second, first)
}

fn iterate(
  acc: #(Level, Bool),
  curr: Level,
  comparator: fn(Level, Level) -> Bool,
) -> list.ContinueOrStop(#(Level, Bool)) {
  case comparator(pair.first(acc), curr) {
    True -> list.Continue(#(curr, True))
    False -> list.Stop(#(curr, False))
  }
}

pub fn within_range_p(
  input: Report,
  comparator: fn(Level, Level) -> Bool,
) -> Bool {
  let iterate_fn = fn(acc, curr) { iterate(acc, curr, comparator) }
  case input {
    [] -> True
    [head, ..tail] ->
      list.fold_until(tail, #(head, True), iterate_fn)
      |> pair.second()
  }
}

pub fn safe_dampened_p(input: Report) -> Bool {
  safe_p(input)
  || {
    list.combinations(input, list.length(input) - 1)
    |> list.map(safe_p)
    |> list.contains(True)
  }
}
