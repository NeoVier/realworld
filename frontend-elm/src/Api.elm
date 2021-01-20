module Api exposing (favoriteArticle, fetchFeed, listTags, login, unfavoriteArticle)

import Article exposing (Article)
import Feed exposing (Feed)
import Http
import Json.Decode
import Json.Encode
import Slug
import Tag exposing (Tag)
import User exposing (User)


baseUrl : String
baseUrl =
    "https://conduit.productionready.io/api"


signedRequest :
    { method : String
    , user : User
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
signedRequest { method, user, url, body, expect, timeout, tracker } =
    optionallySignedRequest
        { method = method
        , user = Just user
        , url = url
        , body = body
        , expect = expect
        , timeout = timeout
        , tracker = tracker
        }


optionallySignedRequest :
    { method : String
    , user : Maybe User
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
optionallySignedRequest { method, user, url, body, expect, timeout, tracker } =
    Http.request
        { method = method
        , headers =
            case user of
                Nothing ->
                    []

                Just u ->
                    [ Http.header "Authorization" <| "Token " ++ u.token ]
        , url = url
        , body = body
        , expect = expect
        , timeout = timeout
        , tracker = tracker
        }


fetchFeed : Feed -> Maybe User -> (Result Http.Error (List Article) -> msg) -> Cmd msg
fetchFeed feed maybeUser toMsg =
    case feed of
        Feed.Global ->
            optionallySignedRequest
                { method = "GET"
                , user = maybeUser
                , url = baseUrl ++ "/articles"
                , body = Http.emptyBody
                , expect = Http.expectJson toMsg (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                , timeout = Nothing
                , tracker = Nothing
                }

        Feed.Personal user ->
            signedRequest
                { method = "GET"
                , user = user
                , url = baseUrl ++ "/articles/feed"
                , body = Http.emptyBody
                , expect = Http.expectJson toMsg (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                , timeout = Nothing
                , tracker = Nothing
                }

        Feed.Tag tag ->
            optionallySignedRequest
                { method = "GET"
                , user = maybeUser
                , url = baseUrl ++ "/articles?tag=" ++ Tag.toString tag
                , body = Http.emptyBody
                , expect = Http.expectJson toMsg (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                , timeout = Nothing
                , tracker = Nothing
                }


favoriteArticle : Article -> User -> (Result Http.Error Article -> msg) -> Cmd msg
favoriteArticle article user toMsg =
    signedRequest
        { method = "POST"
        , user = user
        , url = baseUrl ++ "/articles/" ++ Slug.toString article.slug ++ "/favorite"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }


unfavoriteArticle : Article -> User -> (Result Http.Error Article -> msg) -> Cmd msg
unfavoriteArticle article user toMsg =
    signedRequest
        { method = "DELETE"
        , user = user
        , url = baseUrl ++ "/articles/" ++ Slug.toString article.slug ++ "/favorite"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }


listTags : (Result Http.Error (List Tag) -> msg) -> Cmd msg
listTags toMsg =
    Http.get
        { url = baseUrl ++ "/tags"
        , expect =
            Http.expectJson toMsg
                (Json.Decode.field "tags" (Json.Decode.list Tag.decoder))
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
