import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.simple(init, update, view)

  lustre.register(component, "wordle-app")
}

pub fn element() -> Element(msg) {
  element.element("wordle-app", [], [])
}

type Model {
  Model(word: String, input: String, past_inputs: List(String))
}

fn init(_) -> Model {
  Model("", "", [])
}

type Msg {
  UserTyped(input: String)
  UserGuessed(word: String)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserTyped(input) ->
      case string.length(string.trim(input)) <= 6 {
        True -> {
          Model(..model, input: string.trim(input))
        }
        False -> model
      }
    UserGuessed(word) ->
      case string.length(word) == 6 {
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
  html.div([attribute.class("container")], [
    html.div([], [html.ul([], { list.map(model.past_inputs, view_guess) })]),
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
  ])
}

fn view_guess(guess: String) -> Element(Msg) {
  html.li([], [html.text(guess)])
}
