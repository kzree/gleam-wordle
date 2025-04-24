import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import keys
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import util/form
import util/letter

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
  let words = ["crank", "plate", "shave", "shard", "panic", "tangy"]

  list.sample(words, 1)
  |> list.last
  |> option.from_result
}

type GameState {
  Win
  Lose
  Active
}

type Model {
  Model(
    word: String,
    input: String,
    past_inputs: List(String),
    game_state: GameState,
  )
}

fn init(_) -> Model {
  let word = get_random_word()
  case word {
    option.Some(value) -> Model(value, "", [], Active)
    option.None -> Model("", "", [], Active)
  }
}

type Msg {
  UserTyped(input: String)
  UserGuessed(word: String)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserTyped(input) -> {
      let assert Ok(re) = regexp.from_string("^[a-zA-Z]*$")

      let matches_regex = regexp.check(re, input)
      let is_valid_length =
        string.trim(input) |> string.length <= max_word_length
      case matches_regex, is_valid_length {
        True, True -> {
          Model(..model, input: string.trim(input))
        }
        _, _ -> model
      }
    }
    UserGuessed(word) ->
      case string.length(word) == max_word_length {
        True -> {
          Model(
            ..model,
            game_state: case model.word == word {
              True -> Win
              False ->
                case list.length(model.past_inputs) + 1 == max_guesses {
                  True -> Lose
                  False -> Active
                }
            },
            input: "",
            past_inputs: list.append(model.past_inputs, [word]),
          )
        }
        False -> model
      }
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("container grid place-items-center")], [
    html.div(
      [attribute.class("max-w-[500px] py-24 w-full flex flex-col gap-16")],
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
        case model.game_state {
          Active -> element.none()
          Lose ->
            html.div([attribute.class("flex justify-center w-full text-xl")], [
              html.text("Loser!"),
            ])
          Win ->
            html.div([attribute.class("flex justify-center w-full text-xl")], [
              html.text("Winner!"),
            ])
        },
        html.form(
          [
            event.on_submit(fn(values: List(#(String, String))) -> Msg {
              let word = form.get_form_value(values, "word")
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
        keys.view(model.past_inputs, model.word),
      ],
    ),
  ])
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
  let letter_status = letter.get_status(model.word, letter)
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
        #("bg-[#c7aa40]", letter_status == letter.InvalidPos),
        #("bg-[#288a3b]", letter_status == letter.Correct),
      ]),
    ],
    [html.text(letter_val)],
  )
}
