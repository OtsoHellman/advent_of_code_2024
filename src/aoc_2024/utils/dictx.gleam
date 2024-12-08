import aoc_2024/utils/resultx
import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/pair

pub fn min_by(input: dict.Dict(k, v), predicate: fn(v) -> Int) {
  input
  |> dict.to_list
  |> list.reduce(fn(left, right) {
    let left_value = predicate(left |> pair.second)
    let right_value = predicate(right |> pair.second)

    case int.compare(left_value, right_value) {
      order.Gt -> right
      _ -> left
    }
  })
  |> resultx.assert_unwrap
}

pub fn max_by(input: dict.Dict(k, v), predicate: fn(v) -> Int) {
  input
  |> dict.to_list
  |> list.reduce(fn(left, right) {
    let left_value = predicate(left |> pair.second)
    let right_value = predicate(right |> pair.second)

    case int.compare(left_value, right_value) {
      order.Lt -> right
      _ -> left
    }
  })
  |> resultx.assert_unwrap
}
