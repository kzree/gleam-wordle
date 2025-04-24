import gleeunit/should
import util/letter

const test_word = "abcde"

const past_inputs = ["klmno", "abecd"]

pub fn get_status_correct_test() {
  letter.get_status(test_word, #(0, "a"))
  |> should.equal(letter.Correct)
}

pub fn get_status_invalid_test() {
  letter.get_status(test_word, #(1, "a"))
  |> should.equal(letter.InvalidPos)
}

pub fn get_status_incorrect_test() {
  letter.get_status(test_word, #(0, "x"))
  |> should.equal(letter.Incorrect)
}

pub fn get_status_for_key_correct_test() {
  letter.get_status_for_key_grid("a", test_word, past_inputs)
  |> should.equal(letter.Correct)
}

pub fn get_status_for_key_invalid_test() {
  letter.get_status_for_key_grid("c", test_word, past_inputs)
  |> should.equal(letter.InvalidPos)
}

pub fn get_status_for_key_incorrect_test() {
  letter.get_status_for_key_grid("k", test_word, past_inputs)
  |> should.equal(letter.Incorrect)
}

pub fn get_status_for_key_unused_test() {
  letter.get_status_for_key_grid("x", test_word, past_inputs)
  |> should.equal(letter.Unused)
}
