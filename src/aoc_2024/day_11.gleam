import aoc_2024/lib/cache
import aoc_2024/lib/perf
import aoc_2024/utils/resultx
import gleam/bool
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  use <- perf.measure("pt1")
  input
  |> string.split(" ")
  |> list.map(resultx.int_parse_unwrap)
  |> blink_naive(25)
  |> list.length
}

fn blink_naive(stones: List(Int), i: Int) -> List(Int) {
  use <- bool.guard(i <= 0, stones)

  let stones = stones |> list.flat_map(handle_stone_naive)

  blink_naive(stones, i - 1)
}

fn handle_stone_naive(stone: Int) {
  let #(left, right) = split_stone(stone)

  use <- bool.guard(list.length(left) == list.length(right), [
    int.undigits(left, 10) |> resultx.assert_unwrap,
    int.undigits(right, 10) |> resultx.assert_unwrap,
  ])

  case stone {
    0 -> [1]
    stone -> [stone * 2024]
  }
}

fn split_stone(stone: Int) {
  let digits = stone |> int.digits(10) |> resultx.assert_unwrap
  list.split(digits, list.length(digits) / 2)
}

pub fn pt_2(input: String) {
  cache.create()
  let n = 75
  use <- perf.measure("pt2, n=" <> int.to_string(n))

  input
  |> string.split(" ")
  |> list.map(resultx.int_parse_unwrap)
  |> list.map(fn(stone) { handle_stone(stone, n) })
  |> int.sum
}

fn handle_stone(stone: Int, i: Int) -> Int {
  use <- bool.guard(i <= 0, 1)

  use <- cache.try_memo(#(stone, i))

  let #(left, right) = split_stone(stone)

  let stones = case list.length(left) == list.length(right) {
    True -> [
      int.undigits(left, 10) |> resultx.assert_unwrap,
      int.undigits(right, 10) |> resultx.assert_unwrap,
    ]
    False ->
      case stone {
        0 -> [1]
        stone -> [stone * 2024]
      }
  }

  stones |> list.map(handle_stone(_, i - 1)) |> int.sum
}
