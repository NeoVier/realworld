module Article.Slug exposing (Slug, decoder, fromString, toString)

import Json.Decode exposing (Decoder)


type Slug
    = Slug String


toString : Slug -> String
toString (Slug slug) =
    slug


fromString : String -> Slug
fromString =
    Slug


decoder : Decoder Slug
decoder =
    Json.Decode.map Slug Json.Decode.string
