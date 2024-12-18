import aoc_2024/lib/grid
import aoc_2024/utils/dictx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
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

  grid |> grid.print
  let start = #(0, 0)
  dijkstra_1(grid, set.new(), dict.from_list([#(start, 0)]))
}

fn dijkstra_1(
  grid: grid.Grid(String),
  solved_nodes: set.Set(grid.Coord),
  seen_nodes: dict.Dict(grid.Coord, Int),
) -> Int {
  let #(current_coord, current_score) =
    seen_nodes
    |> dictx.min_by(fn(score) { score })

  use <- bool.guard(current_coord == #(x - 1, y - 1), current_score)

  let solved_nodes = solved_nodes |> set.insert(current_coord)
  let seen_nodes = seen_nodes |> dict.delete(current_coord)

  let seen_nodes =
    get_neighbors(grid, current_coord)
    |> list.filter(fn(node) { !set.contains(solved_nodes, node) })
    |> update_seen_coords_1(seen_nodes, current_score)

  dijkstra_1(grid, solved_nodes, seen_nodes)
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

fn update_seen_coords_1(
  neighbors: List(grid.Coord),
  seen_nodes: dict.Dict(grid.Coord, Int),
  current_score: Int,
) {
  use seen_nodes, neighbor <- list.fold(neighbors, seen_nodes)
  use existing_pair_option <- dict.upsert(seen_nodes, neighbor)

  let new_score = current_score + 1

  case existing_pair_option {
    option.Some(existing_score) -> int.min(existing_score, new_score)
    option.None -> new_score
  }
}

pub fn pt_2(_input: String) {
  1
}
