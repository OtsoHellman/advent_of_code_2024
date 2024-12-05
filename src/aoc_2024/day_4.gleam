import aoc_2024/grid
import aoc_2024/utils
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  input |> grid.parse_input_to_string_grid |> solve_1
}

fn solve_1(input_grid: grid.Grid(String)) {
  input_grid
  |> grid.get_coords
  |> list.map(solve_coord_1(input_grid, _))
  |> int.sum
}

fn solve_coord_1(input_grid: grid.Grid(String), coord: grid.Coord) -> Int {
  let word = "XMAS"

  grid.get_directions(grid.All)
  |> list.map(solve_coord_direction(input_grid, coord, _, 0, word))
  |> list.count(fn(b) { b })
}

fn solve_coord_direction(
  input_grid: grid.Grid(String),
  location: grid.Coord,
  direction: grid.Direction,
  word_index: Int,
  word: String,
) {
  let expected_char = word |> string.slice(word_index, 1)
  let char = input_grid |> grid.at(location)

  use <- bool.guard(expected_char == "", True)
  use <- bool.guard(result.is_error(char), False)
  case { char |> utils.assert_unwrap } == expected_char {
    True ->
      solve_coord_direction(
        input_grid,
        location |> grid.move(direction),
        direction,
        word_index + 1,
        word,
      )
    False -> False
  }
}

pub fn pt_2(input: String) {
  input |> grid.parse_input_to_string_grid |> solve_2
}

fn solve_2(input_grid: grid.Grid(String)) {
  input_grid
  |> grid.get_coords
  |> list.map(solve_coord_2(input_grid, _))
  |> list.count(fn(b) { b })
}

fn solve_coord_2(input_grid: grid.Grid(String), coord: grid.Coord) -> Bool {
  let word = "MAS"

  grid.get_directions(grid.Diagonal)
  |> list.map(fn(direction) {
    solve_coord_direction(
      input_grid,
      coord |> grid.move(direction),
      direction |> grid.opposite_direction,
      0,
      word,
    )
  })
  |> list.count(fn(b) { b })
  |> fn(val) { val >= 2 }
}
