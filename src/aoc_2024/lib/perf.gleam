import birl
import gleam/int
import gleam/io

pub fn start(name: String) {
  let start = birl.now() |> birl.to_unix_milli
  { "\nstarting " <> name } |> io.println

  let name = case name {
    "" -> ""
    name -> name <> " finished in "
  }

  let stop = fn() {
    let end = birl.now() |> birl.to_unix_milli
    { name <> int.to_string(end - start) <> "ms" } |> io.println
  }

  stop
}

pub fn measure(name: String, fun: fn() -> a) {
  let stop = start(name)
  let value = fun()
  stop()
  value
}
