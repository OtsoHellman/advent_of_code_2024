import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/string

pub fn assert_unwrap(result: Result(t, _)) -> t {
  case result {
    Ok(value) -> value
    _ -> panic
  }
}

pub fn int_parse_unwrap(input: String) -> Int {
  case int.parse(input) {
    Ok(value) -> value
    _ -> panic
  }
}

pub fn get_substring_indices(input: String, substring: String) {
  let splits_with_tail = input |> string.split(substring)
  let splits =
    splits_with_tail
    |> list.take(list.length(splits_with_tail) - 1)

  let split_lengths = splits |> list.map(fn(split) { split |> string.length })

  split_lengths
  |> list.map_fold(0, fn(prev_length, split_length) {
    let current_index = prev_length + split_length
    let next_length = current_index + string.length(substring)

    #(next_length, current_index)
  })
  |> pair.second
}

pub fn min_by(input: dict.Dict(String, a), predicate: fn(a) -> Int) {
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
  |> assert_unwrap
}

pub fn max_by(input: dict.Dict(String, a), predicate: fn(a) -> Int) {
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
  |> assert_unwrap
}
