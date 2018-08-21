module RedLineTrains exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Prediction exposing (Prediction)
import Stop exposing (Stop)


type Model
    = LoadingStops
    | DisplayingStops (List Stop)
    | LoadingTimes Stop
    | DisplayingPredictions Stop (List Prediction)


type Msg
    = StopsLoaded (Result Http.Error (List Stop))
    | StopSelected Stop
    | PredictionsLoaded Stop (Result Http.Error (List Prediction))


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

        PredictionsLoaded _ (Err error) ->
            Debug.crash <| toString error

        PredictionsLoaded stop (Ok predictions) ->
            ( DisplayingPredictions stop predictions, Cmd.none )

        StopSelected stop ->
            ( LoadingTimes stop, fetchPredictionsCmd stop )



subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    case model of
        LoadingStops ->
            h1 [] [ text "Loading stops..." ]

        DisplayingStops stops ->
            ol [] <| List.map viewStop stops

        LoadingTimes stop ->
            h1 [] [ text "Loading times..." ]

        DisplayingPredictions stop predictions ->
            div
                []
                [ h1 [] [ text <| "Arrival times for " ++ stop.name ]
                , text <| toString predictions
                ]


viewStop : Stop -> Html Msg
viewStop stop =
    li []
        [ a
            [ href "#"
            , onClick <| StopSelected stop
            ]
            [ text stop.name ]
        ]


getStopsUrl : String
getStopsUrl =
    "https://api-v3.mbta.com/stops?filter[route]=Red"

getPredictionsUrl : Stop -> String
getPredictionsUrl stop =
    "https://api-v3.mbta.com/predictions?filter[route]=Red&filter[stop]=" ++ stop.id

getStopsRequest : Http.Request (List Stop)
getStopsRequest =
    Http.get getStopsUrl Stop.listDecoder


fetchPredictionsCmd : Stop -> Cmd Msg
fetchPredictionsCmd stop =
    Http.send (PredictionsLoaded stop) <| getPredictionsRequest stop


getPredictionsRequest : Stop -> Http.Request (List Prediction)
getPredictionsRequest stop =
    Http.get (getPredictionsUrl stop) Prediction.listDecoder
