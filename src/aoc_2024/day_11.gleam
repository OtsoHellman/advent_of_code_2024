import aoc_2024/lib/cache
import aoc_2024/lib/perf
import aoc_2024/utils/intx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(Int) {
  input
  |> string.split(" ")
  |> list.map(resultx.int_parse_unwrap)
}

pub fn pt_1(input: List(Int)) {
  use <- perf.measure("pt1")

  input
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
  let digits = intx.digits_assert(stone)
  list.split(digits, list.length(digits) / 2)
}

pub fn pt_2(input: List(Int)) {
  use <- perf.measure("pt1")
  cache.create()

  input
  |> list.map(fn(stone) { handle_stone(stone, 75) })
  |> int.sum
}

fn handle_stone(stone: Int, i: Int) -> Int {
  use <- bool.guard(i <= 0, 1)

  use <- cache.try_memo(#(stone, i))

  let stones = case stone, intx.length(stone) {
    0, _ -> [1]

    stone, digits if digits % 2 == 0 -> {
      let #(left, right) = split_stone(stone)
      [left, right]
      |> list.map(intx.undigits_assert)
    }

    stone, _ -> [stone * 2024]
  }

  stones |> list.map(handle_stone(_, i - 1)) |> int.sum
}
