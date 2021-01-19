module Tag exposing (Tag, decoder, fromString, toString)

import Json.Decode exposing (Decoder)


type Tag
    = Tag String


fromString : String -> Tag
fromString =
    Tag


toString : Tag -> String
toString (Tag tag) =
    tag


decoder : Decoder Tag
decoder =
    Json.Decode.map Tag Json.Decode.string
