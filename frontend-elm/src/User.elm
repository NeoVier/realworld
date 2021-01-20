module User exposing (User, decoder, encoder)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode
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


encoder : User -> Json.Encode.Value
encoder { email, token, username, bio, image } =
    Json.Encode.object
        [ ( "email", Json.Encode.string email )
        , ( "token", Json.Encode.string token )
        , ( "username", Username.encoder username )
        , ( "bio", Json.Encode.string bio )
        , ( "image", Json.Encode.string image )
        ]
