import aoc_2024/utils
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  let assert [rule_input, updates_input] = input |> string.split("\n\n")
  let rules = rule_input |> parse_rule_input
  let updates = updates_input |> parse_updates_input
  solve_1(rules, updates)
}

fn parse_rule_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(rule) {
    let assert [left, right] =
      rule |> string.split("|") |> list.map(utils.int_parse_unwrap)
    #(left, right)
  })
}

fn parse_updates_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(",") |> list.map(utils.int_parse_unwrap)
  })
}

fn solve_1(rules: List(#(Int, Int)), updates: List(List(Int))) -> Int {
  updates
  |> list.filter(verify_rules(rules, _))
  |> list.map(find_middle_element)
  |> int.sum
}

fn verify_rules(rules: List(#(Int, Int)), update: List(Int)) -> Bool {
  let rules_to_verify =
    update
    |> list.flat_map(fn(item) {
      rules
      |> list.filter(fn(rule) { rule.0 == item })
    })

  rules_to_verify |> list.all(verify_single_rule(_, update))
}

fn verify_single_rule(rule: #(Int, Int), update: List(Int)) {
  let #(left, right) = rule

  let update_with_indices =
    update
    |> list.index_map(fn(key, i) { #(key, i) })

  let left_index =
    update_with_indices
    |> list.find(fn(item) { item.0 == left })
    |> result.map(pair.second)
    |> utils.assert_unwrap

  let right_index =
    update_with_indices
    |> list.find(fn(item) { item.0 == right })
    |> result.map(pair.second)

  case right_index {
    Ok(index) -> left_index < index
    Error(_) -> True
  }
}

fn find_middle_element(update: List(Int)) -> Int {
  update
  |> list.drop({ list.length(update) - 1 } / 2)
  |> list.first
  |> utils.assert_unwrap
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
