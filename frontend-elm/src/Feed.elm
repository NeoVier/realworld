module Feed exposing (Feed(..), fromString, toString)

import Article.Tag
import User exposing (User)


type Feed
    = Global
    | Personal User
    | Tag Article.Tag.Tag


fromString : String -> Maybe User -> Feed
fromString string maybeUser =
    case ( string, maybeUser ) of
        ( "Global Feed", _ ) ->
            Global

        ( "Your Feed", Just user ) ->
            Personal user

        ( x, _ ) ->
            Tag <| Article.Tag.fromString <| String.dropLeft 1 x


toString : Feed -> String
toString feed =
    case feed of
        Global ->
            "Global Feed"

        Personal _ ->
            "Your Feed"

        Tag tag ->
            "#" ++ Article.Tag.toString tag
