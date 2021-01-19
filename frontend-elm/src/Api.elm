module Api exposing (listArticles, login)

import Article exposing (Article)
import Http
import Json.Decode
import Json.Encode
import User exposing (User)


baseUrl : String
baseUrl =
    "https://conduit.productionready.io/api"


listArticles : (Result Http.Error (List Article) -> msg) -> Cmd msg
listArticles toMsg =
    Http.get
        { url = baseUrl ++ "/articles"
        , expect =
            Http.expectJson toMsg
                (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
        }


login : { email : String, password : String } -> (Result Http.Error User -> msg) -> Cmd msg
login { email, password } toMsg =
    Http.post
        { url = baseUrl ++ "/users/login"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "user"
                      , Json.Encode.object
                            [ ( "email", Json.Encode.string email )
                            , ( "password"
                              , Json.Encode.string password
                              )
                            ]
                      )
                    ]
        , expect = Http.expectJson toMsg (Json.Decode.field "user" User.decoder)
        }
