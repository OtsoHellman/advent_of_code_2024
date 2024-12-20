import aoc_2024/lib/algos
import aoc_2024/lib/grid
import aoc_2024/utils/resultx
import gleam/bool
import gleam/list
import gleam/pair

fn parse_input(input: String) {
  input |> grid.parse_input_to_string_grid
}

pub fn pt_1(input: String) {
  let grid = parse_input(input)

  let start = grid |> grid.find("S") |> resultx.assert_unwrap
  let end = grid |> grid.find("E") |> resultx.assert_unwrap

  let time = get_time(grid, start, end)
  grid.get_coords(grid)
  |> list.map(fn(coord) {
    let grid = grid.copy_set(grid, coord, ".") |> resultx.assert_unwrap

    get_time(grid, start, end)
  })
  |> list.filter(fn(i) { saved_steps <= time - i })
  |> list.length
}

fn get_time(grid, start, end) {
  algos.bfs(start, fn(coord) { coord == end }, fn(coord) {
    get_neighbors(grid, coord)
  })
  |> list.first
  |> resultx.assert_unwrap
  |> pair.second
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

const saved_steps = 100

const skips = 20

pub fn pt_2(input: String) {
  let grid = parse_input(input)

  let start = grid |> grid.find("S") |> resultx.assert_unwrap
  let end = grid |> grid.find("E") |> resultx.assert_unwrap

  let path =
    algos.bfs(start, fn(coord) { coord == end }, fn(coord) {
      get_neighbors(grid, coord)
    })
    |> list.map(fn(x) {
      let #(coord, score) = x

      Step(coord:, score:)
    })

  path
  |> list.combination_pairs
  |> list.filter(get_saved_time)
  |> list.length
}

type Step {
  Step(coord: grid.Coord, score: Int)
}

fn get_saved_time(pair: #(Step, Step)) {
  let #(left, right) = pair

  let score_diff = left.score - right.score

  let manhattan_distance = grid.get_manhattan_distance(left.coord, right.coord)

  case manhattan_distance < skips + 1 {
    True -> saved_steps <= score_diff - manhattan_distance
    False -> False
  }
}
