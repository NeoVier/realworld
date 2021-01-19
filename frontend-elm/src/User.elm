module User exposing (User, decoder)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import User.Username as Username exposing (Username)


type alias User =
    { email : String
    , token : String
    , username : Username
    , bio : String
    , image : String
    }


decoder : Decoder User
decoder =
    Json.Decode.succeed User
        |> JDP.required "email" Json.Decode.string
        |> JDP.required "token" Json.Decode.string
        |> JDP.required "username" Username.decoder
        |> JDP.optional "bio" Json.Decode.string ""
        |> JDP.optional "image" Json.Decode.string "https://static.productionready.io/images/smiley-cyrus.jpg"
