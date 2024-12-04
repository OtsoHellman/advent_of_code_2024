import aoc_2024/utils
import gleam/list
import gleam/result
import gleam/string
import glearray

pub type Matrix(t) =
  glearray.Array(glearray.Array(t))

pub type Coord =
  #(Int, Int)

// should be typed as literal but idk how [#(1, 0), #(1, 1), #(0, 1), #(-1, 1), #(-1, 0), #(-1, -1), #(0, -1), #(1, -1)]
pub type Direction =
  #(Int, Int)

pub fn parse_input_to_string_matrix(input: String) -> Matrix(String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) { line |> string.split("") |> glearray.from_list })
  |> glearray.from_list
}

pub fn at(matrix: Matrix(t), coord: Coord) -> Result(t, Nil) {
  let #(row, col) = coord
  matrix |> glearray.get(row) |> result.try(glearray.get(_, col))
}

fn length(matrix: Matrix(t)) -> #(Int, Int) {
  let rows = matrix |> glearray.length
  let cols = matrix |> glearray.get(0) |> utils.assert_unwrap |> glearray.length
  #(rows, cols)
}

pub fn get_coords(matrix: Matrix(t)) -> List(Coord) {
  //-> List(Coord) {
  let #(rows, cols) = matrix |> length

  list.range(0, rows - 1)
  |> list.flat_map(fn(row) {
    list.range(0, cols - 1)
    |> list.map(fn(col) { #(row, col) })
  })
}

pub fn move(coord: Coord, direction: Direction) -> Coord {
  let #(row, col) = coord
  let #(x, y) = direction
  #(row + x, col + y)
}

pub fn opposite_direction(direction: Direction) -> Direction {
  let #(x, y) = direction
  #(-x, -y)
}

pub type DirectionOpts {
  Orthogonal
  Diagonal
  All
}

pub fn get_directions(opts: DirectionOpts) {
  let orthogonal = [#(1, 0), #(0, 1), #(-1, 0), #(0, -1)]
  let diagonal = [#(1, 1), #(-1, 1), #(-1, -1), #(1, -1)]

  case opts {
    Orthogonal -> orthogonal
    Diagonal -> diagonal
    All -> list.flatten([orthogonal, diagonal])
  }
}
