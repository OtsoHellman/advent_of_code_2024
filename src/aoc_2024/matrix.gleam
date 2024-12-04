import aoc_2024/utils
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import glearray

pub type Matrix(t) =
  glearray.Array(glearray.Array(t))

pub type Coord =
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

pub fn move(coord1: Coord, coord2: Coord) -> Coord {
  let #(row1, col1) = coord1
  let #(row2, col2) = coord2
  #(row2 + row1, col2 + col1)
}
