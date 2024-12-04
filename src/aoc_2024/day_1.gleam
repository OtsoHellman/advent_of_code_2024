import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  case solve_1(input) {
    Ok(result) -> result
    Error(_) -> 0
  }
}

fn solve_1(input: String) -> Result(Int, Nil) {
  use int_pairs <- result.try(
    input
    |> string.split("\n")
    |> list.map(string.split(_, "   "))
    |> list.map(parse_string_pair_to_tuples)
    |> result.all(),
  )

  let #(list1, list2) = int_pairs |> list.unzip
  let sorted_list1 = list1 |> list.sort(int.compare)
  let sorted_list2 = list2 |> list.sort(int.compare)

  let zipped = list.zip(sorted_list1, sorted_list2)

  zipped
  |> list.map(fn(pair) {
    let #(first, second) = pair
    first - second |> int.absolute_value
  })
  |> int.sum
  |> Ok
}

fn parse_string_pair_to_tuples(pair: List(String)) {
  use int_pair <- result.try(
    pair
    |> list.map(int.parse)
    |> result.all,
  )
  case int_pair {
    [first, second] -> Ok(#(first, second))
    _ -> Error(Nil)
  }
}

pub fn pt_2(input: String) {
  todo
}
