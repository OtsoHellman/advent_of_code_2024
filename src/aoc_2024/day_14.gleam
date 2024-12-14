import aoc_2024/lib/grid
import aoc_2024/utils/resultx
import gleam/bool
import gleam/dict
import gleam/erlang/node
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string

pub fn parse(input: String) {
  input |> string.split("\n") |> list.map(parse_robot)
}

fn parse_robot(input: String) {
  let assert Ok(number_re) = regexp.from_string("-?[0-9]+")
  let assert [p_x, p_y, v_x, v_y] =
    regexp.scan(number_re, input)
    |> list.map(fn(match) { match.content })
    |> list.map(resultx.int_parse_unwrap)

  Robot(#(p_x, p_y), #(v_x, v_y))
}

pub type Robot {
  Robot(position: grid.Coord, velocity: grid.Coord)
}

const x_max = 101

//101

const y_max = 103

//103

pub fn pt_1(robots: List(Robot)) {
  robots |> list.map(move_n) |> get_score
}

fn print(robot: Robot) {
  "" |> io.debug
  let Robot(p, _) = robot
  p |> io.debug

  robot
}

fn move_n(robot: Robot) {
  let n = 100

  use robot, i <- list.fold(list.range(1, n), robot)
  move(robot)
}

fn move(robot: Robot) {
  let #(x, y) = grid.move_distance(robot.position, robot.velocity)

  Robot(#({ x + x_max } % x_max, { y + y_max } % y_max), robot.velocity)
}

fn get_score(robots: List(Robot)) {
  let x_split = { x_max - 3 } / 2

  let y_split = { y_max - 3 } / 2

  robots
  |> list.map(fn(robot) {
    case robot.position {
      #(x, y) if x <= x_split && y <= y_split -> grid.DownLeft
      #(x, y) if x_split + 2 <= x && y <= y_split -> grid.DownRight
      #(x, y) if x <= x_split && y_split + 2 <= y -> grid.UpLeft
      #(x, y) if x_split + 2 <= x && y_split + 2 <= y -> grid.UpRight
      _ -> grid.Down
    }
  })
  |> list.filter(fn(x) { x != grid.Down })
  |> list.group(fn(x) { x })
  |> dict.values
  |> list.map(list.length)
  |> int.product
}

pub fn pt_2(robots: List(Robot)) {
  find_tree(robots, 0)
}

fn find_tree(robots: List(Robot), i: Int) {
  use <- bool.guard(count(robots) == 500, i)

  let robots = robots |> list.map(move)

  find_tree(robots, i + 1)
}

fn count(robots: List(Robot)) {
  robots
  |> list.map(fn(robot) { robot.position })
  |> list.unique
  |> list.length
}
