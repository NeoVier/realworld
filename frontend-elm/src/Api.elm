module Api exposing (createArticle, favoriteArticle, fetchArticle, fetchFeed, fetchUser, listTags, login, register, unfavoriteArticle, updateArticle)

import Article exposing (Article)
import Article.Slug exposing (Slug)
import Article.Tag exposing (Tag)
import Feed exposing (Feed)
import Http
import Json.Decode
import Json.Encode
import User exposing (User)



-- INTERNALS


baseUrl : String
baseUrl =
    "https://conduit.productionready.io/api"


signedRequest :
    { method : String
    , userToken : String
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
signedRequest { method, userToken, url, body, expect, timeout, tracker } =
    optionallySignedRequest
        { method = method
        , userToken = Just userToken
        , url = url
        , body = body
        , expect = expect
        , timeout = timeout
        , tracker = tracker
        }


optionallySignedRequest :
    { method : String
    , userToken : Maybe String
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
optionallySignedRequest { method, userToken, url, body, expect, timeout, tracker } =
    Http.request
        { method = method
        , headers =
            case userToken of
                Nothing ->
                    []

                Just token ->
                    [ Http.header "Authorization" <| "Token " ++ token ]
        , url = url
        , body = body
        , expect = expect
        , timeout = timeout
        , tracker = tracker
        }



-- ARTICLES


fetchFeed : Feed -> Maybe User -> (Result Http.Error (List Article) -> msg) -> Cmd msg
fetchFeed feed maybeUser toMsg =
    case feed of
        Feed.Global ->
            optionallySignedRequest
                { method = "GET"
                , userToken = Maybe.map .token maybeUser
                , url = baseUrl ++ "/articles"
                , body = Http.emptyBody
                , expect = Http.expectJson toMsg (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                , timeout = Nothing
                , tracker = Nothing
                }

        Feed.Personal user ->
            signedRequest
                { method = "GET"
                , userToken = user.token
                , url = baseUrl ++ "/articles/feed"
                , body = Http.emptyBody
                , expect = Http.expectJson toMsg (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                , timeout = Nothing
                , tracker = Nothing
                }

        Feed.Tag tag ->
            optionallySignedRequest
                { method = "GET"
                , userToken = Maybe.map .token maybeUser
                , url = baseUrl ++ "/articles?tag=" ++ Article.Tag.toString tag
                , body = Http.emptyBody
                , expect = Http.expectJson toMsg (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                , timeout = Nothing
                , tracker = Nothing
                }


favoriteArticle : Article -> User -> (Result Http.Error Article -> msg) -> Cmd msg
favoriteArticle article user toMsg =
    signedRequest
        { method = "POST"
        , userToken = user.token
        , url = baseUrl ++ "/articles/" ++ Article.Slug.toString article.slug ++ "/favorite"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }


unfavoriteArticle : Article -> User -> (Result Http.Error Article -> msg) -> Cmd msg
unfavoriteArticle article user toMsg =
    signedRequest
        { method = "DELETE"
        , userToken = user.token
        , url = baseUrl ++ "/articles/" ++ Article.Slug.toString article.slug ++ "/favorite"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }


fetchArticle : Slug -> (Result Http.Error Article -> msg) -> Cmd msg
fetchArticle slug toMsg =
    Http.get
        { url = baseUrl ++ "/articles" ++ Article.Slug.toString slug
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        }


createArticle :
    { title : String, description : String, body : String, tagList : List Tag }
    -> User
    -> (Result Http.Error Article -> msg)
    -> Cmd msg
createArticle { title, description, body, tagList } user toMsg =
    signedRequest
        { method = "POST"
        , userToken = user.token
        , url = baseUrl ++ "/articles"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "article"
                      , Json.Encode.object
                            [ ( "title", Json.Encode.string title )
                            , ( "description", Json.Encode.string description )
                            , ( "body", Json.Encode.string body )
                            , ( "tagList", Json.Encode.list Article.Tag.encoder tagList )
                            ]
                      )
                    ]
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }


updateArticle :
    { title : String, description : String, body : String, tagList : List Tag }
    -> Article.Slug.Slug
    -> User
    -> (Result Http.Error Article -> msg)
    -> Cmd msg
updateArticle { title, description, body, tagList } slug user toMsg =
    signedRequest
        { method = "PUT"
        , userToken = user.token
        , url = baseUrl ++ "/articles/" ++ Article.Slug.toString slug
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "article"
                      , Json.Encode.object
                            [ ( "title", Json.Encode.string title )
                            , ( "description", Json.Encode.string description )
                            , ( "body", Json.Encode.string body )
                            , ( "tagList", Json.Encode.list Article.Tag.encoder tagList )
                            ]
                      )
                    ]
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }



-- TAGS


listTags : (Result Http.Error (List Tag) -> msg) -> Cmd msg
listTags toMsg =
    Http.get
        { url = baseUrl ++ "/tags"
        , expect =
            Http.expectJson toMsg
                (Json.Decode.field "tags" (Json.Decode.list Article.Tag.decoder))
        }



-- AUTHENTICATION


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
                            , ( "password", Json.Encode.string password )
                            ]
                      )
                    ]
        , expect = Http.expectJson toMsg (Json.Decode.field "user" User.decoder)
        }


register :
    { username : String, email : String, password : String }
    -> (Result Http.Error User -> msg)
    -> Cmd msg
register { username, email, password } toMsg =
    Http.post
        { url = baseUrl ++ "/users"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "user"
                      , Json.Encode.object
                            [ ( "username", Json.Encode.string username )
                            , ( "email", Json.Encode.string email )
                            , ( "password", Json.Encode.string password )
                            ]
                      )
                    ]
        , expect = Http.expectJson toMsg (Json.Decode.field "user" User.decoder)
        }


fetchUser : String -> (Result Http.Error User -> msg) -> Cmd msg
fetchUser token toMsg =
    signedRequest
        { method = "GET"
        , userToken = token
        , url = baseUrl ++ "/user"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg (Json.Decode.field "user" User.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }
