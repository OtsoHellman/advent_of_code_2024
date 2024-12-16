import aoc_2024/lib/grid
import aoc_2024/utils/dictx
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/set

pub fn parse(input: String) {
  input |> grid.parse_input_to_string_grid
}

pub fn pt_1(grid: grid.Grid(String)) {
  let starting_coord = #(1, 1)
  let starting_directon = grid.Right
  let starting_node = Node(starting_coord, starting_directon)

  dijkstra(grid, set.new(), dict.from_list([#(starting_node, 0)]))
}

pub type Node {
  Node(coord: grid.Coord, direction: grid.Direction)
}

fn dijkstra(
  grid: grid.Grid(String),
  solved_nodes: set.Set(Node),
  seen_nodes: dict.Dict(Node, Int),
) -> Int {
  let #(current_node, current_score) =
    seen_nodes
    |> dictx.min_by(fn(score) { score })

  use <- bool.guard(
    grid.at_assert(grid, current_node.coord) == "E",
    current_score,
  )

  let solved_nodes = solved_nodes |> set.insert(current_node)
  let seen_nodes = seen_nodes |> dict.delete(current_node)

  let seen_nodes =
    get_neighbors(grid, current_node)
    |> list.filter(fn(node) { !set.contains(solved_nodes, node) })
    |> update_seen_nodes(seen_nodes, current_score, current_node.direction)

  dijkstra(grid, solved_nodes, seen_nodes)
}

fn get_neighbors(grid: grid.Grid(String), current_node: Node) {
  let Node(current_coord, current_direction) = current_node

  grid
  |> grid.get_neighbors(current_coord, grid.Orthogonal)
  |> list.filter(fn(neighbor) {
    let #(coord, direction) = neighbor
    let neighbor_value = grid.at_assert(grid, coord)
    let opposite_direction = grid.opposite_direction(direction)

    use <- bool.guard(neighbor_value == "#", False)
    use <- bool.guard(opposite_direction == current_direction, False)

    True
  })
  |> list.map(fn(neighbor) {
    let #(coord, direction) = neighbor
    case direction == current_direction {
      True -> Node(coord, direction)
      False -> Node(current_coord, direction)
    }
  })
}

fn update_seen_nodes(
  neighbors: List(Node),
  seen_nodes: dict.Dict(Node, Int),
  current_score: Int,
  current_direction: grid.Direction,
) {
  use seen_nodes, neighbor <- list.fold(neighbors, seen_nodes)
  use existing_weight_option <- dict.upsert(seen_nodes, neighbor)

  let new_score = case neighbor.direction == current_direction {
    False -> current_score + 1000
    True -> current_score + 1
  }

  case existing_weight_option {
    option.Some(existing_weight) -> int.min(existing_weight, new_score)
    option.None -> new_score
  }
}

pub fn pt_2(_grid: grid.Grid(String)) {
  1
}
