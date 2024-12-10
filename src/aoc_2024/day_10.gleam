import aoc_2024/lib/grid
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/pair

pub fn parse(input: String) {
  input |> grid.parse_input_to_int_grid
}

type Grid =
  grid.Grid(Int)

type Coord =
  grid.Coord

type TrailHead =
  grid.Coord

pub fn pt_1(grid: Grid) {
  let trailheads =
    grid
    |> grid.find_all_by(fn(x) { x == 0 })

  trailheads
  |> list.map(get_trailhead_score(grid, _))
  |> int.sum
}

fn get_trailhead_score(grid: Grid, trailhead: TrailHead) {
  get_trailhead_tops(grid, trailhead)
  |> list.unique
  |> list.length
}

fn get_trailhead_tops(grid: Grid, trailhead: TrailHead) -> List(Coord) {
  let trailhead_height = grid.at_assert(grid, trailhead)

  use <- bool.guard(9 <= trailhead_height, [trailhead])

  let valid_neighbors =
    grid
    |> grid.get_neighbors(trailhead, grid.Orthogonal)
    |> list.map(pair.first)
    |> list.map(fn(coord) { #(coord, grid.at_assert(grid, coord)) })
    |> list.filter(fn(x) { x.1 == { trailhead_height + 1 } })

  valid_neighbors
  |> list.flat_map(fn(x) { get_trailhead_tops(grid, x.0) })
}

pub fn pt_2(input: Grid) {
  input |> grid.at_assert(#(0, 0))
}
