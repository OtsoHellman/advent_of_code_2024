import aoc_2024/utils/listx
import gleam/dict
import gleam/int
import gleam/order
import gleam/pair

pub fn assert_reduce(
  input: dict.Dict(k, v),
  predicate: fn(#(k, v), #(k, v)) -> #(k, v),
) -> #(k, v) {
  input |> dict.to_list |> listx.assert_reduce(predicate)
}

pub fn min_by(input: dict.Dict(k, v), predicate: fn(v) -> Int) {
  use left, right <- assert_reduce(input)

  let left_value = predicate(left |> pair.second)
  let right_value = predicate(right |> pair.second)

  case int.compare(left_value, right_value) {
    order.Gt -> right
    _ -> left
  }
}

pub fn max_by(input: dict.Dict(k, v), predicate: fn(v) -> Int) {
  use left, right <- assert_reduce(input)

  let left_value = predicate(left |> pair.second)
  let right_value = predicate(right |> pair.second)

  case int.compare(left_value, right_value) {
    order.Lt -> right
    _ -> left
  }
}
