import gleam/int
import lustre
import lustre/attribute
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#dispatch-widget", Nil)
  Nil
}

type Model {
  Model(available: Int, in_flight: Int)
}

type Message {
  Dispatch
  Recall
}

fn init(_arguments: Nil) -> Model {
  Model(available: 7, in_flight: 3)
}

fn update(model: Model, message: Message) -> Model {
  case message {
    Dispatch if model.available > 0 ->
      Model(available: model.available - 1, in_flight: model.in_flight + 1)
    Recall if model.in_flight > 0 ->
      Model(available: model.available + 1, in_flight: model.in_flight - 1)
    _ -> model
  }
}

fn view(model: Model) {
  html.section([attribute.class("dispatch-island")], [
    html.div([attribute.class("dispatch-copy")], [
      html.span([attribute.class("dispatch-label")], [
        html.text("Live operations"),
      ]),
      html.h3([], [html.text("Rooftop dispatch")]),
      html.p([], [
        html.text(
          "Send the next available courier into the skies, or recall one for a well-earned snack.",
        ),
      ]),
    ]),
    html.div([attribute.class("dispatch-controls")], [
      html.div([attribute.class("dispatch-counts")], [
        metric("Available", model.available),
        metric("In flight", model.in_flight),
      ]),
      html.div([attribute.class("dispatch-buttons")], [
        html.button(
          [
            attribute.class("dispatch-secondary"),
            attribute.disabled(model.in_flight == 0),
            event.on_click(Recall),
          ],
          [html.text("Recall one")],
        ),
        html.button(
          [
            attribute.class("dispatch-primary"),
            attribute.disabled(model.available == 0),
            event.on_click(Dispatch),
          ],
          [html.text("Dispatch pigeon →")],
        ),
      ]),
    ]),
  ])
}

fn metric(label: String, value: Int) {
  html.div([], [
    html.span([], [html.text(label)]),
    html.strong([], [html.text(int.to_string(value))]),
  ])
}
