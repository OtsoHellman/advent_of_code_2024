import aoc_2024/lib/grid
import gleam/list
import gleam/pair
import gleam/set

type Pair =
  #(grid.Coord, grid.Coord)

type Grid =
  grid.Grid(String)

fn parse_antennas(grid: Grid) {
  grid
  |> grid.get_coords
  |> list.map(grid.at_assert(grid, _))
  |> set.from_list()
  |> set.delete(".")
  |> set.to_list
}

pub fn pt_1(input: String) {
  let grid = input |> grid.parse_input_to_string_grid

  parse_antennas(grid)
  |> list.flat_map(get_antenna_pairs(grid, _))
  |> list.map(get_one_antinode)
  |> list.filter(grid.includes(grid, _))
  |> list.unique
  |> list.length
}

fn get_antenna_pairs(grid: Grid, antenna: String) -> List(Pair) {
  grid
  |> grid.get_coords
  |> list.filter(fn(coord) { grid.at(grid, coord) == Ok(antenna) })
  |> list.combination_pairs
  |> list.flat_map(fn(pair) { [pair, pair.swap(pair)] })
}

fn get_one_antinode(pair: Pair) {
  let #(left, right) = pair

  grid.get_distance(left, right)
  |> grid.move_distance(right, _)
}

pub fn pt_2(input: String) {
  let grid = input |> grid.parse_input_to_string_grid

  let antinode_coords =
    parse_antennas(grid)
    |> list.flat_map(get_antenna_pairs(grid, _))
    |> list.flat_map(fn(pair) { get_all_antinodes(grid, [pair.1, pair.0]) })
    |> list.unique

  let print_predicate = fn(coord) {
    case
      list.contains(antinode_coords, coord)
      && grid.at_assert(grid, coord) == "."
    {
      True -> Ok("#")
      False -> Error(Nil)
    }
  }

  grid.conditional_print(grid, print_predicate)

  antinode_coords
  |> list.length
}

fn get_all_antinodes(grid: Grid, antinodes: List(grid.Coord)) {
  let assert [right, left, ..] = antinodes

  let antinode = get_one_antinode(#(left, right))

  case grid.includes(grid, antinode) {
    False -> antinodes
    True -> get_all_antinodes(grid, [antinode, ..antinodes])
  }
}
