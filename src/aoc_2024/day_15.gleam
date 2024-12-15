import aoc_2024/lib/grid
import aoc_2024/utils/resultx
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn parse(input: String) -> Instructions {
  let direction_arrows =
    dict.from_list([
      #("^", grid.Up),
      #(">", grid.Right),
      #("v", grid.Down),
      #("<", grid.Left),
    ])

  let assert [grid_input, moves_input] = input |> string.split("\n\n")

  let grid = grid_input |> grid.parse_input_to_string_grid
  let moves =
    moves_input
    |> string.replace("\n", "")
    |> string.split("")
    |> list.map(dict.get(direction_arrows, _))
    |> list.map(resultx.assert_unwrap)

  Instructions(grid, moves)
}

pub type Instructions {
  Instructions(grid: grid.Grid(String), moves: List(grid.Direction))
}

pub fn pt_1(instructions: Instructions) {
  instructions |> steps |> get_score
}

fn get_score(grid: grid.Grid(String)) {
  grid |> grid.print
  let #(_, rows) = grid |> grid.length |> io.debug

  grid.find_all_by(grid, fn(x) { x == "O" })
  |> list.map(fn(coord) { #(coord.0, rows - 1 - coord.1) })
  |> list.map(fn(coord) { coord.0 + { 100 * coord.1 } })
  |> int.sum
}

fn steps(instructions: Instructions) {
  use grid, direction <- list.fold(instructions.moves, instructions.grid)
  let starting_coord = grid |> grid.find("@") |> resultx.assert_unwrap

  step(grid, starting_coord, direction)
}

fn step(
  grid: grid.Grid(String),
  coord: grid.Coord,
  direction: grid.Direction,
) -> grid.Grid(String) {
  let current_node = grid.at(grid, coord) |> resultx.assert_unwrap

  let next_coord = grid.move(coord, direction)
  let next_node = grid.at(grid, next_coord) |> resultx.assert_unwrap

  case next_node {
    "#" -> grid
    "." ->
      grid
      |> grid.assert_set(next_coord, current_node)
      |> grid.assert_set(coord, ".")
    "O" -> {
      let next_grid = step(grid, next_coord, direction)
      let next_node = grid.at(next_grid, next_coord) |> resultx.assert_unwrap

      case next_node {
        "O" -> grid
        "." ->
          next_grid
          |> grid.assert_set(next_coord, current_node)
          |> grid.assert_set(coord, ".")
        _ -> panic
      }
    }
    x -> {
      x |> io.debug
      panic
    }
  }
}

pub fn pt_2(_instructions: Instructions) {
  1
}
