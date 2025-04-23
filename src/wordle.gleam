import app
import lustre
import lustre/element.{type Element}

pub fn main() {
  let wordle = lustre.simple(init, update, view)
  let assert Ok(_) = app.register()
  let assert Ok(_) = lustre.start(wordle, "#app", Nil)

  Nil
}

type Model =
  Nil

fn init(_) -> Model {
  Nil
}

type Msg =
  Nil

fn update(_, _) -> Model {
  Nil
}

fn view(_) -> Element(Msg) {
  app.element()
}
