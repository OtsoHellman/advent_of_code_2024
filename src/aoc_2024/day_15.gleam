import aoc_2024/lib/grid
import aoc_2024/utils/resultx
import gleam/dict
import gleam/int
import gleam/list
import gleam/string

pub type Instructions {
  Instructions(grid: grid.Grid(String), moves: List(grid.Direction))
}

pub fn pt_1(input: String) {
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

  let instructions = Instructions(grid, moves)

  instructions |> steps_1 |> get_score_1
}

fn get_score_1(grid: grid.Grid(String)) {
  let #(_, rows) = grid |> grid.length
  grid.find_all_by(grid, fn(x) { x == "O" })
  |> list.map(fn(coord) { #(coord.0, rows - 1 - coord.1) })
  |> list.map(fn(coord) { coord.0 + { 100 * coord.1 } })
  |> int.sum
}

fn steps_1(instructions: Instructions) {
  use grid, direction <- list.fold(instructions.moves, instructions.grid)
  let starting_coord = grid |> grid.find("@") |> resultx.assert_unwrap

  step_1(grid, starting_coord, direction)
}

fn step_1(
  grid: grid.Grid(String),
  coord: grid.Coord,
  direction: grid.Direction,
) -> grid.Grid(String) {
  let current_node = grid.at_assert(grid, coord)

  let next_coord = grid.move(coord, direction)
  let next_node = grid.at_assert(grid, next_coord)

  case next_node {
    "#" -> grid
    "." ->
      grid
      |> grid.assert_set(next_coord, current_node)
      |> grid.assert_set(coord, ".")
    "O" -> {
      let next_grid = step_1(grid, next_coord, direction)
      let next_node = grid.at_assert(next_grid, next_coord)

      case next_node {
        "O" -> grid
        "." ->
          next_grid
          |> grid.assert_set(next_coord, current_node)
          |> grid.assert_set(coord, ".")
        _ -> panic
      }
    }
    _ -> panic
  }
}

pub fn pt_2(input: String) {
  let direction_arrows =
    dict.from_list([
      #("^", grid.Up),
      #(">", grid.Right),
      #("v", grid.Down),
      #("<", grid.Left),
    ])

  let assert [grid_input, moves_input] = input |> string.split("\n\n")

  let grid =
    grid_input
    |> string.replace("#", "##")
    |> string.replace("O", "[]")
    |> string.replace(".", "..")
    |> string.replace("@", "@.")
    |> grid.parse_input_to_string_grid
  let moves =
    moves_input
    |> string.replace("\n", "")
    |> string.split("")
    |> list.map(dict.get(direction_arrows, _))
    |> list.map(resultx.assert_unwrap)

  let instructions = Instructions(grid, moves)

  instructions
  |> steps
  |> get_score
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
  let current_node = grid.at_assert(grid, coord)

  let next_coord = grid.move(coord, direction)
  let next_node = grid.at_assert(grid, next_coord)

  case next_node {
    "#" -> grid
    "." ->
      grid
      |> grid.assert_set(next_coord, current_node)
      |> grid.assert_set(coord, ".")
    "[" | "]" -> {
      case direction {
        grid.Left | grid.Right -> {
          let next_grid = step(grid, next_coord, direction)
          let next_node = grid.at_assert(next_grid, next_coord)
          case next_node {
            "." ->
              next_grid
              |> grid.assert_set(next_coord, current_node)
              |> grid.assert_set(coord, ".")
            _ -> grid
          }
        }
        grid.Up | grid.Down -> {
          let pair_coord = case next_node {
            "[" -> #(next_coord.0 + 1, next_coord.1)
            "]" -> #(next_coord.0 - 1, next_coord.1)
            _ -> panic
          }

          let next_grid =
            grid
            |> step(next_coord, direction)
            |> step(pair_coord, direction)

          let next_node = grid.at_assert(next_grid, next_coord)
          let pair_node = grid.at_assert(next_grid, pair_coord)

          case next_node, pair_node {
            ".", "." ->
              next_grid
              |> grid.assert_set(pair_coord, ".")
              |> grid.assert_set(next_coord, current_node)
              |> grid.assert_set(coord, ".")

            _, _ -> grid
          }
        }
        _ -> panic
      }
    }
    _ -> panic
  }
}

fn get_score(grid: grid.Grid(String)) {
  let #(_, rows) = grid |> grid.length
  grid.find_all_by(grid, fn(x) { x == "[" })
  |> list.map(fn(coord) { #(coord.0, rows - 1 - coord.1) })
  |> list.map(fn(coord) { coord.0 + { 100 * coord.1 } })
  |> int.sum
}
