module App exposing (..)

import Task
import Dict exposing (..)
import Html exposing (Html, div, text, hr, button, form, input)
import Html.Attributes exposing (class, action, type_, name, value)
import Html.Events exposing (onInput, onClick)
import Navigation exposing (Location)

import Routing exposing (Route(..), parseLocation)

import Paypal
import Ideal


type alias Model = {
    paypalModel: Paypal.Model,
    idealModel: Ideal.Model,

    positions: List String,
    position: String,
    tabs: List String,
    tab: String,
    email: String
  }

tabs : List String
tabs = ["Paypal", "Ideal"]

positions : List String
positions = ["top", "left", "right", "bottom"]

initialModel : Model
initialModel = {
    paypalModel = Paypal.initialModel,
    idealModel = Ideal.initialModel,
    positions = positions,
    position = "top",
    tabs = tabs,
    tab = "Paypal",
    email = "emanuele@lostcrew.it"
  }

init : Location -> (Model, Cmd Msg)
init location = (initialModel, Task.perform OnLocationChange (Task.succeed location))

-- VIEW

type Msg =
  PaypalMsg Paypal.Msg |
  IdealMsg Ideal.Msg |
  OnLocationChange Location |
  ChangePosition String |
  ChangeTab String |
  ChangeEmail String

positionView : Model -> String -> Html Msg
positionView model position = button [
    type_ "button",
    class (if model.position == position then "button-primary" else ""),
    onClick (ChangePosition position)
  ] [ text position ]

tabView : Model -> String -> Html Msg
tabView model tab = button [
    type_ "button",
    class ("tabs__button " ++ (if model.tab == tab then "button-primary" else "")),
    onClick (ChangeTab tab)
  ] [ text tab ]

tabContentView : Model -> Html Msg
tabContentView model =
  case model.tab of
    "Paypal" -> Html.map PaypalMsg (Paypal.view model.paypalModel)
    "Ideal" -> Html.map IdealMsg (Ideal.view model.idealModel)
    _ -> div [] [ text "Uhmf." ]

view : Model -> Html Msg
view model = div [] [
    div [ class "position-switcher" ] (List.map (positionView model) model.positions),
    div [ class "main"] [
      div [ class ("tabs tabs--" ++ model.position) ] [
        div [ class "tabs__bar" ] (List.map (tabView model) model.tabs),
        div [ class "tabs__content" ] [ tabContentView model ]
      ]
    ]
  ]

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PaypalMsg paypalMsg ->
      let (paypalModel, paypalCmd) = Paypal.update paypalMsg model.paypalModel
      in ({ model | paypalModel = paypalModel }, Cmd.map PaypalMsg paypalCmd)
    IdealMsg idealMsg ->
      let (idealModel, idealCmd) = Ideal.update idealMsg model.idealModel
      in ({ model | idealModel = idealModel }, Cmd.map IdealMsg idealCmd)

    OnLocationChange location ->
      case parseLocation location of
        PaypalRoute -> (model, Task.perform ChangeTab (Task.succeed "Paypal"))
        IdealRoute -> (model,  Task.perform ChangeTab (Task.succeed "Ideal"))
        NotFoundRoute -> (model, Cmd.none)

    ChangePosition position ->
      ({ model | position = position }, Cmd.none)
    ChangeTab tab ->
      ({ model | tab = tab }, Cmd.none)
    ChangeEmail email ->
      ({ model | email = email }, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- MAIN

main : Program Never Model Msg
main = Navigation.program OnLocationChange {
    init = init,
    view = view,
    update = update,
    subscriptions = subscriptions
  }
