module Article exposing (Article, decoder)

import Article.Slug exposing (Slug)
import Article.Tag exposing (Tag)
import Iso8601
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Time
import User.Profile exposing (Profile)


type alias Article =
    { title : String
    , slug : Slug
    , body : String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , tagList : List Tag
    , description : String
    , author : Profile
    , favorited : Bool
    , favoritesCount : Int
    }


decoder : Decoder Article
decoder =
    Json.Decode.succeed Article
        |> JDP.required "title" Json.Decode.string
        |> JDP.required "slug" Article.Slug.decoder
        |> JDP.required "body" Json.Decode.string
        |> JDP.required "createdAt" Iso8601.decoder
        |> JDP.required "updatedAt" Iso8601.decoder
        |> JDP.required "tagList" (Json.Decode.list Article.Tag.decoder)
        |> JDP.required "description" Json.Decode.string
        |> JDP.required "author" User.Profile.decoder
        |> JDP.required "favorited" Json.Decode.bool
        |> JDP.required "favoritesCount" Json.Decode.int
