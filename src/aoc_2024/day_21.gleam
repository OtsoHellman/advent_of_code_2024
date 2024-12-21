import aoc_2024/lib/cache
import aoc_2024/lib/grid
import aoc_2024/utils/listx
import aoc_2024/utils/regexpx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/deque
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string

const arrows_string = "#^A
<v>"

const keyboard_string = "789
456
123
#0A"

type Transition {
  Transition(start: String, goal: String)
}

pub type Keyboard {
  Arrows(keyboard: Keyboard, position: String)
  Keys(position: String)
}

pub type Move {
  Up
  Right
  Down
  Left
  Step
}

pub fn pt_1(input: String) {
  let codes = input |> string.split("\n")

  codes
  |> list.map(get_code_sequence_1)
  |> list.zip(codes)
  |> list.map(fn(x) {
    let #(value, code) = x
    let assert [code] = regexpx.get_positive_ints(code)
    value * code
  })
  |> int.sum
}

pub fn get_code_sequence_1(code) {
  let transitions =
    code
    |> fn(x) { "A" <> x }
    |> string.split("")
    |> list.window(2)
    |> list.map(fn(x) {
      let assert [a, b] = x

      Transition(a, b)
    })

  transitions
  |> list.map(fn(transition) {
    let keyboard = build_keyboard(transition.start, 2)

    let dq =
      [Up, Right, Down, Left, Step]
      |> list.map(fn(d) { #(keyboard, [d]) })
      |> deque.from_list

    solve_transition(transition, set.new(), dq)
    |> build_transition_string
    |> string.append("A")
  })
  |> string.join("")
  |> string.length
}

fn build_keyboard(start: String, n: Int) {
  let keys = Keys(start)
  use keyboard, _ <- list.fold(list.range(1, n), keys)
  Arrows(keyboard, "A")
}

fn solve_transition(
  transition: Transition,
  visited: set.Set(Keyboard),
  queue: deque.Deque(#(Keyboard, List(Move))),
) {
  let assert Ok(#(#(keyboard, moves), queue)) = deque.pop_front(queue)
  let assert Ok(move) = list.first(moves)

  let keyboard = nested_step(keyboard, move)

  use <- bool.guard(is_goal(keyboard, transition.goal), list.reverse(moves))

  case set.contains(visited, keyboard) {
    True -> {
      solve_transition(transition, visited, queue)
    }
    False -> {
      let visited = set.insert(visited, keyboard)
      let queue = update_queue(queue, keyboard, moves)
      solve_transition(transition, visited, queue)
    }
  }
}

fn update_queue(
  queue: deque.Deque(#(Keyboard, List(Move))),
  keyboard: Keyboard,
  moves: List(Move),
) {
  use queue, move <- list.fold([Up, Right, Down, Left, Step], queue)

  deque.push_back(queue, #(keyboard, [move, ..moves]))
}

fn is_goal(keyboard: Keyboard, goal: String) -> Bool {
  case keyboard {
    Keys(position) -> position == goal
    Arrows(keyboard, position) -> position == "A" && is_goal(keyboard, goal)
  }
}

fn move_keys(keys: Keyboard, move: Move) -> Result(String, Nil) {
  let position = case keys {
    Keys(p) -> p
    _ -> panic
  }
  let grid = grid.parse_input_to_string_grid(keyboard_string)

  let coord = grid.find(grid, position) |> resultx.assert_unwrap

  let new_coord = case move {
    Up -> grid.try_move(grid, coord, grid.Up)
    Right -> grid.try_move(grid, coord, grid.Right)
    Down -> grid.try_move(grid, coord, grid.Down)
    Left -> grid.try_move(grid, coord, grid.Left)
    Step -> Error(Nil)
  }
  let result = new_coord |> result.map(grid.at(grid, _)) |> result.flatten

  case result == Ok("#") {
    True -> Error(Nil)
    False -> result
  }
}

fn move_step(position: String, move: Move, arrow: Bool) -> Result(String, Nil) {
  let grid = case arrow {
    True -> grid.parse_input_to_string_grid(arrows_string)
    False -> grid.parse_input_to_string_grid(keyboard_string)
  }

  let coord = grid.find(grid, position) |> resultx.assert_unwrap

  let new_coord = case move {
    Up -> grid.try_move(grid, coord, grid.Up)
    Right -> grid.try_move(grid, coord, grid.Right)
    Down -> grid.try_move(grid, coord, grid.Down)
    Left -> grid.try_move(grid, coord, grid.Left)
    Step -> panic
  }
  let result = new_coord |> result.map(grid.at(grid, _)) |> result.flatten

  case result == Ok("#") {
    True -> Error(Nil)
    False -> result
  }
}

fn move_arrows(keys: Keyboard, move: Move) -> Result(String, Nil) {
  let position = case keys {
    Arrows(_, p) -> p
    _ -> panic
  }

  move_step(position, move, True)
}

fn nested_step(keyboard: Keyboard, move: Move) -> Keyboard {
  case keyboard {
    Keys(_) -> {
      let position = move_keys(keyboard, move)
      case position {
        Ok(position) -> Keys(position)
        _ -> keyboard
      }
    }
    Arrows(nested_keyboard, position) -> {
      case move {
        Step -> {
          let move = case position {
            "^" -> Up
            ">" -> Right
            "v" -> Down
            "<" -> Left
            "A" -> Step
            _ -> panic
          }
          let nested_keyboard = nested_step(nested_keyboard, move)
          Arrows(nested_keyboard, position)
        }
        _ -> {
          let position = move_arrows(keyboard, move)
          case position {
            Ok(position) -> Arrows(nested_keyboard, position)
            _ -> keyboard
          }
        }
      }
    }
  }
}

fn build_transition_string(moves: List(Move)) {
  use transition_string, direction <- list.fold(moves, "")
  let new = case direction {
    Up -> "^"
    Right -> ">"
    Down -> "v"
    Left -> "<"
    Step -> "A"
  }
  transition_string <> new
}

pub fn pt_2(input: String) {
  let codes = input |> string.split("\n")

  cache.create()

  codes
  |> list.map(get_code_sequence)
  |> list.zip(codes)
  |> list.map(fn(x) {
    let #(value, code) = x
    let assert [code] = regexpx.get_positive_ints(code)
    value * code
  })
  |> int.sum
}

pub fn get_code_sequence(code) {
  let transitions =
    code
    |> fn(x) { "A" <> x }
    |> string.split("")
    |> list.window(2)
    |> list.map(fn(x) {
      let assert [a, b] = x

      Transition(a, b)
    })

  transitions
  |> list.map(get_transitions(_, False))
  |> list.map(fn(transition_strings) {
    transition_strings
    |> list.map(fn(transition_string) {
      construct_transitions(transition_string)
      |> list.map(get_min_transitions(_, 24))
      |> int.sum
    })
    |> listx.assert_reduce(int.min)
  })
  |> int.sum
}

fn construct_transitions(transition_string: String) {
  transition_string
  |> fn(x) { "A" <> x }
  |> string.split("")
  |> list.window(2)
  |> list.map(fn(x) {
    let assert [a, b] = x

    Transition(a, b)
  })
}

fn get_min_transitions(transition: Transition, level: Int) -> Int {
  use <- cache.try_memo(#(transition, level))
  let transition_strings = get_transitions(transition, True)

  case level <= 0 {
    True ->
      transition_strings
      |> list.map(string.length)
      |> listx.assert_reduce(int.min)
    False ->
      transition_strings
      |> list.map(fn(transition_string) {
        let transitions = transition_string |> construct_transitions

        transitions
        |> list.map(fn(transition) {
          get_min_transitions(transition, level - 1)
        })
        |> int.sum
      })
      |> listx.assert_reduce(int.min)
  }
}

fn get_transitions(transition: Transition, arrow: Bool) {
  let Transition(start, goal) = transition

  case start == goal {
    True -> ["A"]
    False ->
      solve(transition, arrow)
      |> list.map(build_transition_string)
  }
}

fn solve(transition: Transition, arrow: Bool) {
  let dq =
    [Down, Left, Up, Right]
    |> list.map(fn(d) { #(transition.start, [d]) })
    |> deque.from_list

  solve_arrow_transition(transition, dict.new(), [], dq, arrow)
  |> list.map(fn(list) {
    list
    |> list.prepend(Step)
    |> list.reverse()
  })
}

fn solve_arrow_transition(
  transition: Transition,
  visited: dict.Dict(String, Int),
  solved: List(List(Move)),
  queue: deque.Deque(#(String, List(Move))),
  arrow: Bool,
) {
  use <- bool.guard(deque.is_empty(queue), solved)
  let assert Ok(#(#(position, moves), queue)) = deque.pop_front(queue)
  let assert Ok(move) = list.first(moves)
  let position = move_step(position, move, arrow)
  case position {
    Ok(position) -> {
      let solved = case position == transition.goal {
        True -> {
          case list.is_empty(solved) {
            True -> [moves, ..solved]
            False ->
              case
                solved |> list.first |> resultx.assert_unwrap |> list.length
                < list.length(moves)
              {
                True -> solved
                False -> [moves, ..solved]
              }
          }
        }
        False -> solved
      }

      case
        dict.has_key(visited, position)
        && dict.get(visited, position) |> resultx.assert_unwrap
        < list.length(moves)
      {
        True -> {
          solve_arrow_transition(transition, visited, solved, queue, arrow)
        }
        False -> {
          let visited = dict.insert(visited, position, list.length(moves))
          let queue = update_arrow_queue(queue, position, moves)
          solve_arrow_transition(transition, visited, solved, queue, arrow)
        }
      }
    }
    _ -> solve_arrow_transition(transition, visited, solved, queue, arrow)
  }
}

fn update_arrow_queue(
  queue: deque.Deque(#(String, List(Move))),
  position: String,
  moves: List(Move),
) {
  use queue, move <- list.fold([Up, Right, Down, Left], queue)

  deque.push_back(queue, #(position, [move, ..moves]))
}
