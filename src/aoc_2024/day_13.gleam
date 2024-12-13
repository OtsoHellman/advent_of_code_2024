import aoc_2024/lib/grid
import aoc_2024/utils/listx
import aoc_2024/utils/resultx
import gleam/float
import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

pub fn parse(input: String) -> List(Game) {
  input
  |> string.split("\n\n")
  |> list.map(parse_game)
}

fn parse_game(input: String) -> Game {
  let assert [a_string, b_string, price_string] = input |> string.split("\n")
  Game(
    parse_button(a_string, 3),
    parse_button(b_string, 1),
    parse_price(price_string),
  )
}

fn parse_button(input: String, cost: Int) -> Button {
  let assert Ok(number_re) = regexp.from_string("[0-9]+")
  let assert [x, y] =
    regexp.scan(number_re, input)
    |> list.map(fn(match) { match.content })
    |> list.map(resultx.int_parse_unwrap)

  Button(cost, #(x, y))
}

fn parse_price(input: String) -> Price {
  let assert Ok(number_re) = regexp.from_string("[0-9]+")
  let assert [x, y] =
    regexp.scan(number_re, input)
    |> list.map(fn(match) { match.content })
    |> list.map(resultx.int_parse_unwrap)
  Price(#(x, y))
}

pub type Game {
  Game(button_a: Button, button_b: Button, price: Price)
}

pub type Price {
  Price(coord: grid.Coord)
}

pub type Button {
  Button(cost: Int, coord: grid.Coord)
}

pub fn pt_1(games: List(Game)) {
  games |> list.map(solve_game_naive) |> int.sum
}

fn solve_game_naive(game: Game) -> Int {
  let n = 100

  let a_presses =
    list.range(0, n)
    |> list.map(fn(i) {
      let coord = game.button_a.coord |> grid.multiply(i)
      Button(3 * i, coord)
    })

  let b_presses =
    list.range(0, n)
    |> list.map(fn(i) {
      let coord = game.button_b.coord |> grid.multiply(i)
      Button(i, coord)
    })

  let press_grid =
    a_presses
    |> list.map(fn(a_press) {
      b_presses
      |> list.map(fn(b_press) {
        let coord = grid.move_distance(a_press.coord, b_press.coord)
        let cost = a_press.cost + b_press.cost
        Button(cost, coord)
      })
    })

  let solutions =
    press_grid
    |> list.flat_map(fn(col) {
      col |> list.filter(fn(press) { press.coord == game.price.coord })
    })

  case solutions {
    [] -> 0
    [solution] -> solution.cost
    solutions ->
      solutions
      |> listx.min_by(fn(button) { button.cost })
      |> fn(solution) { solution.cost }
  }
}

pub fn pt_2(games: List(Game)) {
  games
  |> list.map(fn(game) {
    Game(
      game.button_a,
      game.button_b,
      Price(
        grid.move_distance(game.price.coord, #(
          10_000_000_000_000,
          10_000_000_000_000,
        )),
      ),
    )
  })
  |> list.map(solve_game)
  |> int.sum
}

fn solve_game(game: Game) -> Int {
  // (price_x - (price_y) * (b_x / b_y)) / (a_x -  a_y * b_x / b_y)
  let price_x = int.to_float(game.price.coord.0)
  let price_y = int.to_float(game.price.coord.1)

  let a_x = int.to_float(game.button_a.coord.0)
  let a_y = int.to_float(game.button_a.coord.1)

  let b_x = int.to_float(game.button_b.coord.0)
  let b_y = int.to_float(game.button_b.coord.1)

  let a_float = {
    { price_x -. { price_y *. { b_x /. b_y } } }
    /. { a_x -. { a_y *. { b_x /. b_y } } }
  }

  //b = (price_y - a * a_y) / b_y
  let b_float = { price_y -. { a_float *. a_y } } /. b_y

  let a = float.round(a_float)
  let b = float.round(b_float)

  case
    {
      grid.move_distance(
        grid.multiply(game.button_a.coord, a),
        grid.multiply(game.button_b.coord, b),
      )
    }
    == game.price.coord
  {
    True -> a * 3 + b
    False -> 0
  }
}
