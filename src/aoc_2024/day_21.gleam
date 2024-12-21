import aoc_2024/lib/grid
import aoc_2024/utils/regexpx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/deque
import gleam/int
import gleam/io
import gleam/list
import gleam/queue
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

  let code =
    codes
    |> list.first
    |> resultx.assert_unwrap

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
  |> list.map(fn(transition) {
    let keys = Keys(transition.start)
    let arrows_1 = Arrows(keys, "A")
    let arrows_2 = Arrows(arrows_1, "A")

    let dq =
      [Up, Right, Down, Left, Step]
      |> list.map(fn(d) { #(arrows_2, [d]) })
      |> deque.from_list

    solve_transition(transition, set.new(), dq)
    |> build_transition_string
    |> string.append("A")
  })
  |> string.join("")
  |> string.length
}

fn solve_transition(
  transition: Transition,
  solved: set.Set(Keyboard),
  queue: deque.Deque(#(Keyboard, List(Move))),
) {
  let assert Ok(#(#(keyboard, moves), queue)) = deque.pop_front(queue)
  let assert Ok(move) = list.first(moves)

  let keyboard = step(keyboard, move)

  keyboard |> io.debug
  use <- bool.guard(is_goal(keyboard, transition.goal), list.reverse(moves))

  case set.contains(solved, keyboard) {
    True -> {
      solve_transition(transition, solved, queue)
    }
    False -> {
      let solved = set.insert(solved, keyboard)
      let queue = update_queue(queue, keyboard, moves)
      solve_transition(transition, solved, queue)
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

fn move_arrows(keys: Keyboard, move: Move) -> Result(String, Nil) {
  let position = case keys {
    Arrows(_, p) -> p
    _ -> panic
  }
  let grid = grid.parse_input_to_string_grid(arrows_string)

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

fn step(keyboard: Keyboard, move: Move) -> Keyboard {
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
          let nested_keyboard = step(nested_keyboard, move)
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

pub fn pt_2(_input: String) {
  1
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
