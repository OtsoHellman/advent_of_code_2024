import aoc_2024/lib/conc
import aoc_2024/lib/grid
import aoc_2024/lib/perf
import aoc_2024/utils/resultx
import gleam/bool
import gleam/dict
import gleam/list
import gleam/pair
import gleam/result
import gleam/set

pub fn pt_1(input: String) {
  let direction_arrows =
    dict.from_list([
      #("^", grid.Up),
      #(">", grid.Right),
      #("v", grid.Down),
      #("<", grid.Left),
    ])
  let grid = input |> grid.parse_input_to_string_grid
  let starting_coord =
    direction_arrows
    |> dict.keys()
    |> list.map(fn(arrow) { grid |> grid.find(arrow) })
    |> result.values
    |> list.first
    |> resultx.assert_unwrap

  let starting_direction =
    grid
    |> grid.at(starting_coord)
    |> result.try(dict.get(direction_arrows, _))
    |> resultx.assert_unwrap

  get_visited_coords(grid, starting_coord, starting_direction, set.new())
  |> resultx.assert_unwrap
  |> list.unique
  |> list.length
}

fn get_visited_coords(
  grid: grid.Grid(String),
  coord: grid.Coord,
  direction: grid.Direction,
  visited_positions: set.Set(#(grid.Coord, grid.Direction)),
) -> Result(List(grid.Coord), Nil) {
  let new_position = #(coord, direction)
  use <- bool.guard(
    visited_positions
      |> set.contains(new_position),
    Error(Nil),
  )

  let visited_positions = visited_positions |> set.insert(new_position)

  let next_coord = grid.move(coord, direction)
  case grid |> grid.at(next_coord) {
    Ok("#") ->
      get_visited_coords(
        grid,
        coord,
        direction |> grid.turn(grid.TurnRight),
        visited_positions,
      )
    Ok(_) -> get_visited_coords(grid, next_coord, direction, visited_positions)
    Error(_) -> visited_positions |> set.to_list |> list.map(pair.first) |> Ok
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
  let grid = input |> grid.parse_input_to_string_grid
  let starting_coord =
    direction_arrows
    |> dict.keys()
    |> list.map(fn(arrow) { grid |> grid.find(arrow) })
    |> result.values
    |> list.first
    |> resultx.assert_unwrap

  let starting_direction =
    grid
    |> grid.at(starting_coord)
    |> result.try(dict.get(direction_arrows, _))
    |> resultx.assert_unwrap

  let visited_coords =
    get_visited_coords(grid, starting_coord, starting_direction, set.new())
    |> resultx.assert_unwrap
    |> list.unique

  visited_coords
  |> list.filter(fn(coord) { coord != starting_coord })
  |> conc.map(try_obstruction(grid, _, starting_coord, starting_direction))
  |> list.count(result.is_error)
}

fn try_obstruction(
  grid: grid.Grid(String),
  coord: grid.Coord,
  starting_coord: grid.Coord,
  starting_direction: grid.Direction,
) {
  get_visited_coords(
    grid |> grid.copy_set(coord, "#") |> resultx.assert_unwrap,
    starting_coord,
    starting_direction,
    set.new(),
  )
}
