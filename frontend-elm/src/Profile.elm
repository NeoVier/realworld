module Profile exposing (Profile, decoder)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import User exposing (Username)


type alias Profile =
    { username : Username
    , bio : String
    , image : String
    , following : Bool
    }


decoder : Decoder Profile
decoder =
    Json.Decode.succeed Profile
        |> JDP.required "username" User.decoder
        |> JDP.optional "bio" Json.Decode.string ""
        |> JDP.required "image" Json.Decode.string
        |> JDP.required "following" Json.Decode.bool
