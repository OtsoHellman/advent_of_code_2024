import aoc_2024/utils/resultx
import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

pub fn pt_1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\([0-9]+,[0-9]+\\)")

  let mul_expressions =
    regexp.scan(re, input) |> list.map(fn(match) { match.content })

  mul_expressions
  |> list.map(parse_mul_expression)
  |> int.sum
}

fn parse_mul_expression(input: String) {
  let assert Ok(number_re) = regexp.from_string("[0-9]+")

  regexp.scan(number_re, input)
  |> list.map(fn(match) { match.content })
  |> list.map(resultx.int_parse_unwrap)
  |> int.product
}

pub fn pt_2(input: String) {
  input
  |> string.split("do()")
  |> list.map(drop_donts)
  |> list.map(pt_1)
  |> int.sum
}

fn drop_donts(input: String) {
  case input |> string.split("don't()") {
    [head, ..] -> head
    [] -> input
  }
}
