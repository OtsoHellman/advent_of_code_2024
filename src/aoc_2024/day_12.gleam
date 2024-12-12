import aoc_2024/lib/grid
import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/set

pub fn parse(input: String) -> Grid {
  input |> grid.parse_input_to_string_grid
}

type Grid =
  grid.Grid(String)

type Coord =
  grid.Coord

type Plant {
  Plant(coord: Coord, fences: Int, sides: set.Set(grid.Direction))
}

type Region =
  List(Plant)

pub fn pt_1(grid: Grid) {
  grid
  |> grid.flood_fill_every_color
  |> list.map(fn(color) {
    color
    |> set.to_list
    |> list.map(fn(coord) {
      Plant(coord, get_n_of_fences(grid, coord), get_sides(grid, coord))
    })
  })
  |> list.map(get_score)
  |> int.sum
}

fn get_score(region: Region) {
  let area = region |> list.length
  let perimeter = region |> list.map(fn(plant) { plant.fences }) |> int.sum

  area * perimeter
}

fn get_sides(grid: Grid, coord: Coord) {
  grid.get_adjacent_coords(coord, grid.Orthogonal)
  |> list.filter(fn(x) {
    let #(adjacent, _) = x

    grid.at(grid, adjacent) != grid.at(grid, coord)
  })
  |> list.map(pair.second)
  |> set.from_list
}

fn get_n_of_fences(grid: Grid, coord: Coord) {
  get_sides(grid, coord) |> set.size
}

pub fn pt_2(grid: Grid) {
  grid
  |> grid.flood_fill_every_color
  |> list.map(fn(color) {
    color
    |> set.to_list
    |> list.map(fn(coord) {
      Plant(coord, get_n_of_fences(grid, coord), get_sides(grid, coord))
    })
  })
  |> list.map(get_sides_score)
  |> int.sum
}

fn get_sides_score(region: Region) {
  let sides_score =
    grid.get_directions(grid.Orthogonal)
    |> list.map(get_side_score(region, _))
    |> int.sum
  let area = region |> list.length
  sides_score * area
}

fn get_side_score(region: Region, direction: grid.Direction) {
  let sides =
    region
    |> list.filter(fn(plant) { set.contains(plant.sides, direction) })

  let side_groups =
    sides
    |> list.map(fn(plant) { plant.coord })
    |> list.map(flip(_, direction))
    |> list.group(fn(plant) { plant.0 })
    |> dict.to_list
    |> list.map(fn(x) { x.1 |> list.map(fn(plant) { plant.1 }) })

  side_groups
  |> list.map(fn(group) {
    group
    |> list.sort(int.compare)
    |> list.fold(#(0, -2), fn(pair, y) {
      let #(n_of_groups, prev_y) = pair

      case y - prev_y {
        1 -> #(n_of_groups, y)
        _ -> #(n_of_groups + 1, y)
      }
    })
    |> pair.first
  })
  |> int.sum
}

fn flip(coord, direction) {
  case direction {
    grid.Left | grid.Right -> coord
    grid.Up | grid.Down -> coord |> pair.swap
    _ -> panic
  }
}
