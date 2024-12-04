import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  use reports <- result.try(
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.split(" ")
      |> list.map(int.parse)
      |> result.all()
    })
    |> result.all(),
  )

  reports |> list.filter(is_valid_level) |> list.length |> Ok
}

fn is_valid_level(level: List(Int)) {
  use <- bool.guard(level |> is_sorted |> bool.negate, False)

  let zipped = level |> list.zip(level |> list.drop(1))

  zipped
  |> list.map(fn(pair) { int.absolute_value(pair.0 - pair.1) })
  |> list.all(fn(diff) { 1 <= diff && diff <= 3 })
}

fn is_sorted(level: List(Int)) {
  let sorted = level |> list.sort(int.compare)
  level == sorted || level == sorted |> list.reverse
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
