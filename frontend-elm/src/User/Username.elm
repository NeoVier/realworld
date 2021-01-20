module User.Username exposing (Username, decoder, encoder, fromString, toString)

import Json.Decode exposing (Decoder)
import Json.Encode


type Username
    = Username String


fromString : String -> Username
fromString =
    Username


toString : Username -> String
toString (Username username) =
    username


decoder : Decoder Username
decoder =
    Json.Decode.map Username Json.Decode.string


encoder : Username -> Json.Encode.Value
encoder (Username username) =
    Json.Encode.string username
