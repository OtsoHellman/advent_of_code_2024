import aoc_2024/lib/algos
import aoc_2024/lib/grid
import aoc_2024/utils/resultx
import gleam/bool
import gleam/list
import gleam/set
import gleam/string

const x = 71

const y = 71

fn parse_input(input: String) {
  input
  |> parse_bytes
  |> parse_grid
}

fn parse_bytes(input: String) {
  let n = 2911

  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(",") |> list.map(resultx.int_parse_unwrap)
  })
  |> list.map(fn(line) {
    let assert [x, y] = line
    #(x, y)
  })
  |> list.take(n)
  |> set.from_list
}

fn parse_grid(bytes: set.Set(grid.Coord)) {
  let grid = grid.new(#(x, y))

  grid
  |> grid.map_with_coord(fn(coord) {
    case set.contains(bytes, coord) {
      True -> Ok("#")
      False -> Error(Nil)
    }
  })
}

pub fn pt_1(input: String) {
  let grid = input |> parse_input

  algos.bfs(#(0, 0), fn(coord) { coord == #(x - 1, y - 1) }, fn(coord) {
    get_neighbors(grid, coord)
  })
  |> list.first
}

fn get_neighbors(grid: grid.Grid(String), current_coord: grid.Coord) {
  grid
  |> grid.get_neighbors(current_coord, grid.Orthogonal)
  |> list.filter(fn(neighbor) {
    let #(coord, _) = neighbor
    let neighbor_value = grid.at_assert(grid, coord)

    use <- bool.guard(neighbor_value == "#", False)

    True
  })
  |> list.map(fn(neighbor) {
    let #(coord, _) = neighbor
    coord
  })
}

pub fn pt_2(_input: String) {
  1
}
