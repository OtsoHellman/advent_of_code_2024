import aoc_2024/utils
import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

pub fn pt_1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\([0-9]+,[0-9]+\\)")
  let assert Ok(number_re) = regexp.from_string("[0-9]+")
  let muls = regexp.scan(re, input) |> list.map(fn(match) { match.content })
  let numbers =
    muls
    |> list.map(fn(mul) {
      regexp.scan(number_re, mul)
      |> list.map(fn(match) { match.content })
    })
  numbers
  |> list.map(fn(pair) {
    pair |> list.map(int.parse) |> list.map(utils.assert_unwrap)
  })
  |> list.map(fn(pair) { pair |> int.product })
  |> int.sum
}

pub fn pt_2(input: String) {
  let dos = input |> string.split("do()")
  dos
  |> list.map(fn(do) {
    let assert [head, ..] = do |> string.split("don't()")
    pt_1(head)
  })
  |> int.sum
}
