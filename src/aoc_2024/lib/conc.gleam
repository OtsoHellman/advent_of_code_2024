import gleam/list
import gleam/otp/task

pub fn map(list: List(a), fun: fn(a) -> v) -> List(v) {
  list
  |> list.map(fn(item) { task.async(fn() { fun(item) }) })
  |> list.map(task.await_forever)
}

pub fn map_timeout(list: List(a), fun: fn(a) -> v, timeout: Int) -> List(v) {
  list
  |> list.map(fn(item) { task.async(fn() { fun(item) }) })
  |> list.map(task.await(_, timeout))
}

pub fn each_timeout(list: List(a), fun: fn(a) -> v, timeout: Int) -> Nil {
  list
  |> list.map(fn(item) { task.async(fn() { fun(item) }) })
  |> list.each(task.await(_, timeout))
}
