module Stop exposing (Stop, listDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias Stop =
    { id : String
    , name : String
    }


decoder : Decoder Stop
decoder =
    Decode.map2 Stop
        (Decode.field "id" Decode.string)
        (Decode.at [ "attributes", "name" ] Decode.string)


listDecoder : Decoder (List Stop)
listDecoder =
    Decode.field "data" <| Decode.list decoder
