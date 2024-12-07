import aoc_2024/utils/intx
import aoc_2024/utils/listx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/int
import gleam/list
import gleam/pair
import gleam/string

fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [calibration_string, nums_string] = string.split(line, ": ")

    #(
      calibration_string |> resultx.int_parse_unwrap,
      nums_string |> string.split(" ") |> list.map(resultx.int_parse_unwrap),
    )
  })
}

pub fn pt_1(input: String) {
  let equations = parse(input)

  equations
  |> list.filter(fn(equation) {
    let #(goal, nums) = equation
    let #(start, nums) = listx.pop(nums)

    is_valid_equation([int.sum, int.product], nums, goal, start)
  })
  |> list.map(pair.first)
  |> int.sum
}

type Operation =
  fn(List(Int)) -> Int

fn is_valid_equation(
  operations: List(Operation),
  nums: List(Int),
  goal: Int,
  agg: Int,
) -> Bool {
  use <- bool.guard(goal < agg, False)
  use <- bool.guard(list.is_empty(nums), agg == goal)

  operations
  |> list.any(fn(operation) {
    let #(head, nums) = listx.pop(nums)
    let agg = operation([agg, head])

    is_valid_equation(operations, nums, goal, agg)
  })
}

pub fn pt_2(input: String) {
  let equations = parse(input)

  equations
  |> list.filter(fn(equation) {
    let #(goal, nums) = equation
    let #(start, nums) = listx.pop(nums)

    is_valid_equation([int.sum, int.product, intx.undigits], nums, goal, start)
  })
  |> list.map(pair.first)
  |> int.sum
}
