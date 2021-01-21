module Page.Article exposing (Model, Msg(..), init, update, view)

import Api
import Article exposing (Article)
import Article.Comment exposing (Comment)
import Article.Slug exposing (Slug)
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Form
import Html.Attributes
import Http
import Ionicon
import Markdown
import Palette
import Route
import Time
import TimeFormat
import User exposing (User)
import User.Profile exposing (Profile)
import User.Username



-- MODEL


type CommentsStatus
    = LoadingComments
    | WithComments (List Comment)
    | WithCommentsError String


type Model
    = Loading
    | WithArticle
        { article : Article
        , comments : CommentsStatus
        , comment : String
        }
    | WithError String


init : Slug -> Maybe User -> ( Model, Cmd Msg )
init slug maybeUser =
    ( Loading, Api.fetchArticle slug maybeUser GotArticle )



-- MESSAGE


type Msg
    = GotArticle (Result Http.Error Article)
    | GotComments (Result Http.Error (List Comment))
    | ClickedFollow
    | FollowedProfile (Result Http.Error Profile)
    | ClickedFavorite
    | FavoritedArticle (Result Http.Error Article)
    | ClickedDelete
    | DeletedArticle (Result Http.Error ())
    | ChangedComment String
    | ClickedSubmitComment
    | PostedComment (Result Http.Error Comment)
    | ClickedDeleteComment Comment
    | DeletedComment (Result Http.Error ())



-- UPDATE


