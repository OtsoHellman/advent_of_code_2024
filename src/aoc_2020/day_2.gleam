import aoc_2024/utils/regexpx
import aoc_2024/utils/resultx
import aoc_2024/utils/stringx
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(Policy) {
  input |> string.split("\n") |> list.map(parse_policy)
}

fn parse_policy(input: String) -> Policy {
  let assert [limits, char_string, password] = input |> string.split(" ")
  let assert [min, max] = limits |> regexpx.get_positive_ints

  let char = char_string |> string.first |> resultx.assert_unwrap

  Policy(min, max, char, password)
}

pub type Policy {
  Policy(min: Int, max: Int, char: String, password: String)
}

pub fn pt_1(policys: List(Policy)) {
  policys |> list.count(is_valid_password)
}

fn is_valid_password(policy: Policy) {
  case
    stringx.get_substring_indices(policy.password, policy.char) |> list.length
  {
    n if policy.min <= n && n <= policy.max -> True
    _ -> False
  }
}

pub fn pt_2(policys: List(Policy)) {
  policys |> list.count(is_valid_password_2)
}

fn is_valid_password_2(policy: Policy) {
  stringx.get_substring_indices(policy.password, policy.char)
  |> list.map(int.add(_, 1))
  |> list.count(fn(i) { i == policy.min || i == policy.max })
  |> fn(x) { x == 1 }
}
