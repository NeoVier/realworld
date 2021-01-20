module Article.Tag exposing (Tag, decoder, encoder, fromString, toString)

import Json.Decode exposing (Decoder)
import Json.Encode


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


encoder : Tag -> Json.Encode.Value
encoder (Tag tag) =
    Json.Encode.string tag
