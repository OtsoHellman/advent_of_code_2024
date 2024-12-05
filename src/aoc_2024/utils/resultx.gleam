import gleam/int

pub fn assert_unwrap(result: Result(t, _)) -> t {
  case result {
    Ok(value) -> value
    _ -> panic
  }
}

pub fn int_parse_unwrap(input: String) -> Int {
  case int.parse(input) {
    Ok(value) -> value
    _ -> panic
  }
}
