module RedLineTrains exposing (main)

import Html exposing (Html)
import Http
import Stop exposing (Stop)


type Model
    = LoadingStops
    | DisplayingStops (List Stop)


type Msg
    = StopsLoaded (Result Http.Error (List Stop))


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : ( Model, Cmd Msg )
init =
    ( LoadingStops, fetchStopsCmd )


fetchStopsCmd : Cmd Msg
fetchStopsCmd =
    Http.send StopsLoaded getStopsRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StopsLoaded (Err error) ->
            Debug.crash <| toString error

        StopsLoaded (Ok stops) ->
            ( DisplayingStops stops, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    Html.text <| toString model


getStopsUrl : String
getStopsUrl =
    "https://api-v3.mbta.com/stops?filter[route]=Red"


getStopsRequest : Http.Request (List Stop)
getStopsRequest =
    Http.get getStopsUrl Stop.listDecoder
