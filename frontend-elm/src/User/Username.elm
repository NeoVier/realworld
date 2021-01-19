module User.Username exposing (Username, decoder, fromString, toString)

import Json.Decode exposing (Decoder)


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
