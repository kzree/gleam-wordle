import gleeunit/should
import util/form

const values = [#("a", "b"), #("c", "d")]

pub fn get_value_from_values_test() {
  form.get_form_value(values, "c")
  |> should.be_some
}

pub fn get_invalid_value_from_values_test() {
  form.get_form_value(values, "d")
  |> should.be_none
}
