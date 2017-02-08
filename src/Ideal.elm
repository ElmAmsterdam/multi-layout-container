module Ideal exposing (..)

import Html exposing (Html, div, text, hr, button, form, input)
import Html.Attributes exposing (class, type_, name, value)
import Html.Events exposing (onInput)

type alias Model = {
    email: String
  }

initialModel : Model
initialModel = {
    email = "emanuele@email4ideal.com"
  }

init : (Model, Cmd Msg)
init = (initialModel, Cmd.none)

-- VIEW

type Msg = ChangeEmail String

view : Model -> Html Msg
view model = div [] [
    text "Ideal form",
    form [] [
      input [
        type_ "email",
        name "email",
        value model.email,
        onInput ChangeEmail
      ] [],
      button [
        type_ "submit",
        class "button-primary"
      ] [ text "Pay" ]
    ]
  ]

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChangeEmail email -> ({ model | email = email }, Cmd.none)
