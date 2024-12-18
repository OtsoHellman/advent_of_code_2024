import aoc_2024/lib/algos
import aoc_2024/lib/grid
import aoc_2024/utils/dictx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/dict
import gleam/list
import gleam/option
import gleam/pair

pub fn parse(input: String) {
  input |> grid.parse_input_to_string_grid
}

pub fn pt_1(grid: grid.Grid(String)) {
  let starting_coord = #(1, 1)
  let starting_directon = grid.Right
  let starting_node = Node(starting_coord, starting_directon)

  algos.dijkstra(
    starting_node,
    fn(node) { grid.at_assert(grid, node.coord) == "E" },
    fn(node) { get_neighbors(grid, node) },
    fn(node, score, neighbor) {
      case neighbor.direction == node.direction {
        False -> score + 1000
        True -> score + 1
      }
    },
  )
  |> list.first
  |> resultx.assert_unwrap
  |> pair.second
}

pub type Node {
  Node(coord: grid.Coord, direction: grid.Direction)
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

pub fn pt_2(grid: grid.Grid(String)) {
  let starting_coord = #(1, 1)
  let starting_directon = grid.Right
  let starting_node = Node(starting_coord, starting_directon)

  let asd =
    dijkstra(grid, dict.new(), dict.from_list([#(starting_node, #([], 0))]), [])
    |> list.map(fn(x) {
      let #(_, #(nodes, _)) = x

      // list.length(nodes)
      nodes |> list.map(fn(node) { node.coord })
    })
    |> list.flatten

  grid.map_with_coord(grid, fn(coord) {
    case list.find(asd, fn(x) { x == coord }) {
      Ok(_) -> Ok("0")
      _ -> Error(Nil)
    }
  })
  |> grid.print

  asd |> list.unique |> list.length
}

fn dijkstra(
  grid: grid.Grid(String),
  solved_nodes: dict.Dict(Node, #(List(Node), Int)),
  seen_nodes: dict.Dict(Node, #(List(Node), Int)),
  goals: List(#(Node, #(List(Node), Int))),
) {
  let current_entry =
    seen_nodes
    |> dictx.min_by(fn(pair) { pair.1 })

  let #(current_node, #(current_path, current_score)) = current_entry

  let current_value = grid.at_assert(grid, current_node.coord)
  let goals = case current_value == "E" {
    True -> [current_entry, ..goals]
    False -> goals
  }
  let seen_nodes = seen_nodes |> dict.delete(current_node)

  use <- bool.guard(123 < current_score, goals)
  // part 1 answer here

  case dict.get(solved_nodes, current_node) {
    Ok(#(_, score)) if score < current_score -> {
      dijkstra(grid, solved_nodes, seen_nodes, goals)
    }
    Ok(#(path, score)) if score == current_score -> {
      let solved_nodes =
        dict.insert(solved_nodes, current_node, #(
          list.flatten([path, current_path]),
          current_score,
        ))

      dijkstra(grid, solved_nodes, seen_nodes, goals)
    }
    Error(_) -> {
      let solved_nodes =
        solved_nodes
        |> dict.insert(current_node, #(current_path, current_score))

      let seen_nodes =
        get_neighbors(grid, current_node)
        |> update_seen_nodes(
          seen_nodes,
          current_score,
          current_node.direction,
          current_path,
        )

      dijkstra(grid, solved_nodes, seen_nodes, goals)
    }
    _ -> panic
  }
}

fn update_seen_nodes(
  neighbors: List(Node),
  seen_nodes: dict.Dict(Node, #(List(Node), Int)),
  current_score: Int,
  current_direction: grid.Direction,
  current_path: List(Node),
) {
  use seen_nodes, neighbor <- list.fold(neighbors, seen_nodes)
  use existing_pair_option <- dict.upsert(seen_nodes, neighbor)

  let new_score = case neighbor.direction == current_direction {
    False -> current_score + 1000
    True -> current_score + 1
  }

  let new_path = [neighbor, ..current_path]

  case existing_pair_option {
    option.Some(existing_pair) ->
      case existing_pair.1 {
        existing_score if existing_score < new_score -> existing_pair
        existing_score if new_score < existing_score -> #(new_path, new_score)
        _ -> {
          #(list.flatten([existing_pair.0, new_path]), new_score)
        }
      }
    option.None -> #(new_path, new_score)
  }
}
