module Article.Comment exposing (Comment, decoder)

import Iso8601
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Time
import User.Profile exposing (Profile)


type alias Comment =
    { createdAt : Time.Posix
    , updatedAt : Time.Posix
    , body : String
    , author : Profile
    }


decoder : Decoder Comment
decoder =
    Json.Decode.succeed Comment
        |> JDP.required "createdAt" Iso8601.decoder
        |> JDP.required "updatedAt" Iso8601.decoder
        |> JDP.required "body" Json.Decode.string
        |> JDP.required "author" User.Profile.decoder