update : Msg -> Model -> Nav.Key -> Maybe User -> ( Model, Cmd Msg )
update msg model navKey maybeUser =
    case ( msg, model ) of
        ( GotArticle (Ok article), Loading ) ->
            ( WithArticle
                { article = article
                , comments = LoadingComments
                , comment = ""
                }
            , Api.fetchComments article.slug maybeUser GotComments
            )

        ( GotArticle (Err _), _ ) ->
            ( WithError "something went wrong.", Cmd.none )

        ( GotComments (Ok comments), WithArticle wc ) ->
            ( WithArticle { wc | comments = WithComments comments }, Cmd.none )

        ( GotComments (Err _), WithArticle wc ) ->
            ( WithArticle { wc | comments = WithCommentsError "something went wrong." }
            , Cmd.none
            )

        ( ClickedFollow, WithArticle { article } ) ->
            case maybeUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model
                    , if article.author.following then
                        Api.unfollowUser article.author.username user FollowedProfile

                      else
                        Api.followUser article.author.username user FollowedProfile
                    )

        ( FollowedProfile (Ok profile), WithArticle ({ article } as wc) ) ->
            let
                newArticle =
                    { article | author = profile }
            in
            ( WithArticle { wc | article = newArticle }, Cmd.none )

        ( ClickedFavorite, WithArticle { article } ) ->
            case maybeUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model
                    , if article.favorited then
                        Api.unfavoriteArticle article user FavoritedArticle

                      else
                        Api.favoriteArticle article user FavoritedArticle
                    )

        ( FavoritedArticle (Ok article), WithArticle wc ) ->
            ( WithArticle { wc | article = article }, Cmd.none )

        ( ClickedDelete, WithArticle { article } ) ->
            case maybeUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model, Api.deleteArticle article.slug user DeletedArticle )

        ( DeletedArticle (Ok ()), WithArticle _ ) ->
            ( model, Route.replaceUrl navKey Route.Home )

        ( ChangedComment newComment, WithArticle wc ) ->
            ( WithArticle { wc | comment = newComment }, Cmd.none )

        ( ClickedSubmitComment, WithArticle ({ article, comment } as wa) ) ->
            case maybeUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( WithArticle { wa | comment = "" }
                    , Api.postComment article.slug comment user PostedComment
                    )

        ( PostedComment (Ok comment), WithArticle ({ comments, article } as wa) ) ->
            case comments of
                LoadingComments ->
                    ( model, Api.fetchComments article.slug maybeUser GotComments )

                WithComments wc ->
                    ( WithArticle { wa | comments = WithComments (comment :: wc) }
                    , Cmd.none
                    )

                WithCommentsError _ ->
                    ( model, Cmd.none )

        ( PostedComment (Err _), WithArticle wa ) ->
            ( WithArticle { wa | comments = WithCommentsError "something went wrong." }
            , Cmd.none
            )

        ( ClickedDeleteComment comment, WithArticle ({ article } as wa) ) ->
            case ( wa.comments, maybeUser ) of
                ( WithComments comments, Just user ) ->
                    ( WithArticle
                        { wa
                            | comments =
                                WithComments
                                    (List.filter (\c -> c /= comment) comments)
                        }
                    , Api.deleteComment article.slug comment user DeletedComment
                    )

                _ ->
                    ( model, Cmd.none )

        ( DeletedComment (Ok ()), WithArticle _ ) ->
            ( model, Cmd.none )

        ( DeletedComment (Err _), WithArticle wa ) ->
            ( WithArticle { wa | comments = WithCommentsError "something went wrong." }
            , Cmd.none
            )

        -- Invalid msgs
        ( GotArticle _, _ ) ->
            ( model, Cmd.none )

        ( GotComments _, _ ) ->
            ( model, Cmd.none )

        ( ClickedFollow, _ ) ->
            ( model, Cmd.none )

        ( FollowedProfile _, _ ) ->
            ( model, Cmd.none )

        ( ClickedFavorite, _ ) ->
            ( model, Cmd.none )

        ( FavoritedArticle _, _ ) ->
            ( model, Cmd.none )

        ( ClickedDelete, _ ) ->
            ( model, Cmd.none )

        ( DeletedArticle _, _ ) ->
            ( model, Cmd.none )

        ( ChangedComment _, _ ) ->
            ( model, Cmd.none )

        ( ClickedSubmitComment, _ ) ->
            ( model, Cmd.none )

        ( PostedComment _, _ ) ->
            ( model, Cmd.none )

        ( ClickedDeleteComment _, _ ) ->
            ( model, Cmd.none )

        ( DeletedComment _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Time.Zone -> Maybe User -> { title : String, body : List (Element Msg) }
view model timeZone maybeUser =
    { title = "Article"
    , body =
        case model of
            Loading ->
                [ Element.text "Loading" ]

            WithArticle ({ article } as wa) ->
                [ banner article timeZone maybeUser
                , Element.el
                    [ Element.width Palette.maxWidth
                    , Element.paddingEach
                        { bottom = 20
                        , top = 0
                        , left = Palette.minPaddingX
                        , right = Palette.minPaddingX
                        }
                    , Element.centerX
                    , Element.Font.size <| Palette.rem 1.2
                    , Element.Font.color <| Element.rgb255 0x37 0x3A 0x3C
                    , Palette.serifFont
                    , Element.Border.widthEach { bottom = 1, left = 0, top = 0, right = 0 }
                    , Element.Border.color <| Element.rgba 0 0 0 0.1
                    ]
                  <|
                    Element.html <|
                        Markdown.toHtml [] article.body
                , articleMeta
                    [ Element.centerX
                    , Element.paddingEach { bottom = 30, top = 0, left = 0, right = 0 }
                    ]
                    { backgroundIsLight = True
                    , timeZone = timeZone
                    , article = article
                    , maybeUser = maybeUser
                    }
                , Element.column
                    [ Element.width <| Element.maximum 730 Element.fill
                    , Element.centerX
                    , Element.paddingXY Palette.minPaddingX 0
                    , Element.spacing 10
                    ]
                    [ case maybeUser of
                        Nothing ->
                            Element.none

                        Just user ->
                            viewCommentBox
                                [ Element.width Element.fill
                                ]
                                { text = wa.comment
                                , userPicture = user.image
                                , onChange = ChangedComment
                                , onSubmit = Just ClickedSubmitComment
                                }
                    , case wa.comments of
                        WithComments comments ->
                            let
                                isOwner =
                                    Maybe.map (\_ -> True) maybeUser
                                        |> Maybe.withDefault False
                            in
                            Element.column
                                [ Element.width Element.fill
                                , Element.spacing 15
                                ]
                                (List.map
                                    (\comment ->
                                        viewComment [ Element.width Element.fill ]
                                            { comment = comment
                                            , owner = maybeUser
                                            , timeZone = timeZone
                                            , onDelete =
                                                if isOwner then
                                                    Just (ClickedDeleteComment comment)

                                                else
                                                    Nothing
                                            }
                                    )
                                    comments
                                )

                        LoadingComments ->
                            Element.text "Loading"

                        WithCommentsError err ->
                            Element.text err
                    ]
                ]

            WithError err ->
                [ Element.text err ]
    }



-- BANNER


banner : Article -> Time.Zone -> Maybe User -> Element Msg
banner article timeZone maybeUser =
    Element.column
        [ Element.width Palette.maxWidth
        , Element.paddingXY Palette.minPaddingX 32
        , Element.centerX
        , Element.spacing 32
        , Element.Font.color <| Element.rgb 1 1 1
        ]
        [ Element.el
            [ Element.Font.size <| Palette.rem 2.8
            , Element.Font.bold
            , Element.Font.shadow
                { offset = ( 0, 1 )
                , blur = 3
                , color = Element.rgba 0 0 0 0.3
                }
            ]
          <|
            Element.text article.title
        , articleMeta []
            { backgroundIsLight = False
            , timeZone = timeZone
            , article = article
            , maybeUser = maybeUser
            }
        ]
        |> Element.el
            [ Element.width Element.fill
            , Element.Background.color <| Element.rgb255 0x33 0x33 0x33
            ]



-- ARTICLE META


articleMeta :
    List (Element.Attribute Msg)
    ->
        { backgroundIsLight : Bool
        , timeZone : Time.Zone
        , article : Article
        , maybeUser : Maybe User
        }
    -> Element Msg
articleMeta attributes { backgroundIsLight, timeZone, article, maybeUser } =
    let
        imageSize =
            32

        actions =
            case maybeUser of
                Nothing ->
                    [ User.Profile.viewFollowButton [ Element.height Element.fill ]
                        { onPress = Just ClickedFollow
                        , username = article.author.username
                        , following = article.author.following
                        , inverted = not backgroundIsLight
                        }
                    , Article.viewFavoriteButton [ Element.height Element.fill ]
                        { onPress = Just ClickedFavorite
                        , favoritesCount = article.favoritesCount
                        , favorited = article.favorited
                        , inverted = True
                        }
                    ]

                Just _ ->
                    [ editArticleButton [] article
                    , deleteArticleButton [] (Just ClickedDelete)
                    ]
    in
    Element.row (Element.spacing 5 :: attributes)
        ([ Route.linkToRoute []
            { route = Route.Profile { favorites = False, username = article.author.username }
            , label =
                Element.image
                    [ Element.width <| Element.px imageSize
                    , Element.height <| Element.px imageSize
                    , Element.clip
                    , Element.Border.rounded imageSize
                    ]
                    { src = article.author.image, description = "" }
            }
         , Element.column
            [ Element.paddingEach { left = 0, right = 19, top = 0, bottom = 0 }
            , Element.spacing 2
            ]
            [ Route.linkToRoute
                [ Palette.underlineOnHover
                , Element.Font.color <|
                    if backgroundIsLight then
                        Palette.color

                    else
                        Element.rgb 1 1 1
                ]
                { route = Route.Profile { favorites = False, username = article.author.username }
                , label = Element.text <| User.Username.toString article.author.username
                }
            , Element.el
                [ Element.Font.size <| Palette.rem 0.7
                , Element.Font.color <| Element.rgb255 0xBB 0xBB 0xBB
                , Element.Font.extraLight
                ]
              <|
                Element.text <|
                    TimeFormat.toString timeZone article.updatedAt
            ]
         ]
            ++ actions
        )


editArticleButton :
    List (Element.Attribute msg)
    -> Article
    -> Element msg
editArticleButton attributes article =
    let
        fontColor =
            Element.rgba255 0xCC 0xCC 0xCC 0.8

        fontSize =
            Palette.rem 0.875
    in
    Route.linkToRoute
        ([ Element.paddingXY 10 5
         , Element.Border.rounded <| Palette.rem 0.2
         , Element.Border.width 1
         , Element.Border.color fontColor
         , Element.Font.size fontSize
         , Element.Font.color fontColor
         , Element.mouseOver
            [ Element.Background.color <| Element.rgb255 0xCC 0xCC 0xCC
            , Element.Font.color <| Element.rgb 1 1 1
            ]
         ]
            ++ attributes
        )
        { route = Route.Editor (Just article.slug)
        , label =
            Element.row [ Element.spacing 3 ]
                [ Element.el [] <|
                    Element.html <|
                        Ionicon.edit fontSize (Element.toRgb fontColor)
                , Element.text "Edit Article"
                ]
        }


deleteArticleButton : List (Element.Attribute msg) -> Maybe msg -> Element msg
deleteArticleButton attributes onPress =
    let
        fontSize =
            Palette.rem 0.875

        fontColor =
            Element.rgb255 0xB8 0x5C 0x5C
    in
    Element.Input.button
        ([ Element.paddingXY 10 5
         , Element.Border.rounded <| Palette.rem 0.2
         , Element.Border.width 1
         , Element.Border.color fontColor
         , Element.Font.size fontSize
         , Element.Font.color fontColor
         , Element.mouseOver
            [ Element.Font.color <| Element.rgb 1 1 1
            , Element.Background.color <| Element.rgb255 0xB8 0x5C 0x5C
            ]
         ]
            ++ attributes
        )
        { onPress = onPress
        , label =
            Element.row [ Element.spacing 3 ]
                [ Element.el [] <| Element.html <| Ionicon.trashA fontSize (Element.toRgb fontColor)
                , Element.text "Delete Article"
                ]
        }



-- COMMENTS


viewCommentLayout :
    List (Element.Attribute msg)
    -> { topElement : Element msg, bottomElement : Element msg }
    -> Element msg
viewCommentLayout attributes { topElement, bottomElement } =
    Element.column
        ([ Element.Border.color <| Element.rgba 0 0 0 0.1
         , Element.Border.width 1
         , Element.Border.rounded <| Palette.rem 0.25
         ]
            ++ attributes
        )
        [ topElement
        , bottomElement
        ]


viewCommentBox :
    List (Element.Attribute msg)
    ->
        { text : String
        , userPicture : String
        , onChange : String -> msg
        , onSubmit : Maybe msg
        }
    -> Element msg
viewCommentBox attributes { text, userPicture, onChange, onSubmit } =
    let
        borderColor =
            Element.rgba 0 0 0 0.1

        imgSize =
            32
    in
    viewCommentLayout ((Element.htmlAttribute <| Html.Attributes.class "no-focus-border") :: attributes)
        { topElement =
            Element.Input.multiline
                [ Element.height <| Element.minimum 150 Element.fill
                , Element.padding (Palette.rem 1.25)
                , Element.Border.color borderColor
                , Element.Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                , Element.Border.rounded 0
                ]
                { onChange = onChange
                , text = text
                , placeholder = Just <| Element.Input.placeholder [] <| Element.text "Write a comment..."
                , label = Element.Input.labelHidden "Write a comment"
                , spellcheck = True
                }
        , bottomElement =
            Element.row
                [ Element.paddingXY 20 12
                , Element.width Element.fill
                , Element.Background.color <| Element.rgb255 0xF5 0xF5 0xF5
                ]
                [ Element.image
                    [ Element.width <| Element.px imgSize
                    , Element.height <| Element.px imgSize
                    , Element.clip
                    , Element.Border.rounded imgSize
                    ]
                    { src = userPicture, description = "" }
                , Element.Input.button
                    [ Element.alignRight
                    , Element.height Element.fill
                    , Element.paddingXY (Palette.rem 0.5) (Palette.rem 0.25)
                    , Element.Font.color <| Element.rgb 1 1 1
                    , Element.Font.size <| Palette.rem 0.875
                    , Element.Font.bold
                    , Element.Background.color <| Element.rgb255 0x5C 0xB8 0x5C
                    , Element.Border.rounded (Palette.rem 0.2)
                    , Element.mouseOver
                        [ Element.Background.color <| Element.rgb255 0x44 0x9D 0x44
                        ]
                    ]
                    { onPress = onSubmit
                    , label = Element.text "Post Comment"
                    }
                ]
        }


viewComment :
    List (Element.Attribute msg)
    ->
        { comment : Comment
        , owner : Maybe User
        , timeZone : Time.Zone
        , onDelete : Maybe msg
        }
    -> Element msg
viewComment attributes { comment, owner, timeZone, onDelete } =
    let
        imageSize =
            20
    in
    viewCommentLayout attributes
        { topElement =
            Element.paragraph
                [ Element.padding (Palette.rem 1.25)
                , Element.Border.color <| Element.rgba 0 0 0 0.1
                , Element.Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                , Element.Border.rounded 0
                ]
            <|
                [ Element.html <|
                    Markdown.toHtml [] comment.body
                ]
        , bottomElement =
            Element.row
                [ Element.paddingXY 20 12
                , Element.width Element.fill
                , Element.spacing 5
                , Element.Background.color <| Element.rgb255 0xF5 0xF5 0xF5
                ]
                [ Route.linkToRoute []
                    { route = Route.Profile { favorites = False, username = comment.author.username }
                    , label =
                        Element.image
                            [ Element.width <| Element.px imageSize
                            , Element.height <| Element.px imageSize
                            , Element.clip
                            , Element.Border.rounded imageSize
                            ]
                            { src = comment.author.image, description = "" }
                    }
                , Route.linkToRoute
                    [ Element.Font.color <| Palette.color
                    , Element.Font.size <| Palette.rem 0.8
                    , Element.Font.light
                    , Palette.underlineOnHover
                    ]
                    { route =
                        Route.Profile
                            { favorites = False
                            , username = comment.author.username
                            }
                    , label = Element.text <| User.Username.toString comment.author.username
                    }
                , Element.el
                    [ Element.Font.color <| Element.rgb255 0xBB 0xBB 0xBB
                    , Element.Font.size <| Palette.rem 0.8
                    , Element.Font.light
                    ]
                  <|
                    Element.text <|
                        TimeFormat.toString timeZone comment.updatedAt
                , case owner of
                    Nothing ->
                        Element.none

                    Just _ ->
                        Element.Input.button [ Element.alignRight ]
                            { onPress = onDelete
                            , label =
                                Element.html <|
                                    Ionicon.trashA (Palette.rem 0.8)
                                        (Element.toRgb <| Element.rgba255 0x33 0x33 0x33 0.6)
                            }
                ]
        }
