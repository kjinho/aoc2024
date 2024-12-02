import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import nibble.{do, return}
import nibble/lexer

pub fn main() {
  io.println("Hello from aoc2024!")
}

type NumberRow =
  #(Int, Int)

type Day01Input =
  List(NumberRow)

type Token {
  Num(Int)
  Newline
}

fn day01_parse_input(input: String) -> Option(Day01Input) {
  let lexer =
    lexer.simple([
      lexer.int(Num),
      lexer.token("\n", Newline),
      lexer.spaces(Nil) |> lexer.ignore,
    ])

  let parser_num = fn() {
    use tok <- nibble.take_map("expected number")
    case tok {
      Num(num) -> Some(num)
      _ -> None
    }
  }

  let parser_row = {
    use l_number <- do(parser_num())
    use r_number <- do(parser_num())
    use _ <- do(nibble.token(Newline))

    return(#(l_number, r_number))
  }

  let parser = {
    use rows <- do(nibble.many(parser_row))

    return(rows)
  }

  input
  |> lexer.run(lexer)
  |> result.then(fn(x) {
    nibble.run(x, parser) |> result.replace_error(lexer.NoMatchFound(0, 0, ""))
  })
  |> option.from_result()
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

pub fn day01_part1(input: String) -> Option(Int) {
  input
  |> day01_parse_input()
  |> option.map(day01_sort_input)
  |> option.map(day01_distances)
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

fn day01_all_num_frequency(ns1: List(Int), ns2: List(Int)) -> List(#(Int,Int)) {
  list.map(ns1, fn(x) {#(x,day01_num_frequency(x,ns2))})
}

fn day01_all_similarity_score(input: Day01Input) -> Int {
  let list1 = list.map(input, fn(x){x.0})
  let list2 = list.map(input, fn(x){x.1})
  let freqs = day01_all_num_frequency(list1, list2)
  list.fold(freqs, 0, fn(a,x) {
    a + {x.0 * x.1}
  })
}
