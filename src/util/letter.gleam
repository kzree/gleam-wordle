import gleam/list
import gleam/option
import gleam/string

pub type LetterStatus {
  Correct
  InvalidPos
  Incorrect
  Unused
}

pub fn get_status(word: String, letter: #(Int, String)) -> LetterStatus {
  let #(_, letter_val) = letter
  let is_letter_in_word = string.contains(word, letter_val)
  let is_letter_in_correct_pos = check_if_letter_in_correct_pos(word, letter)
  case is_letter_in_word, is_letter_in_correct_pos {
    True, True -> Correct
    True, False -> InvalidPos
    False, _ -> Incorrect
  }
}

pub fn get_status_for_key_grid(
  key: String,
  word: String,
  past_inputs: List(String),
) -> LetterStatus {
  let is_key_present = string.join(past_inputs, "") |> string.contains(key)
  let is_key_in_word = string.contains(word, key)
  let is_key_correct = case is_key_in_word {
    True -> check_if_key_in_correct_pos(key, word, past_inputs)
    False -> False
  }

  case is_key_present, is_key_in_word, is_key_correct {
    True, True, True -> Correct
    True, True, False -> InvalidPos
    True, False, False -> Incorrect
    _, _, _ -> Unused
  }
}

fn check_if_key_in_correct_pos(
  key: String,
  word: String,
  past_inputs: List(String),
) -> Bool {
  let last_input = list.last(past_inputs) |> option.from_result
  case last_input {
    option.None -> False
    option.Some(input) -> {
      let letter =
        string.split(input, "")
        |> list.index_map(fn(x, i) { #(i, x) })
        |> list.find(fn(val) {
          let #(_, x) = val
          x == key
        })

      case letter {
        Ok(x) -> check_if_letter_in_correct_pos(word, x)
        Error(_) -> False
      }
    }
  }
}

fn check_if_letter_in_correct_pos(word: String, letter: #(Int, String)) -> Bool {
  let #(idx, letter_val) = letter
  let res =
    string.split(word, "")
    |> list.index_map(fn(x, i) { #(i, x) })
    |> list.find(fn(val) {
      let #(i, x) = val
      i == idx && x == letter_val
    })
    |> option.from_result

  case res {
    option.Some(_) -> True
    option.None -> False
  }
}
