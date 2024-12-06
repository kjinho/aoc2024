import day01
import day02
import day03
import day04
import day05
import day06
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

  day01.part1(part1_input)
  |> should.equal(Ok(11))

  day01.part1(part1_input2)
  |> should.equal(Ok(1_873_376))

  day01.part2(part1_input)
  |> should.equal(Ok(31))

  day01.part2(part1_input2)
  |> should.equal(Ok(18_997_088))
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

  day02.within_range_p([], day02.descending_comparator)
  |> should.be_true()

  day02.within_range_p([5], day02.descending_comparator)
  |> should.be_true()

  day02.within_range_p([5, 4], day02.descending_comparator)
  |> should.be_true()

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

pub fn day03_test() {
  let part1_input =
    //"%mul(2,4)xxmul(5,2)"
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

  let part1_input2 =
    "input/day03.input"
    |> simplifile.read()
    |> result.unwrap("")

  let part2_input =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

  part1_input
  |> day03.part1()
  |> should.equal(161)

  part1_input2
  |> day03.part1()
  |> should.equal(188_192_787)

  part2_input
  |> day03.part2()
  |> should.equal(48)

  part1_input2
  |> day03.part2()
  |> should.equal(113_965_544)
}

pub fn day04_test() {
  let part1_input =
    "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"

  let _part1_input2 =
    "input/day04.input"
    |> simplifile.read()
    |> result.unwrap("")

  part1_input
  |> day04.part1()
  |> should.equal(Some(18))
  // part1_input2
  // |> day04.part1()
  // |> should.equal(Some(18))

  part1_input
  |> day04.part2()
  |> should.equal(Some(9))
  // part1_input2
  // |> day04.part2()
  // |> should.equal(Some(9))
}

pub fn day05_test() {
  let part1_input =
    "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"

  let part1_input2 =
    "input/day05.input"
    |> simplifile.read()
    |> result.unwrap("")

  part1_input
  |> day05.part1()
  |> should.equal(Some(143))

  part1_input2
  |> day05.part1()
  |> should.equal(Some(6242))

  part1_input
  |> day05.part2()
  |> should.equal(Some(123))

  part1_input2
  |> day05.part2()
  |> should.equal(Some(5169))
}

pub fn day06_test() {
  let part1_input =
    "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"

  let part1_input2 =
    "input/day06.input"
    |> simplifile.read()
    |> result.unwrap("")

  part1_input
  |> day06.part1()
  |> should.equal(Ok(41))

  part1_input2
  |> day06.part1()
  |> should.equal(Ok(5551))

  part1_input
  |> day06.part2()
  |> should.equal(Ok(6))

  part1_input2
  |> day06.part2()
  |> should.equal(Ok(1939))
}
