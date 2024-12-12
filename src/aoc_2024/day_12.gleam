import aoc_2024/lib/grid
import aoc_2024/utils/listx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

pub fn parse(input: String) -> Grid {
  input |> grid.parse_input_to_string_grid
}

type Grid =
  grid.Grid(String)

type Plant {
  Plant(coord: grid.Coord, fences: Int, sides: set.Set(grid.Direction))
}

type Region =
  List(Plant)

pub fn pt_1(grid: Grid) {
  grid |> grid.print

  let unsolved_coords = grid |> grid.get_coords

  form_regions(grid, unsolved_coords, [])
  |> list.map(get_score)
  |> int.sum
}

fn get_score(region: Region) {
  let area = region |> list.length
  let perimeter = region |> list.map(fn(plant) { plant.fences }) |> int.sum

  area * perimeter
}

fn form_regions(
  grid: Grid,
  unsolved_coords: List(grid.Coord),
  regions: List(Region),
) -> List(Region) {
  use <- bool.guard(list.is_empty(unsolved_coords), regions)

  let #(coord, unsolved_coords) = listx.pop(unsolved_coords)

  let new_region = form_region(grid, coord, [], [])

  let unsolved_coords =
    unsolved_coords
    |> list.filter(fn(coord) {
      new_region
      |> list.find(fn(plant) { plant.coord == coord })
      |> result.is_error
    })

  let regions = regions |> list.prepend(new_region)
  form_regions(grid, unsolved_coords, regions)
}

fn form_region(
  grid: Grid,
  current_coord: grid.Coord,
  current_region: Region,
  to_traverse: List(grid.Coord),
) {
  let current_plant_type = grid.at(grid, current_coord)

  let neighbors = grid.get_neighbors(grid, current_coord, grid.Orthogonal)

  let n_of_fences =
    {
      neighbors
      |> list.count(fn(neighbor) {
        let #(neighbor_coord, _) = neighbor
        grid.at(grid, neighbor_coord) != current_plant_type
      })
    }
    + 4
    - {
      neighbors
      |> list.length
    }

  let sides =
    grid.get_directions(grid.Orthogonal)
    |> list.filter(fn(direction) {
      { grid.move(current_coord, direction) |> grid.at(grid, _) }
      != current_plant_type
    })
    |> set.from_list

  let plant = Plant(current_coord, n_of_fences, sides)

  let current_region = current_region |> list.prepend(plant)

  let neighbors_to_traverse =
    neighbors
    |> list.filter(fn(neighbor) {
      let #(neighbor_coord, _) = neighbor
      grid.at(grid, neighbor_coord) == current_plant_type
      && list.find(to_traverse, fn(coord) { coord == neighbor_coord })
      |> result.is_error
      && list.find(current_region, fn(plant) { plant.coord == neighbor_coord })
      |> result.is_error
    })
    |> list.map(pair.first)

  let to_traverse = list.flatten([to_traverse, neighbors_to_traverse])

  case list.is_empty(to_traverse) {
    True -> current_region
    False -> {
      let #(next_coord, to_traverse) = listx.pop(to_traverse)

      form_region(grid, next_coord, current_region, to_traverse)
    }
  }
}

pub fn pt_2(grid: Grid) {
  grid |> grid.print

  let unsolved_coords = grid |> grid.get_coords

  form_regions(grid, unsolved_coords, [])
  |> list.map(get_sides_score)
  |> int.sum
  |> io.debug
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
