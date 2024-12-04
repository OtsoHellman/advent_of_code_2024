import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/string

pub fn pt_1(input: String) {
  let assert Ok(re) = regex.from_string("mul\\([0-9]+,[0-9]+\\)")
  let assert Ok(number_re) = regex.from_string("[0-9]+")
  let muls = regex.scan(re, input) |> list.map(fn(match) { match.content })
  let numbers =
    muls
    |> list.map(fn(mul) {
      regex.scan(number_re, mul)
      |> list.map(fn(match) { match.content })
    })
  numbers
  |> list.map(fn(pair) {
    pair |> list.map(int.parse) |> list.map(assert_unwrap)
  })
  |> list.map(fn(pair) { pair |> int.product })
  |> int.sum
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

pub fn assert_unwrap(result: Result(t, _)) -> t {
  case result {
    Ok(value) -> value
    _ -> panic
  }
}
