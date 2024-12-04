import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.all()
  })
  |> result.all()
}

pub fn pt_1(input: String) {
  use reports <- result.try(parse_input(input))

  reports |> list.filter(is_valid_report) |> list.length |> Ok
}

pub fn pt_2(input: String) {
  use reports <- result.try(parse_input(input))

  reports |> list.filter(is_valid_dampener_report) |> list.length |> Ok
}

fn is_valid_report(report: List(Int)) {
  use <- bool.guard(report |> is_sorted |> bool.negate, False)

  let zipped = report |> list.zip(report |> list.drop(1))

  zipped
  |> list.map(fn(pair) { int.absolute_value(pair.0 - pair.1) })
  |> list.all(fn(diff) { 1 <= diff && diff <= 3 })
}

fn is_sorted(report: List(Int)) {
  let sorted = report |> list.sort(int.compare)
  report == sorted || report == sorted |> list.reverse
}

fn is_valid_dampener_report(report: List(Int)) {
  report
  |> list.combinations(list.length(report) - 1)
  |> list.any(is_valid_report)
}
