import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
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

fn day01_lexer() -> lexer.Lexer(Token, Nil) {
  lexer.simple([
    lexer.int(Num),
    lexer.token("\n", Newline),
    lexer.spaces(Nil) |> lexer.ignore,
  ])
}

fn day01_num_parser() -> nibble.Parser(Int, Token, a) {
  use tok <- nibble.take_map("expected number")
  case tok {
    Num(num) -> Some(num)
    _ -> None
  }
}

fn day01_row_parser() -> nibble.Parser(#(Int, Int), Token, a) {
  use r_number <- nibble.do(day01_num_parser())
  use l_number <- nibble.do(day01_num_parser())
  use _ <- nibble.do(nibble.token(Newline))
  nibble.return(#(l_number, r_number))
}

fn day01_input_parser() -> nibble.Parser(List(#(Int, Int)), Token, b) {
  use rows <- nibble.do(nibble.many(day01_row_parser()))
  nibble.return(rows)
}

fn day01_parse_input(input: String) -> Option(Day01Input) {
  case lexer.run(input, day01_lexer()) {
    Ok(a) ->
      nibble.run(a, day01_input_parser())
      |> option.from_result()
    _ -> None
  }
}

// Day 01 Logic

pub fn day01_part1(input: String) -> Option(Int) {
  input
  |> day01_parse_input()
  |> option.map(day01_sort_input)
  |> option.map(day01_distances)
}

fn day01_sort_input(input: Day01Input) -> Day01Input {
  let sort_fn = fn(a, b) {
    case a < b {
      True -> order.Lt
      False -> order.Gt
    }
  }
  let first_list =
    list.map(input, fn(x) { x.0 })
    |> list.sort(sort_fn)
  let second_list =
    list.map(input, fn(x) { x.1 })
    |> list.sort(sort_fn)
  list.map2(first_list, second_list, fn(a, b) { #(a, b) })
}

fn day01_row_distance(row: NumberRow) -> Int {
  row.0 - row.1
  |> int.absolute_value()
}

fn day01_distances(input: Day01Input) -> Int {
  list.map(input, day01_row_distance)
  |> list.fold(0, fn(a, b) { a + b })
}

pub fn day01_part2(input: String) -> Option(Int) {
  input
  |> day01_parse_input()
  |> option.map(day01_all_similarity_score)
}

fn day01_num_frequency(n: Int, ns: List(Int)) -> Int {
  list.fold(ns, 0, fn(a, x) {
    case n == x {
      True -> a + 1
      _ -> a
    }
  })
}

fn day01_all_num_frequency(ns1: List(Int), ns2: List(Int)) -> List(#(Int, Int)) {
  list.map(ns1, fn(x) { #(x, day01_num_frequency(x, ns2)) })
}

fn day01_all_similarity_score(input: Day01Input) -> Int {
  let list1 = list.map(input, fn(x) { x.0 })
  let list2 = list.map(input, fn(x) { x.1 })
  let freqs = day01_all_num_frequency(list1, list2)
  list.fold(freqs, 0, fn(a, x) { a + { x.0 * x.1 } })
}
