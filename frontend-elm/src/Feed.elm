module Feed exposing (Feed(..), fromString, toString)

import Tag
import User exposing (User)


type Feed
    = Global
    | Personal User
    | Tag Tag.Tag


fromString : String -> Maybe User -> Feed
fromString string maybeUser =
    case ( string, maybeUser ) of
        ( "Global Feed", _ ) ->
            Global

        ( "Your Feed", Just user ) ->
            Personal user

        ( x, _ ) ->
            Tag <| Tag.fromString <| String.dropLeft 1 x


toString : Feed -> String
toString feed =
    case feed of
        Global ->
            "Global Feed"

        Personal _ ->
            "Your Feed"

        Tag tag ->
            "#" ++ Tag.toString tag
