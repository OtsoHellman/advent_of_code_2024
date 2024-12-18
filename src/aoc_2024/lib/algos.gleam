import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleamy/priority_queue as pq

pub fn bfs(start: a, is_goal: fn(a) -> Bool, get_neighbors: fn(a) -> List(a)) {
  dijkstra(start, is_goal, get_neighbors, fn(_, score, _) { score + 1 })
}

pub fn dijkstra(
  start: a,
  is_goal: fn(a) -> Bool,
  get_neighbors: fn(a) -> List(a),
  update_score: fn(a, Int, a) -> Int,
) {
  let pq =
    pq.new(fn(a, b) {
      let assert Ok(#(_, a_score)) = a |> list.first
      let assert Ok(#(_, b_score)) = b |> list.first
      int.compare(a_score, b_score)
    })
    |> pq.push([#(start, 0)])

  dijkstra_inner(is_goal, get_neighbors, update_score, dict.new(), pq)
}

fn dijkstra_inner(
  is_goal: fn(a) -> Bool,
  get_neighbors: fn(a) -> List(a),
  update_score: fn(a, Int, a) -> Int,
  solved_nodes: dict.Dict(a, List(#(a, Int))),
  pq: pq.Queue(List(#(a, Int))),
) {
  let assert Ok(#(path, pq)) = pq.pop(pq)
  let assert Ok(#(node, score)) = list.first(path)

  use <- bool.guard(is_goal(node), path)

  case dict.has_key(solved_nodes, node) {
    True ->
      dijkstra_inner(is_goal, get_neighbors, update_score, solved_nodes, pq)
    False -> {
      let solved_nodes = dict.insert(solved_nodes, node, path)

      let pq =
        get_neighbors(node)
        |> update_queue(update_score, pq, node, score, path)

      dijkstra_inner(is_goal, get_neighbors, update_score, solved_nodes, pq)
    }
  }
}

fn update_queue(
  neighbors: List(a),
  update_score: fn(a, Int, a) -> Int,
  pq: pq.Queue(List(#(a, Int))),
  node: a,
  score: Int,
  path: List(#(a, Int)),
) {
  use pq, neighbor <- list.fold(neighbors, pq)

  let new_score = update_score(node, score, neighbor)

  pq |> pq.push([#(neighbor, new_score), ..path])
}
