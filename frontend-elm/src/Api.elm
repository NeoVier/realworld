module Api exposing (createArticle, favoriteArticle, fetchArticle, fetchFeed, fetchProfile, fetchProfileFeed, fetchUser, followUser, listTags, login, register, unfavoriteArticle, unfollowUser, updateArticle, updateUser)

import Article exposing (Article)
import Article.Slug exposing (Slug)
import Article.Tag exposing (Tag)
import Feed exposing (Feed)
import Http
import Json.Decode
import Json.Encode
import User exposing (User)
import User.Profile exposing (Profile)
import User.Username exposing (Username)



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
    }
    -> Cmd msg
signedRequest { method, userToken, url, body, expect } =
    optionallySignedRequest
        { method = method
        , userToken = Just userToken
        , url = url
        , body = body
        , expect = expect
        }


optionallySignedRequest :
    { method : String
    , userToken : Maybe String
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    }
    -> Cmd msg
optionallySignedRequest { method, userToken, url, body, expect } =
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
        , timeout = Nothing
        , tracker = Nothing
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
                }

        Feed.Personal user ->
            signedRequest
                { method = "GET"
                , userToken = user.token
                , url = baseUrl ++ "/articles/feed"
                , body = Http.emptyBody
                , expect = Http.expectJson toMsg (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                }

        Feed.Tag tag ->
            optionallySignedRequest
                { method = "GET"
                , userToken = Maybe.map .token maybeUser
                , url = baseUrl ++ "/articles?tag=" ++ Article.Tag.toString tag
                , body = Http.emptyBody
                , expect =
                    Http.expectJson toMsg
                        (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
                }


fetchProfileFeed :
    Feed.ProfileFeed
    -> Maybe User
    -> (Result Http.Error (List Article) -> msg)
    -> Cmd msg
fetchProfileFeed feed maybeUser toMsg =
    let
        endpoint =
            case feed of
                Feed.OwnArticles owner ->
                    "/articles?author=" ++ User.Username.toString owner

                Feed.Favorited owner ->
                    "/articles?favorited=" ++ User.Username.toString owner
    in
    optionallySignedRequest
        { method = "GET"
        , userToken = Maybe.map .token maybeUser
        , url = baseUrl ++ endpoint
        , body = Http.emptyBody
        , expect =
            Http.expectJson toMsg
                (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
        }


favoriteArticle : Article -> User -> (Result Http.Error Article -> msg) -> Cmd msg
favoriteArticle article user toMsg =
    signedRequest
        { method = "POST"
        , userToken = user.token
        , url = baseUrl ++ "/articles/" ++ Article.Slug.toString article.slug ++ "/favorite"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
        }


unfavoriteArticle : Article -> User -> (Result Http.Error Article -> msg) -> Cmd msg
unfavoriteArticle article user toMsg =
    signedRequest
        { method = "DELETE"
        , userToken = user.token
        , url = baseUrl ++ "/articles/" ++ Article.Slug.toString article.slug ++ "/favorite"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg (Json.Decode.field "article" Article.decoder)
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
        }


updateUser :
    String
    ->
        { email : Maybe String
        , username : Maybe User.Username.Username
        , password : Maybe String
        , image : Maybe String
        , bio : Maybe String
        }
    -> (Result Http.Error User -> msg)
    -> Cmd msg
updateUser token { email, username, password, image, bio } toMsg =
    let
        encodeMaybe maybeValue =
            case maybeValue of
                Nothing ->
                    Json.Encode.null

                Just value ->
                    Json.Encode.string value
    in
    signedRequest
        { method = "PUT"
        , userToken = token
        , url = baseUrl ++ "/user"
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "user"
                      , Json.Encode.object
                            (List.filter (\( _, y ) -> y /= Json.Encode.null)
                                [ ( "email", encodeMaybe email )
                                , ( "username"
                                  , encodeMaybe
                                        (Maybe.map User.Username.toString username)
                                  )
                                , ( "password", encodeMaybe password )
                                , ( "image", encodeMaybe image )
                                , ( "bio", encodeMaybe bio )
                                ]
                            )
                      )
                    ]
        , expect = Http.expectJson toMsg (Json.Decode.field "user" User.decoder)
        }



-- PROFILE


fetchProfile :
    Username
    -> Maybe User
    -> (Result Http.Error Profile -> msg)
    -> Cmd msg
fetchProfile username maybeUser toMsg =
    optionallySignedRequest
        { method = "GET"
        , userToken = Maybe.map .token maybeUser
        , url = baseUrl ++ "/profiles/" ++ User.Username.toString username
        , body = Http.emptyBody
        , expect =
            Http.expectJson toMsg (Json.Decode.field "profile" User.Profile.decoder)
        }


followUser : Username -> User -> (Result Http.Error Profile -> msg) -> Cmd msg
followUser username user toMsg =
    signedRequest
        { method = "POST"
        , userToken = user.token
        , url = baseUrl ++ "/profiles/" ++ User.Username.toString username ++ "/follow"
        , body = Http.emptyBody
        , expect =
            Http.expectJson toMsg
                (Json.Decode.field "profile" User.Profile.decoder)
        }


unfollowUser : Username -> User -> (Result Http.Error Profile -> msg) -> Cmd msg
unfollowUser username user toMsg =
    signedRequest
        { method = "DELETE"
        , userToken = user.token
        , url = baseUrl ++ "/profiles/" ++ User.Username.toString username ++ "/follow"
        , body = Http.emptyBody
        , expect =
            Http.expectJson toMsg
                (Json.Decode.field "profile" User.Profile.decoder)
        }
