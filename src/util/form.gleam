import gleam/list
import gleam/option.{type Option}
import gleam/result

pub fn get_form_value(
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
