import aoc_2024/utils/dictx
import aoc_2024/utils/intx
import aoc_2024/utils/resultx
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/string

fn parse_input(input: String) {
  input |> string.split("\n") |> list.map(resultx.int_parse_unwrap)
}

pub fn pt_1(input: String) {
  let numbers = parse_input(input)
  numbers |> list.map(generate_1) |> int.sum
}

fn process(number: Int) {
  let number =
    int.bitwise_shift_left(number, 6)
    |> mix(number)
    |> prune()

  let number =
    int.bitwise_shift_right(number, 5)
    |> mix(number)
    |> prune()

  let number =
    int.bitwise_shift_left(number, 11)
    |> mix(number)
    |> prune()

  number
}

fn mix(value: Int, secret: Int) {
  int.bitwise_exclusive_or(value, secret)
}

fn prune(number: Int) {
  int.modulo(number, 16_777_216) |> resultx.assert_unwrap
}

fn generate_1(number: Int) {
  use number, _ <- list.fold(list.range(1, 2000), number)
  process(number)
}

fn ones_digit(number: Int) {
  number |> intx.digits_assert() |> list.last |> resultx.assert_unwrap
}

fn generate(number: Int) -> #(List(Price), dict.Dict(Change, Int)) {
  let prices = [Price(number, ones_digit(number), [])]
  let change_dict = dict.new()
  use #(prices, change_dict), _ <- list.fold(list.range(1, n), #(
    prices,
    change_dict,
  ))

  let assert [Price(hash, price, changes), ..] = prices
  let hash = process(hash)
  let new_price = ones_digit(hash)
  let change = new_price - price
  let changes = get_changes(changes, change)

  let prices = [Price(hash, new_price, changes), ..prices]
  let change_dict = case
    dict.has_key(change_dict, changes) || list.length(changes) < 4
  {
    True -> change_dict
    False -> change_dict |> dict.insert(changes, new_price)
  }

  #(prices, change_dict)
}

fn get_changes(changes: Change, change: Int) {
  case changes {
    [] | [_] | [_, _] | [_, _, _] -> [change, ..changes]
    [a, b, c, _d] -> [change, a, b, c]
    _ -> panic
  }
}

type Price {
  Price(hash: Int, price: Int, changes: Change)
}

type Change =
  List(Int)

pub fn pt_2(input: String) {
  let numbers = parse_input(input)
  let change_lists =
    numbers
    |> list.map(fn(number) {
      generate(number)
      |> pair.second
      |> dict.to_list
    })

  get_change_sums(change_lists)
  |> dictx.max_by(fn(x) { x })
}

fn get_change_sums(
  change_lists: List(List(#(Change, Int))),
) -> dict.Dict(Change, Int) {
  let sum = dict.new()

  use sum, change_list <- list.fold(change_lists, sum)
  use sum, #(changes, price) <- list.fold(change_list, sum)
  use existing_value <- dict.upsert(sum, changes)
  case existing_value {
    option.Some(value) -> value + price
    option.None -> price
  }
}

const n = 2000
