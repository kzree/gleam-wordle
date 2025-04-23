import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

const max_word_length = 5

const max_guesses = 6

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.simple(init, update, view)

  lustre.register(component, "wordle-app")
}

pub fn element() -> Element(msg) {
  element.element("wordle-app", [], [])
}

fn get_random_word() {
  let words = ["crank", "plate"]

  list.sample(words, 1)
  |> list.last
  |> option.from_result
}

type Model {
  Model(word: String, input: String, past_inputs: List(String))
}

fn init(_) -> Model {
  let word = get_random_word()
  case word {
    option.Some(value) -> Model(value, "", [])
    option.None -> Model("", "", [])
  }
}

type Msg {
  UserTyped(input: String)
  UserGuessed(word: String)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserTyped(input) ->
      case string.length(string.trim(input)) <= max_word_length {
        True -> {
          Model(..model, input: string.trim(input))
        }
        False -> model
      }
    UserGuessed(word) ->
      case string.length(word) == max_word_length {
        True -> {
          Model(
            ..model,
            input: "",
            past_inputs: list.append(model.past_inputs, [word]),
          )
        }
        False -> model
      }
  }
}

fn get_form_value(
  values: List(#(String, String)),
  list_key: String,
) -> Option(String) {
  list.find(values, fn(pair) {
    let #(key, _) = pair
    key == list_key
  })
  |> result.map(fn(res) -> String {
    let #(_, value) = res
    value
  })
  |> option.from_result
}

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("container grid place-items-center")], [
    html.div(
      [attribute.class("max-w-[500px] py-12 w-full flex flex-col gap-16")],
      [
        html.div([], [
          html.ul([attribute.class("flex flex-col items-center gap-2")], {
            let empty_options =
              list.repeat("", max_guesses - list.length(model.past_inputs))
            list.append(model.past_inputs, empty_options)
            |> list.map(fn(x) {
              case x {
                "" -> view_empty_line(model)
                _ -> view_guess(x, model)
              }
            })
          }),
        ]),
        html.form(
          [
            event.on_submit(fn(values: List(#(String, String))) -> Msg {
              let word = get_form_value(values, "word")
              case word {
                option.Some(word) -> UserGuessed(word)
                option.None -> UserGuessed("")
              }
            }),
          ],
          [
            html.input([
              attribute.value(model.input),
              attribute.name("word"),
              event.on_input(UserTyped),
            ]),
          ],
        ),
      ],
    ),
  ])
}

type LetterStatus {
  Correct
  InvalidPos
  Incorrect
}

fn get_letter_status(word: String, letter: #(Int, String)) {
  let #(_, letter_val) = letter
  let is_letter_in_word = string.contains(word, letter_val)
  let is_letter_in_correct_pos = check_if_letter_in_correct_pos(word, letter)
  case is_letter_in_word {
    True ->
      case is_letter_in_correct_pos {
        True -> Correct
        False -> InvalidPos
      }
    False -> Incorrect
  }
}

fn check_if_letter_in_correct_pos(word: String, letter: #(Int, String)) {
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

fn view_empty_line(model: Model) -> Element(Msg) {
  html.div([attribute.class("flex gap-2")], {
    list.map(
      list.repeat(" ", max_word_length)
        |> list.index_map(fn(x, i) { #(i, x) }),
      fn(x) { view_letter(x, model) },
    )
  })
}

fn view_guess(guess: String, model: Model) -> Element(Msg) {
  html.div([attribute.class("flex gap-2")], {
    list.map(
      string.split(guess, "")
        |> list.index_map(fn(x, i) { #(i, x) }),
      fn(x) { view_letter(x, model) },
    )
  })
}

fn view_letter(letter: #(Int, String), model: Model) -> Element(Msg) {
  let letter_status = get_letter_status(model.word, letter)
  let #(_, letter_val) = letter
  html.span(
    [
      attribute.class(
        "w-[52px] h-[52px] text-2xl font-bold text-center grid place-items-center uppercase",
      ),
      attribute.class(
        "border border-[--pico-form-element-border-color] rounded-sm",
      ),
      attribute.classes([
        #("bg-[#c7aa40]", letter_status == InvalidPos),
        #("bg-[#288a3b]", letter_status == Correct),
      ]),
    ],
    [html.text(letter_val)],
  )
}
