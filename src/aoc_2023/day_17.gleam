import aoc_2024/lib/grid
import aoc_2024/lib/perf
import aoc_2024/utils/dictx
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/set

pub fn pt_1(input: String) {
  use <- perf.measure("pt1")
  let grid = input |> grid.parse_input_to_int_grid
  let goal_coord = #(grid.length(grid).0 - 1, 0)

  let starting_coord = #(0, grid.length(grid).1 - 1)
  let starting_weight = 0

  let starting_node = Node(starting_coord, grid.Down, 0)

  let step_range = #(0, 3)
  dijkstra(
    grid,
    set.new(),
    dict.from_list([#(starting_node, starting_weight)]),
    goal_coord,
    step_range,
  )
}

pub type Node {
  Node(coord: grid.Coord, direction: grid.Direction, steps: Int)
}

fn dijkstra(
  grid: grid.Grid(Int),
  solved_nodes: set.Set(Node),
  seen_nodes: dict.Dict(Node, Int),
  goal_coord: grid.Coord,
  step_range: #(Int, Int),
) {
  let #(current_node, current_weight) =
    seen_nodes
    |> dictx.min_by(fn(weight) { weight })

  use <- bool.guard(current_node.coord == goal_coord, current_weight)

  let solved_nodes = solved_nodes |> set.insert(current_node)
  let seen_nodes = seen_nodes |> dict.delete(current_node)

  let seen_nodes =
    get_neighbors(grid, current_node, step_range)
    |> list.filter(fn(node) { !set.contains(solved_nodes, node) })
    |> update_seen_nodes(grid, _, seen_nodes, current_weight)

  dijkstra(grid, solved_nodes, seen_nodes, goal_coord, step_range)
}

fn get_neighbors(
  grid: grid.Grid(Int),
  current_node: Node,
  step_range: #(Int, Int),
) {
  let Node(current_coord, current_direction, current_steps) = current_node

  grid
  |> grid.get_neighbors(current_coord, grid.Orthogonal)
  |> list.filter(fn(neighbor) {
    let #(_, direction) = neighbor
    let opposite_direction = grid.opposite_direction(direction)
    let #(min_steps, max_steps) = step_range

    use <- bool.guard(current_steps == 0, True)
    use <- bool.guard(opposite_direction == current_direction, False)
    use <- bool.guard(current_steps < min_steps, direction == current_direction)
    use <- bool.guard(
      max_steps <= current_steps,
      direction != current_direction,
    )

    True
  })
  |> list.map(fn(neighbor) {
    let #(coord, direction) = neighbor
    case direction == current_direction {
      True -> Node(coord, direction, current_steps + 1)
      False -> Node(coord, direction, 1)
    }
  })
}

fn update_seen_nodes(
  grid: grid.Grid(Int),
  neighbors: List(Node),
  seen_nodes: dict.Dict(Node, Int),
  current_weight: Int,
) {
  use seen_nodes, neighbor <- list.fold(neighbors, seen_nodes)
  use existing_weight_option <- dict.upsert(seen_nodes, neighbor)

  let new_weight = grid.at_assert(grid, neighbor.coord) + current_weight

  case existing_weight_option {
    option.Some(existing_weight) -> int.min(existing_weight, new_weight)
    option.None -> new_weight
  }
}

pub fn pt_2(input: String) {
  use <- perf.measure("pt2")
  let grid = input |> grid.parse_input_to_int_grid
  let goal_coord = #(grid.length(grid).0 - 1, 0)

  let starting_coord = #(0, grid.length(grid).1 - 1)
  let starting_weight = 0

  let starting_node = Node(starting_coord, grid.Down, 0)

  let step_range = #(4, 10)
  dijkstra(
    grid,
    set.new(),
    dict.from_list([#(starting_node, starting_weight)]),
    goal_coord,
    step_range,
  )
}
