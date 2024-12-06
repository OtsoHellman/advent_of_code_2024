import birl
import gleam/int
import gleam/io

pub fn start(name: String) {
  let start = birl.now() |> birl.to_unix_milli
  { "starting " <> name } |> io.debug

  let name = case name {
    "" -> ""
    name -> name <> " finished in "
  }

  let stop = fn() {
    let end = birl.now() |> birl.to_unix_milli
    { name <> int.to_string(end - start) <> "ms" } |> io.debug
  }

  stop
}
