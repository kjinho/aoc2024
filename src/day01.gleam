import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import nibble
import nibble/lexer

// Day 01 Data

type NumberRow =
  #(Int, Int)

type Day01Input =
  List(NumberRow)

// Day 01 Parser

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

fn num_parser() -> nibble.Parser(Int, Token, a) {
  use tok <- nibble.take_map("expected number")
  case tok {
    Num(num) -> Some(num)
    _ -> None
  }
}

fn row_parser() -> nibble.Parser(#(Int, Int), Token, a) {
  use r_number <- nibble.do(num_parser())
  use l_number <- nibble.do(num_parser())
  use _ <- nibble.do(nibble.token(Newline))
  nibble.return(#(l_number, r_number))
}

fn input_parser() -> nibble.Parser(List(#(Int, Int)), Token, b) {
  use rows <- nibble.do(nibble.many(row_parser()))
  nibble.return(rows)
}

fn parse_input(input: String) -> Option(Day01Input) {
  case lexer.run(input, lexer()) {
    Ok(a) ->
      nibble.run(a, input_parser())
      |> option.from_result()
    _ -> None
  }
}

// Day 01 Logic

pub fn part1(input: String) -> Option(Int) {
  input
  |> parse_input()
  |> option.map(sort_input)
  |> option.map(distances)
}

fn sort_input(input: Day01Input) -> Day01Input {
  let first_list =
    list.map(input, pair.first)
    |> list.sort(int.compare)
  let second_list =
    list.map(input, pair.second)
    |> list.sort(int.compare)
  list.map2(first_list, second_list, pair.new)
}

fn row_distance(row: NumberRow) -> Int {
  row.0 - row.1
  |> int.absolute_value()
}

fn distances(input: Day01Input) -> Int {
  list.map(input, row_distance)
  |> list.fold(0, int.add)
}

pub fn part2(input: String) -> Option(Int) {
  input
  |> parse_input()
  |> option.map(all_similarity_score)
}

fn num_frequency(n: Int, ns: List(Int)) -> Int {
  list.count(ns, fn(x) { n == x })
}

fn all_num_frequency(ns1: List(Int), ns2: List(Int)) -> List(#(Int, Int)) {
  list.map(ns1, fn(x) { #(x, num_frequency(x, ns2)) })
}

fn all_similarity_score(input: Day01Input) -> Int {
  let list1 = list.map(input, pair.first)
  let list2 = list.map(input, pair.second)
  let freqs = all_num_frequency(list1, list2)
  list.fold(freqs, 0, fn(acc, row) { acc + { row.0 * row.1 } })
}
