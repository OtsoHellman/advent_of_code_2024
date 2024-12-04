import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  use nums <- result.try(
    input
    |> string.split("\n")
    |> list.map(int.parse)
    |> result.all(),
  )
  use n <- result.try(
    nums
    |> list.find(fn(n) {
      case nums |> list.find(fn(m) { n != m && n + m == 2020 }) {
        Ok(_) -> True
        Error(_) -> False
      }
    }),
  )
  n * { 2020 - n } |> Ok
}

pub fn pt_2(input: String) {
  use nums <- result.try(
    input
    |> string.split("\n")
    |> list.map(int.parse)
    |> result.all(),
  )

  use answer <- result.try(
    nums
    |> list.combinations(3)
    |> list.find(fn(c) { int.sum(c) == 2020 }),
  )

  answer |> int.product |> Ok
}
