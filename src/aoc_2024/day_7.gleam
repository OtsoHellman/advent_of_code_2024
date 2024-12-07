import aoc_2024/utils/resultx
import gleam/bool
import gleam/int
import gleam/io
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
    let assert Ok(#(start, nums)) = list.pop(nums, fn(_) { True })
    is_valid_equation(nums, goal, start)
  })
  |> list.map(pair.first)
  |> int.sum
}

type Operation {
  Sum
  Product
  Concat
}

fn is_valid_equation(nums: List(Int), goal: Int, agg: Int) -> Bool {
  use <- bool.guard(goal < agg, False)
  use <- bool.guard(list.is_empty(nums) && agg < goal, False)
  use <- bool.guard(list.is_empty(nums), True)

  [Sum, Product, Concat]
  |> list.any(fn(operation) {
    let assert Ok(#(head, nums)) = list.pop(nums, fn(_) { True })

    is_valid_equation(nums, goal, operate(operation, agg, head))
  })
}

fn operate(operation: Operation, a: Int, b: Int) {
  case operation {
    Sum -> a + b
    Product -> a * b
    Concat ->
      [a, b]
      |> list.map(int.to_string)
      |> string.concat()
      |> resultx.int_parse_unwrap
  }
}

pub fn pt_2(input: String) {
  parse(input) |> list.first
}
