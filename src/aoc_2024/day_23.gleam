import aoc_2024/lib/cache
import aoc_2024/lib/conc
import aoc_2024/lib/perf
import aoc_2024/utils/listx
import gleam/bool
import gleam/list
import gleam/set
import gleam/string

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(pair) { pair |> string.split("-") })
}

pub fn pt_1(input: String) {
  let pairs = parse_input(input)
  let filtered_pairs =
    pairs
    |> list.filter(fn(pair) {
      pair |> list.any(fn(string) { string.starts_with(string, "t") })
    })

  filtered_pairs
  |> list.map(fn(pair) {
    let assert [a, b] = pair
    let a_pairs =
      list.filter(pairs, fn(pair) { pair |> list.contains(a) })
      |> list.flatten
      |> list.unique
      |> list.filter(fn(x) { x != a && x != b })
    let b_pairs =
      list.filter(pairs, fn(pair) { pair |> list.contains(b) })
      |> list.flatten
      |> list.filter(fn(x) { x != a && x != b })
      |> set.from_list

    list.filter(a_pairs, fn(x) { set.contains(b_pairs, x) })
    |> list.map(fn(match) { [a, b, match] })
    |> list.map(fn(x) { list.sort(x, string.compare) })
  })
  |> list.flatten
  |> list.unique
  |> list.length
}

type AdjList =
  List(List(String))

pub fn pt_2(input: String) {
  use <- perf.measure("pt2")
  cache.create_named("neighbor_cache")
  cache.create_named("clique_cache")

  let pairs = parse_input(input)

  pairs
  |> list.flatten
  |> list.unique
  |> conc.map(fn(computer) {
    let current_clique = set.from_list([computer])
    let remaining = find_neighbors(pairs, computer)

    get_largest_clique(pairs, current_clique, remaining)
  })
  |> listx.max_by(set.size)
  |> set.to_list
  |> list.sort(string.compare)
  |> string.join(",")
}

fn get_largest_clique(
  pairs: AdjList,
  current_clique: set.Set(String),
  remaining: set.Set(String),
) {
  use <- cache.memoize_named("clique_cache", current_clique)
  use <- bool.guard(set.is_empty(remaining), current_clique)

  remaining
  |> set.to_list
  |> list.map(fn(node) {
    let neighbors = find_neighbors(pairs, node)
    let current_clique = set.insert(current_clique, node)
    let remaining = set.intersection(remaining, neighbors)

    get_largest_clique(pairs, current_clique, remaining)
  })
  |> listx.max_by(set.size)
}

fn find_neighbors(pairs: AdjList, node: String) {
  use <- cache.memoize_named("neighbor_cache", node)
  list.filter(pairs, fn(pair) { pair |> list.contains(node) })
  |> list.flatten
  |> list.filter(fn(x) { x != node })
  |> set.from_list
}
