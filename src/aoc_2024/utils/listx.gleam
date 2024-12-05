import gleam/list
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
