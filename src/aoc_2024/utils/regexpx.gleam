import aoc_2024/utils/resultx
import gleam/list
import gleam/regexp

pub fn get_positive_ints(input: String) -> List(Int) {
  let assert Ok(regexp) = regexp.from_string("[0-9]+")
  regexp.scan(regexp, input)
  |> list.map(fn(match) { match.content })
  |> list.map(resultx.int_parse_unwrap)
}

pub fn get_ints(input: String) -> List(Int) {
  let assert Ok(regexp) = regexp.from_string("-?[0-9]+")
  regexp.scan(regexp, input)
  |> list.map(fn(match) { match.content })
  |> list.map(resultx.int_parse_unwrap)
}
