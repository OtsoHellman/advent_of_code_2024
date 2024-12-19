import aoc_2024/lib/cache
import gleam/bool
import gleam/int
import gleam/list
import gleam/string

fn parse_input(input: String) {
  let assert [a, b] = input |> string.split("\n\n")

  let patterns = a |> string.split(", ")

  let designs = b |> string.split("\n")

  #(patterns, designs)
}

pub fn pt_1(input: String) {
  let #(patterns, designs) = parse_input(input)
  cache.create()

  list.count(designs, fn(design) { n_of_valid_patterns(patterns, design) > 0 })
}

fn n_of_valid_patterns(patterns: List(String), design: String) -> Int {
  use <- cache.try_memo(design)

  use <- bool.guard(string.is_empty(design), 1)

  let valid_starts =
    patterns
    |> list.filter(fn(pattern) { string.starts_with(design, pattern) })

  use <- bool.guard(list.is_empty(valid_starts), 0)

  valid_starts
  |> list.map(fn(start) { design |> string.drop_start(start |> string.length) })
  |> list.map(fn(design) { n_of_valid_patterns(patterns, design) })
  |> int.sum
}

pub fn pt_2(input: String) {
  let #(patterns, designs) = parse_input(input)

  list.map(designs, n_of_valid_patterns(patterns, _)) |> int.sum
}
