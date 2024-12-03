import day01
import day02
import gleam/option.{Some}
import gleam/result
import gleeunit
import gleeunit/should
import simplifile

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn day01_part1_test() {
  let part1_input =
    "3   4
4   3
2   5
1   3
3   9
3   3
"

  let part1_input2 =
    "input/day01.input"
    |> simplifile.read()
    |> result.unwrap("")

  day01.day01_part1(part1_input)
  |> should.equal(Some(11))

  day01.day01_part1(part1_input2)
  |> should.equal(Some(1_873_376))

  day01.day01_part2(part1_input)
  |> should.equal(Some(31))

  day01.day01_part2(part1_input2)
  |> should.equal(Some(18_997_088))
}

pub fn day02_test() {
  let part1_input =
    "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"

  let part1_input2 =
    "input/day02.input"
    |> simplifile.read()
    |> result.unwrap("")

  // day02.within_range_p([], day02.descending_comparator)
  // |> should.be_true()

  // day02.within_range_p([5], day02.descending_comparator)
  // |> should.be_true()

  // day02.within_range_p([5, 4], day02.descending_comparator)
  // |> should.be_true()

  day02.safe_p([7, 6, 4, 2, 1])
  |> should.be_true()

  day02.safe_p([1, 3, 6, 7, 9])
  |> should.be_true()

  day02.safe_p([1, 2, 4, 5])
  |> should.be_true()

  day02.part1(part1_input)
  |> should.equal(Some(2))

  day02.part1(part1_input2)
  |> should.equal(Some(526))

  day02.safe_dampened_p([7, 6, 4, 2, 1])
  |> should.be_true()

  day02.safe_dampened_p([1, 2, 7, 8, 9])
  |> should.be_false()

  day02.safe_dampened_p([9, 7, 6, 2, 1])
  |> should.be_false()

  day02.safe_dampened_p([1, 3, 2, 4, 5])
  |> should.be_true()

  day02.part2(part1_input)
  |> should.equal(Some(4))

  day02.part2(part1_input2)
  |> should.equal(Some(566))
}
