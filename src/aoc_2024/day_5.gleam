import aoc_2024/utils/listx
import aoc_2024/utils/resultx
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
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
      rule |> string.split("|") |> list.map(resultx.int_parse_unwrap)
    #(left, right)
  })
}

fn parse_updates_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(",") |> list.map(resultx.int_parse_unwrap)
  })
}

fn solve_1(rules: List(#(Int, Int)), updates: List(List(Int))) -> Int {
  updates
  |> list.filter(verify_rules(rules, _))
  |> list.map(listx.find_middle_element)
  |> list.map(resultx.assert_unwrap)
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

  let left_index =
    update
    |> listx.find_first_index(fn(item) { item == left })
    |> resultx.assert_unwrap

  let right_index =
    update
    |> listx.find_first_index(fn(item) { item == right })

  case right_index {
    Ok(index) -> left_index < index
    Error(_) -> True
  }
}

pub fn pt_2(input: String) {
  let assert [rule_input, updates_input] = input |> string.split("\n\n")
  let rules = rule_input |> parse_rule_input
  let updates = updates_input |> parse_updates_input
  solve_2(rules, updates)
}

fn solve_2(rules: List(#(Int, Int)), updates: List(List(Int))) -> Int {
  updates
  |> list.filter(fn(item) { !verify_rules(rules, item) })
  |> list.map(sort_update(rules, _))
  |> list.map(listx.find_middle_element)
  |> list.map(resultx.assert_unwrap)
  |> int.sum
}

fn sort_update(rules: List(#(Int, Int)), update: List(Int)) -> List(Int) {
  update
  |> list.sort(fn(left, right) { sort_two_elements(rules, #(left, right)) })
}

fn sort_two_elements(rules: List(#(Int, Int)), pair: #(Int, Int)) -> order.Order {
  let rule =
    rules
    |> list.find(fn(rule) { rule == pair || rule == pair.swap(pair) })

  case rule {
    Ok(rule) ->
      case rule == pair {
        True -> order.Lt
        False -> order.Gt
      }
    Error(_) -> order.Eq
  }
}
