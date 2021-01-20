module Page.Home exposing (Model, Msg(..), init, update, view)

import Api
import Article exposing (Article)
import Article.Tag exposing (Tag)
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Feed exposing (Feed)
import Html
import Html.Attributes
import Http
import Palette
import Route
import Time
import User exposing (User)



-- MODEL


type RemoteData a
    = Loading
    | WithData a
    | WithError String


type alias Model =
    { feed : RemoteData (List Article)
    , tags : RemoteData (List Tag)
    , feedType : Feed
    }


init : Maybe User -> ( Model, Cmd Msg )
init maybeUser =
    ( { feed = Loading
      , tags = Loading
      , feedType = Feed.Global
      }
    , Cmd.batch
        [ Api.fetchFeed Feed.Global maybeUser GotArticles
        , Api.listTags GotTags
        ]
    )



-- MESSAGE


type Msg
    = GotArticles (Result Http.Error (List Article))
    | GotTags (Result Http.Error (List Tag))
    | ClickedFavorite Article
    | ChangedFeed Feed
    | ClickedTag Tag
    | NoOp



-- UPDATE


update : Msg -> Model -> Maybe User -> Nav.Key -> ( Model, Cmd Msg )
update msg model maybeUser navKey =
    case msg of
        GotArticles (Ok articles) ->
            ( { model | feed = WithData articles }, Cmd.none )

        GotArticles (Err _) ->
            ( { model | feed = WithError "Something went wrong" }, Cmd.none )

        GotTags (Ok tags) ->
            ( { model | tags = WithData tags }, Cmd.none )

        GotTags (Err _) ->
            ( { model | tags = WithError "Something went wrong" }, Cmd.none )

        ClickedFavorite favoritedArticle ->
            let
                isFavorite =
                    favoritedArticle.favorited
            in
            case ( model.feed, maybeUser ) of
                ( WithData articles, Just user ) ->
                    ( { model
                        | feed =
                            List.map
                                (\article ->
                                    if article == favoritedArticle then
                                        { article
                                            | favorited = not article.favorited
                                            , favoritesCount =
                                                if isFavorite then
                                                    article.favoritesCount - 1

                                                else
                                                    article.favoritesCount + 1
                                        }

                                    else
                                        article
                                )
                                articles
                                |> WithData
                      }
                    , if isFavorite then
                        Api.unfavoriteArticle favoritedArticle user (always NoOp)

                      else
                        Api.favoriteArticle favoritedArticle user (always NoOp)
                    )

                ( _, Nothing ) ->
                    ( model, Route.replaceUrl navKey Route.Login )

                _ ->
                    ( model, Cmd.none )

        ChangedFeed newFeed ->
            ( { model | feedType = newFeed, feed = Loading }
            , Api.fetchFeed newFeed maybeUser GotArticles
            )

        ClickedTag tag ->
            ( { model | feedType = Feed.Tag tag, feed = Loading }
            , Api.fetchFeed (Feed.Tag tag) maybeUser GotArticles
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Element.Device -> Time.Zone -> Maybe User -> { title : String, body : List (Element Msg) }
view model device timeZone maybeUser =
    let
        hideTags =
            case ( device.class, device.orientation ) of
                ( Element.Tablet, Element.Portrait ) ->
                    True

                ( Element.Phone, _ ) ->
                    True

                _ ->
                    False
    in
    { title = "Home"
    , body =
        [ banner
        , Element.row
            [ Element.width Palette.maxWidth
            , Element.centerX
            , Element.paddingXY Palette.minPaddingX 0
            , Element.spacing 50
            ]
            [ Element.column
                [ Element.width <| Element.fillPortion 3
                , Element.spacing 30
                , Element.alignTop
                ]
                [ viewFeed maybeUser model.feedType
                , case model.feed of
                    Loading ->
                        Element.text "Loading"

                    WithData articles ->
                        Article.viewArticles timeZone ClickedFavorite articles

                    WithError err ->
                        Element.text err
                ]
            , if hideTags then
                Element.none

              else
                Element.el [ Element.alignTop, Element.width <| Element.fillPortion 1 ] <|
                    case model.tags of
                        Loading ->
                            Element.text "Loading"

                        WithData tags ->
                            viewTagList tags

                        WithError err ->
                            Element.text err
            ]
        ]
    }



-- BANNER


banner : Element Msg
banner =
    Element.column
        [ Element.width Element.fill
        , Element.paddingEach { left = 0, right = 0, top = 35, bottom = 39 }
        , Element.spacing 16
        , Element.Background.color Palette.color
        , Element.Font.color <| Element.rgb 1 1 1
        , Element.htmlAttribute <| Html.Attributes.class "banner-shadow"
        ]
        [ Element.el
            [ Element.centerX
            , Palette.logoFont
            , Element.Font.bold
            , Element.Font.size <| Palette.rem 3.5
            , Element.Font.shadow
                { offset = ( 0, 1 )
                , blur = 3
                , color = Element.rgba 0 0 0 0.3
                }
            ]
          <|
            Element.text "conduit"
        , Element.paragraph
            [ Element.centerX
            , Element.Font.center
            , Element.Font.light
            , Element.Font.size <| Palette.rem 1.5
            ]
            [ Element.text "A place to share your knowledge."
            ]
        ]



-- FEED


viewFeed : Maybe User -> Feed -> Element Msg
viewFeed maybeUser currentFeed =
    let
        feeds =
            ((case maybeUser of
                Just user ->
                    [ Feed.Personal user ]

                Nothing ->
                    []
             )
                ++ Feed.Global
                :: (case currentFeed of
                        Feed.Tag _ ->
                            [ currentFeed ]

                        _ ->
                            []
                   )
            )
                |> List.map (\f -> ( Feed.toString f, f == currentFeed ))
    in
    List.map
        (\( feedName, isActive ) ->
            Element.Input.button
                [ Element.paddingXY 8 16
                , Element.Font.color <|
                    if isActive then
                        Palette.color

                    else
                        Element.rgb255 0xAA 0xAA 0xAA
                , Element.Border.widthEach { bottom = 2, top = 0, right = 0, left = 0 }
                , Element.Border.color <|
                    if isActive then
                        Palette.color

                    else
                        Element.rgba 0 0 0 0
                , Element.mouseOver <|
                    if isActive then
                        []

                    else
                        [ Element.Font.color <| Element.rgb255 0x37 0x3A 0x3C ]
                ]
                { onPress = Just <| ChangedFeed <| Feed.fromString feedName maybeUser
                , label = Element.text feedName
                }
        )
        feeds
        |> Element.row
            [ Element.width Element.fill
            , Element.paddingXY 8 0
            , Element.spacing 30
            , Element.Border.color <| Element.rgba 0 0 0 0.1
            , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Element.htmlAttribute <| Html.Attributes.class "no-focus-border"
            ]



-- TAGS


viewTagList : List Tag -> Element Msg
viewTagList tags =
    Element.column
        [ Element.width Element.fill
        , Element.padding 10
        , Element.spacing 10
        , Element.Background.color <| Element.rgb255 0xF3 0xF3 0xF3
        ]
        [ Element.el [ Element.Font.color <| Element.rgb255 0x37 0x3A 0x3C ] <|
            Element.text "Popular Tags"
        , Element.wrappedRow [ Element.spacing 3 ] <| List.map viewTag tags
        ]


viewTag : Tag -> Element Msg
viewTag tag =
    Element.Input.button
        [ Element.paddingXY 8 5
        , Element.Font.color <| Element.rgb 1 1 1
        , Element.Font.size <| Palette.rem 0.8
        , Element.Background.color <| Element.rgb255 0x81 0x8A 0x91
        , Element.Border.rounded <| Palette.rem 10
        , Element.mouseOver
            [ Element.Background.color <| Element.rgb255 0x68 0x70 0x77
            ]
        ]
        { onPress = Just <| ClickedTag tag
        , label =
            Article.Tag.toString tag
                |> Element.text
        }
