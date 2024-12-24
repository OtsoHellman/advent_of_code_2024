import aoc_2024/lib/perf
import aoc_2024/utils/resultx
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set
import gleam/string

pub type Bit {
  Bit(name: String, value: Bool)
}

pub type Operation {
  Operation(left: String, right: String, target: String, gate: String)
}

fn parse_input(input: String) {
  let assert [a, b] = input |> string.split("\n\n")

  let bits =
    a
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [a, b] = line |> string.split(": ")

      let value = case b {
        "0" -> False
        "1" -> True
        _ -> panic
      }
      #(a, value)
    })
    |> dict.from_list

  let operations =
    b
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [left, gate, right, _, target] = line |> string.split(" ")
      Operation(left:, right:, target:, gate:)
    })

  #(bits, operations)
}

pub fn pt_1(input: String) {
  use <- perf.measure("pt1")

  let #(bits, operations) = parse_input(input)

  let all_bits =
    operations
    |> list.flat_map(fn(operation) {
      [operation.left, operation.right, operation.target]
    })
    |> list.unique
    |> list.length

  let swaps = ["x08", "x14", "x18", "x23"] |> set.from_list

  let bits = solve(bits, operations, all_bits)
  parse_num(bits, "z")
  // |> int.base_parse(2)
}

fn solve(
  bits: dict.Dict(String, Bool),
  operations: List(Operation),
  all_bits: Int,
) {
  let bits = {
    use bits, operation <- list.fold(operations, bits)

    case bits |> dict.has_key(operation.target) {
      True -> bits
      False -> {
        let left = bits |> dict.get(operation.left)
        let right = bits |> dict.get(operation.right)

        case left, right {
          Ok(left), Ok(right) -> {
            let value = get_operation(operation)(left, right)

            bits |> dict.insert(operation.target, value)
          }
          _, _ -> bits
        }
      }
    }
  }

  case bits |> dict.size < all_bits {
    False -> bits
    True -> solve(bits, operations, all_bits)
  }
}

fn get_operation(operation: Operation) {
  case operation.gate {
    "AND" -> bool.and
    "OR" -> bool.or
    "XOR" -> bool.exclusive_or
    _ -> panic
  }
}

fn parse_num(bits: dict.Dict(String, Bool), prefix: String) {
  bits
  |> dict.to_list
  |> list.filter(fn(bit) { bit.0 |> string.starts_with(prefix) })
  |> list.sort(fn(a, b) { string.compare(b.0, a.0) })
  |> list.map(fn(bit) {
    case bit.1 {
      True -> "1"
      False -> "0"
    }
  })
  |> string.join("")
}

pub fn pt_2(input: String) {
  let #(bits, operations) = parse_input(input)

  let x = { "0" <> parse_num(bits, "x") } |> io.debug
  let y = { "0" <> parse_num(bits, "y") } |> io.debug

  let all_bits =
    operations
    |> list.flat_map(fn(operation) {
      [operation.left, operation.right, operation.target]
    })
    |> list.unique
    |> list.length

  solve(bits, operations, all_bits)
  |> parse_num("z")
  |> io.debug

  let goal =
    {
      int.base_parse(x, 2)
      |> resultx.assert_unwrap
    }
    + {
      int.base_parse(y, 2)
      |> resultx.assert_unwrap
    }
    |> int.to_base2
    |> io.debug
}
