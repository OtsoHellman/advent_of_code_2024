import gleam/list
import gleam/string
import gleam_community/maths/combinatorics.{cartesian_product}

fn parse_pattern(pattern: String) {
  string.split(pattern, "\n")
  |> list.map(fn(line) { line |> string.split("") })
  |> list.transpose
  |> list.map(fn(line) { list.count(line, fn(x) { x == "#" }) - 1 })
}

pub fn pt_1(input: String) {
  let patterns = input |> string.split("\n\n")
  let locks =
    list.filter(patterns, string.starts_with(_, "#")) |> list.map(parse_pattern)
  let keys =
    list.filter(patterns, string.starts_with(_, ".")) |> list.map(parse_pattern)

  use #(lock, key) <- list.count(cartesian_product(locks, keys))
  list.all(list.zip(lock, key), fn(x) { x.0 + x.1 < 6 })
}

pub fn pt_2(_input: String) {
  1
}
