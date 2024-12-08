import aoc_2024/utils/resultx
import gleam/int
import gleam/list
import gleam/order
import gleam/pair

pub fn zip_with_index(list: List(a)) -> List(#(a, Int)) {
  list |> list.index_map(fn(key, i) { #(key, i) })
}

pub fn find_indices(list: List(a), predicate: fn(a) -> Bool) -> List(Int) {
  list
  |> zip_with_index
  |> list.filter(fn(item) { predicate(item.0) })
  |> list.map(pair.second)
}

pub fn find_first_index(
  list: List(a),
  predicate: fn(a) -> Bool,
) -> Result(Int, Nil) {
  list
  |> find_indices(predicate)
  |> list.first
}

pub fn find_middle_element(update: List(a)) -> Result(a, Nil) {
  update
  |> list.drop({ list.length(update) - 1 } / 2)
  |> list.first
}

pub fn at_try(list: List(a), i: Int) -> Result(a, Nil) {
  list |> list.drop(i) |> list.first
}

pub fn at(list: List(a), i: Int) -> a {
  let new_i = int.modulo(i, list.length(list)) |> resultx.assert_unwrap
  list |> at_try(new_i) |> resultx.assert_unwrap
}

pub fn pop(list: List(a)) -> #(a, List(a)) {
  let assert Ok(result) = list.pop(list, fn(_) { True })

  result
}

pub fn min_by(input: List(a), predicate: fn(a) -> Int) {
  input
  |> list.reduce(fn(left, right) {
    let left_value = predicate(left)
    let right_value = predicate(right)

    case int.compare(left_value, right_value) {
      order.Gt -> right
      _ -> left
    }
  })
  |> resultx.assert_unwrap
}

pub fn max_by(input: List(a), predicate: fn(a) -> Int) {
  input
  |> list.reduce(fn(left, right) {
    let left_value = predicate(left)
    let right_value = predicate(right)

    case int.compare(left_value, right_value) {
      order.Lt -> right
      _ -> left
    }
  })
  |> resultx.assert_unwrap
}
