import aoc_2024/lib/grid
import aoc_2024/utils/resultx
import gleam/dict
import gleam/list
import gleam/result

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

  get_visited_coords(grid, starting_coord, starting_direction, [])
  |> list.unique
  |> list.length
}

fn get_visited_coords(
  grid: grid.Grid(String),
  coord: grid.Coord,
  direction: grid.Direction,
  visited_coords: List(grid.Coord),
) -> List(grid.Coord) {
  let visited_coords = list.flatten([visited_coords, [coord]])

  let next_coord = grid.move(coord, direction)
  case grid |> grid.at(next_coord) {
    Ok("#") ->
      get_visited_coords(
        grid,
        coord,
        direction |> grid.turn(grid.TurnRight),
        visited_coords,
      )
    Ok(_) -> get_visited_coords(grid, next_coord, direction, visited_coords)
    Error(_) -> visited_coords
  }
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
