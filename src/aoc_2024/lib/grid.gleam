import aoc_2024/utils/resultx
import gleam/list
import gleam/result
import gleam/string
import glearray

pub type Grid(t) =
  glearray.Array(glearray.Array(t))

pub type Coord =
  #(Int, Int)

pub type Direction {
  Up
  UpRight
  Right
  DownRight
  Down
  DownLeft
  Left
  UpLeft
}

pub type Turn {
  TurnRight
  TurnLeft
}

const direction_map: List(#(Direction, #(Int, Int))) = [
  #(Up, #(0, 1)), #(UpRight, #(1, 1)), #(Right, #(1, 0)), #(DownRight, #(1, -1)),
  #(Down, #(0, -1)), #(DownLeft, #(-1, -1)), #(Left, #(-1, 0)),
  #(UpLeft, #(-1, 1)),
]

pub fn parse_input_to_string_grid(input: String) -> Grid(String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) { line |> string.split("") })
  |> list.transpose
  |> list.map(list.reverse)
  |> list.map(glearray.from_list)
  |> glearray.from_list
}

pub fn at(grid: Grid(t), coord: Coord) -> Result(t, Nil) {
  let #(row, col) = coord
  grid |> glearray.get(row) |> result.try(glearray.get(_, col))
}

pub fn copy_set(grid: Grid(t), coord: Coord, value: t) {
  let #(x, y) = coord

  grid
  |> glearray.copy_set(
    x,
    grid
      |> glearray.get(x)
      |> resultx.assert_unwrap
      |> glearray.copy_set(y, value)
      |> resultx.assert_unwrap,
  )
}

fn length(grid: Grid(t)) -> #(Int, Int) {
  let rows = grid |> glearray.length
  let cols = grid |> glearray.get(0) |> resultx.assert_unwrap |> glearray.length
  #(rows, cols)
}

pub fn get_coords(grid: Grid(t)) -> List(Coord) {
  let #(rows, cols) = grid |> length

  list.range(0, rows - 1)
  |> list.flat_map(fn(row) {
    list.range(0, cols - 1)
    |> list.map(fn(col) { #(row, col) })
  })
}

pub fn find(grid: Grid(t), item: t) -> Result(Coord, Nil) {
  grid
  |> get_coords
  |> list.find(fn(coord) { grid |> at(coord) |> resultx.assert_unwrap == item })
}

fn parse_direction(direction: Direction) -> #(Int, Int) {
  case direction_map |> list.find(fn(p) { p.0 == direction }) {
    Ok(#(_, xy)) -> xy
    _ -> panic
  }
}

fn to_direction(xy: #(Int, Int)) -> Direction {
  case direction_map |> list.find(fn(p) { p.1 == xy }) {
    Ok(#(direction, _)) -> direction
    _ -> panic
  }
}

pub fn move(coord: Coord, direction: Direction) -> Coord {
  let #(row, col) = coord
  let #(x, y) = direction |> parse_direction
  #(row + x, col + y)
}

pub fn opposite_direction(direction: Direction) -> Direction {
  let #(x, y) = direction |> parse_direction
  #(-x, -y) |> to_direction
}

pub fn turn(direction: Direction, turn: Turn) -> Direction {
  let #(x, y) = direction |> parse_direction

  case turn {
    TurnRight -> #(y, -x)
    TurnLeft -> #(-y, x)
  }
  |> to_direction
}

pub type DirectionOpts {
  Orthogonal
  Diagonal
  All
}

pub fn get_directions(opts: DirectionOpts) {
  let orthogonal = [Up, Right, Down, Left]
  let diagonal = [UpRight, DownRight, DownLeft, UpLeft]

  case opts {
    Orthogonal -> orthogonal
    Diagonal -> diagonal
    All -> list.interleave([orthogonal, diagonal])
  }
}
