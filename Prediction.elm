module Prediction exposing (Prediction, listDecoder)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode


type alias Prediction =
    { arrivalTime : Date
    , direction : Direction
    }


type Direction
    = Southbound
    | Northbound


listDecoder : Decoder (List Prediction)
listDecoder =
    Decode.field "data" (Decode.list decoder)


decoder : Decoder Prediction
decoder =
    Decode.map2 Prediction
        (Decode.at [ "attributes", "arrival_time" ] Decode.date)
        (Decode.at [ "attributes", "direction_id" ] directionDecoder)


directionDecoder : Decoder Direction
directionDecoder =
    Decode.int
        |> Decode.andThen (Decode.fromResult << parseDirection)


parseDirection : Int -> Result String Direction
parseDirection n =
    case n of
        0 ->
            Ok Southbound

        1 ->
            Ok Northbound

        _ ->
            Err <| "Cannot parse " ++ (toString n) ++ " as a direction."
