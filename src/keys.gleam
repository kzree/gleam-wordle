import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import util/letter

const key_row1 = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]

const key_row2 = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]

const key_row3 = ["z", "x", "c", "v", "b", "n", "m"]

pub fn view(past_inputs: List(String), word: String) -> Element(_) {
  html.div([attribute.class("flex flex-col items-center gap-2")], [
    view_row(key_row1, past_inputs, word),
    view_row(key_row2, past_inputs, word),
    view_row(key_row3, past_inputs, word),
  ])
}

fn view_row(
  keys: List(String),
  past_inputs: List(String),
  word: String,
) -> Element(_) {
  html.div([attribute.class("inline-flex gap-2")], {
    list.map(keys, fn(x) { view_key(x, past_inputs, word) })
  })
}

fn view_key(key: String, past_inputs: List(String), word: String) -> Element(_) {
  let status = letter.get_status_for_key_grid(key, word, past_inputs)
  html.div(
    [
      attribute.class(
        "grid place-items-center w-[43px] h-[58px] rounded-sm uppercase font-semibold",
      ),
      attribute.classes([
        #("bg-[--pico-form-element-background-color]", status == letter.Unused),
        #("opacity-30", status == letter.Incorrect),
        #("bg-[#c7aa40]", status == letter.InvalidPos),
        #("bg-[#288a3b]", status == letter.Correct),
      ]),
    ],
    [html.text(key)],
  )
}
