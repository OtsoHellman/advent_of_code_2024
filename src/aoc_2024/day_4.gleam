import aoc_2024/matrix
import aoc_2024/utils
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

const directions = [
  #(1, 0), #(1, 1), #(0, 1), #(-1, 1), #(-1, 0), #(-1, -1), #(0, -1), #(1, -1),
]

pub fn pt_1(input: String) {
  input |> matrix.parse_input_to_string_matrix |> solve_1
}

fn solve_1(input_matrix: matrix.Matrix(String)) {
  input_matrix
  |> matrix.get_coords
  |> list.map(fn(coord) { solve_coord(input_matrix, coord) })
  |> int.sum
}

fn solve_coord(input_matrix: matrix.Matrix(String), coord: matrix.Coord) -> Int {
  directions
  |> list.map(fn(direction) {
    solve_coord_direction(input_matrix, coord, direction, 0)
  })
  |> list.count(fn(bool) { bool })
}

fn solve_coord_direction(
  input_matrix: matrix.Matrix(String),
  location: matrix.Coord,
  direction: matrix.Coord,
  word_index: Int,
) {
  let word = "XMAS"

  let expected_char = word |> string.slice(word_index, 1)
  let char = input_matrix |> matrix.at(location)
  use <- bool.guard(expected_char == "", True)
  use <- bool.guard(result.is_error(char), False)

  case { char |> utils.assert_unwrap } == expected_char {
    True ->
      solve_coord_direction(
        input_matrix,
        location |> matrix.move(direction),
        direction,
        word_index + 1,
      )
    False -> False
  }
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
