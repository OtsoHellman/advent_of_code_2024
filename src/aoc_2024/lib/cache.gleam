import carpenter/table
import gleam/list
import gleam/pair
import gleam/result

pub fn create() {
  let assert Ok(table) =
    table.build("table")
    |> table.privacy(table.Public)
    |> table.write_concurrency(table.AutoWriteConcurrency)
    |> table.read_concurrency(True)
    |> table.decentralized_counters(True)
    |> table.compression(False)
    |> table.set

  table
}

pub fn get(table: table.Set(k, v), key: k) {
  table |> table.lookup(key) |> list.first |> result.map(pair.second)
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
