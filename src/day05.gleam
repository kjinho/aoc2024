import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import nibble
import nibble/lexer

type PageOrderingRules =
  List(Rule)

type Page =
  Int

type Rule {
  Rule(Page, Page)
}

type Updates =
  List(Update)

type Update =
  List(Page)

type Input =
  #(PageOrderingRules, Updates)

// parser

type Token {
  Num(Int)
  Pipe
  Newline
  Comma
}

fn lexer() -> lexer.Lexer(Token, Nil) {
  lexer.simple([
    lexer.int(Num),
    lexer.token("\n", Newline),
    lexer.token("|", Pipe),
    lexer.token(",", Comma),
    lexer.spaces(Nil) |> lexer.ignore,
  ])
}

fn page_parser() -> nibble.Parser(Page, Token, a) {
  use tok <- nibble.take_map("expected number")
  case tok {
    Num(num) -> Some(num)
    _ -> None
  }
}

fn rule_parser() -> nibble.Parser(Rule, Token, a) {
  use num1 <- nibble.do(page_parser())
  use _ <- nibble.do(nibble.token(Pipe))
  use num2 <- nibble.do(page_parser())
  use _ <- nibble.do(nibble.token(Newline))

  nibble.return(Rule(num1, num2))
}

fn rules_parser() -> nibble.Parser(PageOrderingRules, Token, a) {
  use rules <- nibble.do(nibble.many1(rule_parser()))
  nibble.return(rules)
}

fn update_parser() -> nibble.Parser(Update, Token, a) {
  use nums <- nibble.do(nibble.sequence(page_parser(), nibble.token(Comma)))
  use _ <- nibble.do(nibble.token(Newline))

  nibble.return(nums)
}

fn updates_parser() -> nibble.Parser(Updates, Token, a) {
  use updates <- nibble.do(nibble.many1(update_parser()))
  nibble.return(updates)
}

fn input_parser() -> nibble.Parser(Input, Token, a) {
  use rules <- nibble.do(rules_parser())
  use _ <- nibble.do(nibble.token(Newline))
  use updates <- nibble.do(updates_parser())
  nibble.return(#(rules, updates))
}

fn parse_input(input: String) -> Option(Input) {
  input
  |> lexer.run(lexer())
  |> option.from_result()
  |> option.map(nibble.run(_, input_parser()))
  |> option.map(option.from_result(_))
  |> option.flatten()
}

// business logic

fn update_correct_p(rules: PageOrderingRules, update: Update, acc) -> Bool {
  case update, acc {
    _, False -> False
    [], _ | [_], _ -> acc
    [first, ..rest], _ ->
      list.fold_until(rest, True, fn(_acc, next) {
        case page_correct_p(first, next, rules) {
          True -> list.Continue(True)
          False -> list.Stop(False)
        }
      })
      |> update_correct_p(rules, rest, _)
  }
}

fn page_correct_p(page1: Page, page2: Page, rules: PageOrderingRules) -> Bool {
  list.contains(rules, Rule(page1, page2))
}

fn get_middle_number(update: Update) -> Option(Page) {
  case update {
    [] -> None
    [a] -> Some(a)
    _ -> {
      let len = list.length(update)
      list.drop(update, len / 2)
      |> list.first
      |> option.from_result
    }
  }
}

pub fn part1(input: String) -> Option(Int) {
  input
  |> parse_input()
  |> option.map(fn(x) {
    let #(rules, updates) = x
    list.filter(updates, update_correct_p(rules, _, True))
    |> list.map(get_middle_number)
    |> option.values()
    |> list.fold(0, int.add)
  })
}

fn compare_pages(
  page1: Page,
  page2: Page,
  rules: PageOrderingRules,
) -> order.Order {
  case page1 == page2 {
    True -> order.Eq
    _ ->
      case list.contains(rules, Rule(page1, page2)) {
        True -> order.Lt
        _ -> order.Gt
      }
  }
}

pub fn part2(input: String) -> Option(Int) {
  input
  |> parse_input()
  |> option.map(fn(x) {
    let #(rules, updates) = x
    list.filter(updates, fn(x) { !update_correct_p(rules, x, True) })
    |> list.map(list.sort(_, fn(a, b) { compare_pages(a, b, rules) }))
    |> list.map(get_middle_number)
    |> option.values()
    |> list.fold(0, int.add)
  })
}
