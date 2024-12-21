import aoc_2024/utils/resultx
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
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

pub fn new(size: #(Int, Int)) -> Grid(String) {
  let #(cols, rows) = size
  list.range(1, cols)
  |> list.map(fn(_) {
    list.range(1, rows)
    |> list.map(fn(_) { "." })
    |> glearray.from_list()
  })
  |> glearray.from_list()
}

pub fn parse_input_to_string_grid(input: String) -> Grid(String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) { line |> string.split("") })
  |> list.transpose
  |> list.map(list.reverse)
  |> list.map(glearray.from_list)
  |> glearray.from_list
}

fn to_string(grid: Grid(String)) {
  grid
  |> glearray.to_list
  |> list.map(glearray.to_list)
  |> list.map(list.reverse)
  |> list.transpose
  |> list.map(string.join(_, ""))
  |> string.join("\n")
}

pub fn print(grid: Grid(String)) {
  { "\n\n" <> to_string(grid) <> "\n" } |> io.println
}

pub fn conditional_print(
  grid: Grid(String),
  predicate: fn(Coord) -> Result(String, Nil),
) {
  grid |> map_with_coord(predicate) |> print
}

pub fn map(grid: Grid(a), fun: fn(a) -> v) -> Grid(v) {
  grid
  |> glearray.to_list
  |> list.map(fn(col) {
    col |> glearray.to_list |> list.map(fun) |> glearray.from_list
  })
  |> glearray.from_list
}

pub fn map_with_coord(
  grid: Grid(a),
  fun: fn(Coord) -> Result(a, Nil),
) -> Grid(a) {
  use grid, coord <- list.fold(get_coords(grid), grid)

  case fun(coord) {
    Ok(value) -> copy_set(grid, coord, value) |> resultx.assert_unwrap
    Error(_) -> grid
  }
}

pub fn parse_input_to_int_grid(input: String) -> Grid(Int) {
  input |> parse_input_to_string_grid |> map(resultx.int_parse_unwrap)
}

pub fn at(grid: Grid(t), coord: Coord) -> Result(t, Nil) {
  let #(row, col) = coord
  grid |> glearray.get(row) |> result.try(glearray.get(_, col))
}

pub fn at_assert(grid: Grid(t), coord: Coord) -> t {
  at(grid, coord) |> resultx.assert_unwrap
}

pub fn includes(grid: Grid(t), coord: Coord) -> Bool {
  case at(grid, coord) {
    Ok(_) -> True
    _ -> False
  }
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

pub fn assert_set(grid: Grid(t), coord: Coord, value: t) {
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
  |> resultx.assert_unwrap
}

pub fn length(grid: Grid(t)) -> #(Int, Int) {
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

pub fn find_all_by(grid: Grid(t), predicate: fn(t) -> Bool) -> List(Coord) {
  grid
  |> get_coords
  |> list.filter(fn(coord) {
    grid |> at(coord) |> resultx.assert_unwrap |> predicate
  })
}

fn parse_direction(direction: Direction) -> #(Int, Int) {
  case direction_map |> list.find(fn(p) { p.0 == direction }) {
    Ok(#(_, xy)) -> xy
    _ -> panic
  }
}

pub fn to_direction(xy: #(Int, Int)) -> Direction {
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

pub fn try_move(
  grid: Grid(a),
  coord: Coord,
  direction: Direction,
) -> Result(Coord, Nil) {
  let #(row, col) = coord
  let #(x, y) = direction |> parse_direction
  let #(row, col) = #(row + x, col + y)

  let #(rows, cols) = grid |> length

  case 0 <= row && row < rows && 0 <= col && col < cols {
    True -> Ok(#(row, col))
    _ -> Error(Nil)
  }
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

pub fn get_neighbors(grid: Grid(a), coord: Coord, opts: DirectionOpts) {
  opts
  |> get_directions
  |> list.filter_map(fn(direction) {
    use coords <- result.try(try_move(grid, coord, direction))
    #(coords, direction) |> Ok
  })
}

pub fn get_adjacent_coords(coord: Coord, opts: DirectionOpts) {
  opts
  |> get_directions
  |> list.map(fn(direction) { #(move(coord, direction), direction) })
}

pub type Distance =
  #(Int, Int)

pub fn get_distance(left: Coord, right: Coord) -> Distance {
  let #(x1, y1) = left
  let #(x2, y2) = right

  #(x2 - x1, y2 - y1)
}

pub fn get_manhattan_distance(left: Coord, right: Coord) -> Int {
  get_distance(left, right)
  |> fn(pair) {
    let #(x, y) = pair

    int.absolute_value(x) + int.absolute_value(y)
  }
}

pub fn move_distance(coord: Coord, distance: Distance) -> Coord {
  let #(row, col) = coord
  let #(x, y) = distance
  #(row + x, col + y)
}

pub fn multiply(coord: Coord, n: Int) -> Coord {
  let #(row, col) = coord
  #(row * n, col * n)
}

pub fn flood_fill_every_color(grid: Grid(a)) {
  let stack = grid |> get_coords |> set.from_list

  let predicate = fn(a, b) { a == b }

  flood_fill_every_inner(grid, stack, [], predicate)
}

fn flood_fill_every_inner(
  grid: Grid(a),
  stack: set.Set(Coord),
  groups: List(set.Set(Coord)),
  predicate: fn(a, a) -> Bool,
) {
  case set.to_list(stack) {
    [coord, ..] -> {
      let group = flood_fill(grid, coord, predicate)
      let stack = set.difference(stack, group)
      let groups = [group, ..groups]

      flood_fill_every_inner(grid, stack, groups, predicate)
    }
    [] -> groups
  }
}

pub fn flood_fill(
  grid: Grid(a),
  starting_coord: Coord,
  predicate: fn(a, a) -> Bool,
) {
  flood_fill_inner(grid, starting_coord, predicate, set.new())
}

fn flood_fill_inner(
  grid: Grid(a),
  coord: Coord,
  predicate: fn(a, a) -> Bool,
  result: set.Set(Coord),
) {
  use <- bool.guard(set.contains(result, coord), result)

  let result = set.insert(result, coord)

  let neighbors =
    get_neighbors(grid, coord, Orthogonal)
    |> list.map(pair.first)
    |> list.filter(fn(neighbor) {
      let left = at_assert(grid, coord)
      let right = at_assert(grid, neighbor)

      predicate(left, right)
    })

  use result, neighbor <- list.fold(neighbors, result)
  flood_fill_inner(grid, neighbor, predicate, result)
}
