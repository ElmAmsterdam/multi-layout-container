module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)

type Route = PaypalRoute | IdealRoute | NotFoundRoute

matchers : Parser (Route -> a) a
matchers = oneOf [
    map PaypalRoute top,
    map PaypalRoute (s "paypal"),
    map IdealRoute (s "ideal")
  ]

parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route -> route
    Nothing -> NotFoundRoute
