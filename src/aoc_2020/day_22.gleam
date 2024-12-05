import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  let assert [player_1_input, player_2_input] = string.split(input, "\n\n")

  use deck_1 <- result.try(parse_input_to_deck(player_1_input))
  use deck_2 <- result.try(parse_input_to_deck(player_2_input))

  let winning_deck = play_game(deck_1, deck_2)
  winning_deck |> calculate_winning_score |> Ok
}

fn parse_input_to_deck(input: String) {
  let assert [_, ..string_deck] =
    input
    |> string.split("\n")

  string_deck
  |> list.map(int.parse)
  |> result.all()
}

fn play_game(deck_1: List(Int), deck_2: List(Int)) -> List(Int) {
  use <- bool.guard(deck_2 == [], deck_1)
  use <- bool.guard(deck_1 == [], deck_2)

  let assert [card_1, ..deck_1] = deck_1
  let assert [card_2, ..deck_2] = deck_2

  case card_1 > card_2 {
    True -> play_game(list.flatten([deck_1, [card_1, card_2]]), deck_2)
    False -> play_game(deck_1, list.flatten([deck_2, [card_2, card_1]]))
  }
}

fn calculate_winning_score(deck: List(Int)) -> Int {
  deck
  |> list.reverse
  |> list.index_map(fn(card, i) { { i + 1 } * card })
  |> int.sum
}
// pub fn pt_2(input: String) {
//   todo as "part 2 not implemented"
// }
