import aoc_2024/utils/resultx
import gleam/int
import gleam/list
import gleam/string

fn parse_input(input: String) {
  let patterns = input |> string.split("\n\n")

  let locks = patterns |> list.filter(is_lock)
  let keys = patterns |> list.filter(fn(x) { !is_lock(x) })

  let locks =
    locks
    |> list.map(fn(pattern) {
      pattern
      |> string.split("\n")
      |> list.map(fn(line) { line |> string.split("") })
      |> list.transpose
      |> list.map(fn(line) { line |> list.count(fn(x) { x == "#" }) })
      |> list.map(int.subtract(_, 1))
    })

  let keys =
    keys
    |> list.map(fn(pattern) {
      pattern
      |> string.split("\n")
      |> list.map(fn(line) { line |> string.split("") })
      |> list.transpose
      |> list.map(fn(line) { line |> list.count(fn(x) { x == "#" }) })
      |> list.map(int.subtract(_, 1))
    })

  #(locks, keys)
}

fn is_lock(input: String) {
  input
  |> string.split("\n")
  |> list.first
  |> resultx.assert_unwrap
  |> string.contains("#")
}

pub fn pt_1(input: String) {
  let #(locks, keys) = parse_input(input)

  locks
  |> list.map(fn(lock) {
    keys
    |> list.count(fn(key) { key_fits(lock, key) })
  })
  |> int.sum
}

fn key_fits(lock: List(Int), key: List(Int)) {
  list.zip(lock, key)
  |> list.all(fn(x) {
    let #(lock, key) = x

    lock + key < 6
  })
}

pub fn pt_2(_input: String) {
  1
}
