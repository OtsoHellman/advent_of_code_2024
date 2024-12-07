import aoc_2024/lib/cache
import aoc_2024/lib/perf
import aoc_2024/utils/resultx
import carpenter/table
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let nums = input |> string.split("\n") |> list.map(resultx.int_parse_unwrap)

  nums
  |> list.sort(int.compare)
  |> list.window_by_2
  |> list.map(fn(pair) { pair.1 - pair.0 })
  |> list.append([1, 3])
  |> list.group(fn(diff) { diff })
  |> dict.map_values(fn(_, values) { values |> list.length })
  |> dict.values()
  |> int.product
}

pub fn pt_2(input: String) {
  let nums =
    input
    |> string.split("\n")
    |> list.map(resultx.int_parse_unwrap)
    |> list.append([0])
    |> list.sort(int.compare)

  let start = nums |> list.first |> resultx.assert_unwrap
  let end = nums |> list.last |> resultx.assert_unwrap

  cache.create()
  get_n_of_arrangements(nums, start, end)
}

fn get_n_of_arrangements(nums: List(Int), start: Int, end: Int) -> Int {
  use <- bool.guard(start == end, 1)
  use <- bool.guard(nums |> list.contains(start) |> bool.negate, 0)
  use <- cache.try_memo(start)

  list.range(1, 3)
  |> list.map(fn(jump) { get_n_of_arrangements(nums, start + jump, end) })
  |> int.sum
}
