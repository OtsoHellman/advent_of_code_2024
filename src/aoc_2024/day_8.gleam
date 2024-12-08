import aoc_2024/lib/grid
import aoc_2024/utils/resultx
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set

pub fn pt_1(input: String) {
  let grid = input |> grid.parse_input_to_string_grid

  let antennas =
    grid
    |> grid.get_coords
    |> list.map(grid.at(grid, _))
    |> list.map(resultx.assert_unwrap)
    |> set.from_list()
    |> set.delete(".")

  antennas
  |> set.map(get_antenna_antinode_locations(grid, _))
  |> set.to_list
  |> list.flatten
  |> list.unique
  |> list.filter_map(grid.at(grid, _))
  |> list.length
}

fn get_antenna_antinode_locations(
  grid: grid.Grid(String),
  antenna: String,
) -> List(grid.Coord) {
  let antenna_coords =
    grid
    |> grid.get_coords
    |> list.filter(fn(coord) { grid.at(grid, coord) == Ok(antenna) })

  let pairs =
    antenna_coords
    |> list.combination_pairs
    |> list.flat_map(fn(pair) { [pair, pair.swap(pair)] })

  pairs
  |> list.map(fn(pair) {
    let #(left, right) = pair
    grid.get_distance(left, right)
    |> grid.move_distance(right, _)
  })
}

pub fn pt_2(input: String) {
  let grid = input |> grid.parse_input_to_string_grid

  let antennas =
    grid
    |> grid.get_coords
    |> list.map(grid.at(grid, _))
    |> list.map(resultx.assert_unwrap)
    |> set.from_list()
    |> set.delete(".")

  antennas
  |> set.map(get_antenna_antinode_locations_2(grid, _))
  |> set.to_list
  |> list.flatten
  |> list.unique
  |> list.filter_map(grid.at(grid, _))
  |> list.length
}

fn get_antenna_antinode_locations_2(
  grid: grid.Grid(String),
  antenna: String,
) -> List(grid.Coord) {
  let antenna_coords =
    grid
    |> grid.get_coords
    |> list.filter(fn(coord) { grid.at(grid, coord) == Ok(antenna) })

  let pairs =
    antenna_coords
    |> list.combination_pairs
    |> list.flat_map(fn(pair) { [pair, pair.swap(pair)] })

  pairs
  |> list.map(fn(pair) {
    list.range(0, 60)
    |> list.map_fold(pair, fn(pair, _) {
      let antinode = get_one_antinode(pair)

      #(#(pair.1, antinode), #(pair.1, antinode))
    })
  })
  |> list.map(pair.second)
  |> list.flatten
  |> list.map(pair.first)
}

fn get_one_antinode(pair) {
  let #(left, right) = pair

  grid.get_distance(left, right)
  |> grid.move_distance(right, _)
}
