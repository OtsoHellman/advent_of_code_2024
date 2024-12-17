import aoc_2024/lib/grid
import aoc_2024/utils/regexpx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import glearray

fn parse_1(input: String) {
  let assert [registers_string, program_string] = input |> string.split("\n\n")

  Computer(
    parse_registers(registers_string),
    parse_program(program_string),
    0,
    [],
  )
}

fn parse_registers(input: String) {
  let assert [a, b, c] = input |> regexpx.get_positive_ints

  Registers(a, b, c)
}

fn parse_program(input: String) {
  input
  |> regexpx.get_positive_ints
  |> list.sized_chunk(2)
  |> list.map(fn(x) {
    let assert [opcode, operand] = x

    Operation(opcode, operand)
  })
  |> glearray.from_list
}

pub type Computer {
  Computer(
    registers: Registers,
    program: Program,
    pointer: Int,
    output: List(Int),
  )
}

pub type Registers {
  Registers(a: Int, b: Int, c: Int)
}

pub type Program =
  glearray.Array(Operation)

pub type Operation {
  Operation(opcode: Int, operand: Int)
}

pub fn pt_1(input: String) {
  let computer = parse_1(input)

  compute(computer)
}

pub fn compute(computer: Computer) {
  let current_pointer = computer.pointer |> io.debug
  let next_operation = computer.program |> glearray.get(current_pointer / 2)

  case next_operation {
    Error(_) ->
      computer.output
      |> list.reverse
      |> list.map(int.to_string)
      |> string.join(",")

    Ok(operation) -> {
      let new_computer = run_operation(computer, operation)
      case new_computer.pointer == current_pointer {
        True -> {
          let pointer = current_pointer + 2
          compute(Computer(..new_computer, pointer:))
        }
        False -> compute(new_computer)
      }
    }
  }
}

pub fn run_operation(computer: Computer, operation: Operation) {
  let Operation(opcode, operand) = operation

  case opcode {
    0 -> opcode_0(computer, operand)
    1 -> opcode_1(computer, operand)
    2 -> opcode_2(computer, operand)
    3 -> opcode_3(computer, operand)
    4 -> opcode_4(computer, operand)
    5 -> opcode_5(computer, operand)
    6 -> opcode_6(computer, operand)
    7 -> opcode_7(computer, operand)
    _ -> panic
  }
}

pub fn adv(computer: Computer, operand: Int) {
  let operand = combo_operand(computer, operand)
  let numerator = computer.registers.a
  let denominator =
    int.power(2, int.to_float(operand)) |> resultx.assert_unwrap |> float.round

  numerator / denominator
}

pub fn opcode_0(computer: Computer, operand: Int) {
  let result = adv(computer, operand)

  let registers = Registers(result, computer.registers.b, computer.registers.c)

  Computer(..computer, registers:)
}

pub fn opcode_1(computer: Computer, operand: Int) {
  let result = int.bitwise_exclusive_or(computer.registers.b, operand)

  let registers = Registers(computer.registers.a, result, computer.registers.c)

  Computer(..computer, registers:)
}

pub fn opcode_2(computer: Computer, operand: Int) {
  let result = combo_operand(computer, operand)

  let registers =
    Registers(computer.registers.a, result % 8, computer.registers.c)

  Computer(..computer, registers:)
}

pub fn opcode_3(computer: Computer, operand: Int) {
  use <- bool.guard(computer.registers.a == 0, computer)

  let pointer = operand
  Computer(..computer, pointer:)
}

pub fn opcode_4(computer: Computer, _operand: Int) {
  let result =
    int.bitwise_exclusive_or(computer.registers.b, computer.registers.c)

  let registers = Registers(computer.registers.a, result, computer.registers.c)

  Computer(..computer, registers:)
}

pub fn opcode_5(computer: Computer, operand: Int) {
  let operand = combo_operand(computer, operand)
  let output = [operand % 8, ..computer.output]

  Computer(..computer, output:)
}

pub fn opcode_6(computer: Computer, operand: Int) {
  let result = adv(computer, operand)

  let registers = Registers(computer.registers.a, result, computer.registers.c)

  Computer(..computer, registers:)
}

pub fn opcode_7(computer: Computer, operand: Int) {
  let result = adv(computer, operand)

  let registers = Registers(computer.registers.a, computer.registers.b, result)

  Computer(..computer, registers:)
}

pub fn combo_operand(computer: Computer, operand: Int) {
  case operand {
    x if 0 <= x && x <= 3 -> x
    4 -> computer.registers.a
    5 -> computer.registers.b
    6 -> computer.registers.c
    7 -> panic
    _ -> panic
  }
}

pub fn pt_2(_input: String) {
  1
}
