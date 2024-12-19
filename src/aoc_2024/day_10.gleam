import aoc_2024/lib/grid
import gleam/bool
import gleam/int
import gleam/list
import gleam/pair
import gleam/set

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
  |> list.map(get_trailhead_tops(grid, _))
  |> list.map(set.size)
  |> int.sum
}

fn get_trailhead_tops(grid: Grid, trailhead: TrailHead) -> set.Set(Coord) {
  let trailhead_height = grid.at_assert(grid, trailhead)

  use <- bool.guard(9 <= trailhead_height, set.from_list([trailhead]))

  get_valid_neighbors(grid, trailhead)
  |> list.map(fn(x) { get_trailhead_tops(grid, x.0) })
  |> list.fold(set.new(), fn(a, b) { set.union(a, b) })
}

fn get_valid_neighbors(grid, trailhead) {
  let trailhead_height = grid.at_assert(grid, trailhead)

  grid
  |> grid.get_neighbors(trailhead, grid.Orthogonal)
  |> list.map(pair.first)
  |> list.map(fn(coord) { #(coord, grid.at_assert(grid, coord)) })
  |> list.filter(fn(x) { x.1 == { trailhead_height + 1 } })
}

pub fn pt_2(grid: Grid) {
  let trailheads =
    grid
    |> grid.find_all_by(fn(x) { x == 0 })

  trailheads
  |> list.map(get_distinct_trails(grid, _))
  |> int.sum
}

fn get_distinct_trails(grid: Grid, trailhead: TrailHead) {
  let trailhead_height = grid.at_assert(grid, trailhead)

  use <- bool.guard(9 <= trailhead_height, 1)

  get_valid_neighbors(grid, trailhead)
  |> list.map(fn(x) { get_distinct_trails(grid, x.0) })
  |> int.sum
}
