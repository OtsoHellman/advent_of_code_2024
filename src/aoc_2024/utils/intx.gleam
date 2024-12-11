import aoc_2024/utils/resultx
import gleam/int
import gleam/list
import gleam/string

pub fn digits_assert(input: Int) {
  input |> int.digits(10) |> resultx.assert_unwrap
}

pub fn undigits(list: List(Int)) {
  list
  |> list.map(int.to_string)
  |> string.concat()
  |> resultx.int_parse_unwrap
}

pub fn undigits_assert(list: List(Int)) {
  list |> int.undigits(10) |> resultx.assert_unwrap
}

pub fn length(input: Int) {
  input |> int.digits(10) |> resultx.assert_unwrap |> list.length
}
