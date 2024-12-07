import aoc_2024/utils/resultx
import gleam/int
import gleam/list
import gleam/string

pub fn undigits(list: List(Int)) {
  list
  |> list.map(int.to_string)
  |> string.concat()
  |> resultx.int_parse_unwrap
}
