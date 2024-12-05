import aoc_2024/utils/dictx
import aoc_2024/utils/resultx
import aoc_2024/utils/stringx
import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(string_to_int_list)
  |> list.map(get_first_and_last)
  |> list.map(fn(line) { line |> int.undigits(10) |> resultx.assert_unwrap })
  |> int.sum
}

fn string_to_int_list(input: String) {
  input |> string.to_graphemes |> list.map(int.parse) |> result.values
}

fn get_first_and_last(nums: List(Int)) {
  let assert Ok(head) = list.first(nums)
  let assert Ok(tail) = list.last(nums)
  [head, tail]
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.map(get_line_first_and_last)
  |> list.map(fn(line) { line |> int.undigits(10) |> resultx.assert_unwrap })
  |> int.sum
}

fn get_line_first_and_last(line: String) -> List(Int) {
  let digits =
    dict.from_list([
      #("one", 1),
      #("two", 2),
      #("three", 3),
      #("four", 4),
      #("five", 5),
      #("six", 6),
      #("seven", 7),
      #("eight", 8),
      #("nine", 9),
      #("1", 1),
      #("2", 2),
      #("3", 3),
      #("4", 4),
      #("5", 5),
      #("6", 6),
      #("7", 7),
      #("8", 8),
      #("9", 9),
    ])

  let substring_indices =
    digits
    |> dict.keys
    |> list.map(fn(key) { #(key, stringx.get_substring_indices(line, key)) })
    |> dict.from_list

  let first_substring =
    substring_indices
    |> dict.filter(fn(_, indices) { !list.is_empty(indices) })
    |> dict.map_values(fn(_, value) {
      value |> list.first |> resultx.assert_unwrap
    })
    |> dictx.min_by(fn(value) { value })
    |> pair.first

  let last_substring =
    substring_indices
    |> dict.filter(fn(_, indices) { !list.is_empty(indices) })
    |> dict.map_values(fn(_, value) {
      value |> list.last |> resultx.assert_unwrap
    })
    |> dictx.max_by(fn(value) { value })
    |> pair.first

  [digits |> dict.get(first_substring), digits |> dict.get(last_substring)]
  |> result.all
  |> resultx.assert_unwrap
}
