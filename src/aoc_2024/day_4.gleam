import aoc_2024/matrix
import aoc_2024/utils
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  input |> matrix.parse_input_to_string_matrix |> solve_1
}

fn solve_1(input_matrix: matrix.Matrix(String)) {
  input_matrix
  |> matrix.get_coords
  |> list.map(fn(coord) { solve_coord_1(input_matrix, coord) })
  |> int.sum
}

fn solve_coord_1(
  input_matrix: matrix.Matrix(String),
  coord: matrix.Coord,
) -> Int {
  let directions = [
    #(1, 0),
    #(1, 1),
    #(0, 1),
    #(-1, 1),
    #(-1, 0),
    #(-1, -1),
    #(0, -1),
    #(1, -1),
  ]

  let word = "XMAS"

  directions
  |> list.map(fn(direction) {
    solve_coord_direction(input_matrix, coord, direction, 0, word)
  })
  |> list.count(fn(bool) { bool })
}

fn solve_coord_direction(
  input_matrix: matrix.Matrix(String),
  location: matrix.Coord,
  direction: matrix.Coord,
  word_index: Int,
  word: String,
) {
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
        word,
      )
    False -> False
  }
}

pub fn pt_2(input: String) {
  input |> matrix.parse_input_to_string_matrix |> solve_2
}

fn solve_2(input_matrix: matrix.Matrix(String)) {
  input_matrix
  |> matrix.get_coords
  |> list.map(fn(coord) { solve_coord_2(input_matrix, coord) })
  |> list.count(fn(bool) { bool })
}

fn solve_coord_2(
  input_matrix: matrix.Matrix(String),
  coord: matrix.Coord,
) -> Bool {
  let directions = [#(1, 1), #(-1, 1), #(-1, -1), #(1, -1)]
  let word = "MAS"

  directions
  |> list.map(fn(direction) {
    solve_coord_direction(
      input_matrix,
      coord |> matrix.move(direction),
      direction |> matrix.opposite_direction,
      0,
      word,
    )
  })
  |> list.count(fn(bool) { bool })
  |> fn(val) { val >= 2 }
}
