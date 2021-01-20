module Feed exposing
    ( Feed(..)
    , ProfileFeed(..)
    , fromString
    , profileFeedFromString
    , profileFeedToString
    , toString
    )

import Article.Tag
import User exposing (User)
import User.Username exposing (Username)



-- GENERAL


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



-- PROFILE


type ProfileFeed
    = OwnArticles Username
    | Favorited Username


profileFeedToString : Maybe User -> ProfileFeed -> String
profileFeedToString maybeUser feed =
    case feed of
        OwnArticles username ->
            case maybeUser of
                Nothing ->
                    User.Username.toString username ++ "'s Articles"

                Just user ->
                    if user.username == username then
                        "My Articles"

                    else
                        User.Username.toString username ++ "'s Articles"

        Favorited _ ->
            "Favorited Articles"


profileFeedFromString : String -> Username -> ProfileFeed
profileFeedFromString string profileOwner =
    case string of
        "Favorited Articles" ->
            Favorited profileOwner

        _ ->
            OwnArticles profileOwner
