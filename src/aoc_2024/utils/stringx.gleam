import gleam/list
import gleam/pair
import gleam/string

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
