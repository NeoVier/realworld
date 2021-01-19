module Slug exposing (Slug, fromString, toString)


type Slug
    = Slug String


toString : Slug -> String
toString (Slug slug) =
    slug


fromString : String -> Slug
fromString =
    Slug
