import aoc_2024/utils/resultx
import carpenter/table
import gleam/list
import gleam/pair
import gleam/result

pub type Cache(k, v) =
  table.Set(k, v)

pub fn create_named(name: String) {
  let assert Ok(table) =
    table.build(name)
    |> table.privacy(table.Public)
    |> table.write_concurrency(table.AutoWriteConcurrency)
    |> table.read_concurrency(True)
    |> table.decentralized_counters(True)
    |> table.compression(False)
    |> table.set

  table
}

pub fn create() {
  create_named("aoc_cache")
}

fn get_cache() {
  table.ref("aoc_cache")
}

pub fn drop() {
  get_cache() |> result.map(table.drop)
}

pub fn get(table: table.Set(k, v), key: k) {
  table
  |> table.lookup(key)
  |> list.first
  |> result.map(pair.second)
}

pub fn set(table: table.Set(k, v), key: k, value: v) {
  table |> table.insert([#(key, value)])
}

pub fn memoize(table: table.Set(k, v), key: k, fun: fn() -> v) {
  case table |> get(key) {
    Ok(value) -> value
    Error(_) -> {
      let value = fun()
      table |> set(key, value)
      value
    }
  }
}

pub fn memoize_named(table_name: String, key: k, fun: fn() -> v) {
  let table = table.ref(table_name) |> resultx.assert_unwrap

  case table |> get(key) {
    Ok(value) -> value
    Error(_) -> {
      let value = fun()
      table |> set(key, value)
      value
    }
  }
}

pub fn try_memo(key: k, fun: fn() -> v) {
  case get_cache() {
    Ok(cache) -> memoize(cache, key, fun)
    Error(_) -> fun()
  }
}
