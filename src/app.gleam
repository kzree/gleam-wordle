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
            past_inputs: list.reverse([word, ..model.past_inputs]),
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
      [attribute.class("max-w-[500px] py-12 w-full flex flex-col gap-4")],
      [
        html.div([], [
          html.h1([attribute.class("text-4xl text-center capitalize")], [
            html.text(model.word),
          ]),
        ]),
        html.div([], [
          html.ul([attribute.class("flex flex-col items-center gap-2")], {
            list.map(model.past_inputs, view_guess)
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

fn view_guess(guess: String) -> Element(Msg) {
  html.div([attribute.class("flex gap-2")], {
    list.map(string.split(guess, ""), view_letter)
  })
}

fn view_letter(letter: String) -> Element(Msg) {
  html.span(
    [
      attribute.class(
        "w-[52px] h-[52px] text-2xl font-bold text-center grid place-items-center uppercase",
      ),
      attribute.class(
        "border border-[--pico-form-element-border-color] rounded-sm",
      ),
    ],
    [html.text(letter)],
  )
}
