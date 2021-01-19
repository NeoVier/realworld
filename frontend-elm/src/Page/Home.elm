module Page.Home exposing (Model, Msg(..), init, update, view)

import Api
import Article exposing (Article)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html
import Html.Attributes
import Html.Events
import Http
import Ionicon
import Palette
import Route
import Tag exposing (Tag)
import Task
import Time
import TimeFormat
import User



-- MODEL


type RemoteData a
    = Loading
    | WithData a
    | WithError String


type alias Model =
    { timeZone : Time.Zone
    , feed : RemoteData (List Article)
    , tags : RemoteData (List Tag)
    }


init : ( Model, Cmd Msg )
init =
    ( { timeZone = Time.utc
      , feed = Loading
      , tags = Loading
      }
    , Cmd.batch
        [ Api.listArticles GotArticles
        , Task.perform GotTimeZone Time.here
        ]
    )



-- MESSAGE


type Msg
    = GotArticles (Result Http.Error (List Article))
    | GotTimeZone Time.Zone



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticles (Ok articles) ->
            ( { model | feed = WithData articles }, Cmd.none )

        GotArticles err ->
            let
                _ =
                    Debug.log "Error" err
            in
            ( { model | feed = WithError "Something went wrong" }, Cmd.none )

        GotTimeZone newZone ->
            ( { model | timeZone = newZone }, Cmd.none )



-- VIEW
-- TODO


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Home"
    , body =
        [ banner
        , case model.feed of
            Loading ->
                Element.text "Loading"

            WithData articles ->
                viewArticles model.timeZone articles

            WithError err ->
                Element.text err
        ]
    }


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
        , Element.el
            [ Element.centerX
            , Element.Font.light
            , Element.Font.size <| Palette.rem 1.5
            ]
          <|
            Element.text "A place to share your knowledge."
        ]


viewArticles : Time.Zone -> List Article -> Element Msg
viewArticles zone articles =
    List.map (viewArticle zone) articles
        |> List.intersperse
            (Element.el
                [ Element.width Element.fill
                , Element.height <| Element.px 1
                , Element.Background.color <| Element.rgba 0 0 0 0.1
                ]
                Element.none
            )
        |> Element.column
            [ Element.width Palette.maxWidth
            , Element.centerX
            , Element.paddingXY Palette.minPaddingX 0
            , Element.spacing 25
            ]



-- ARTICLE


viewArticle : Time.Zone -> Article -> Element Msg
viewArticle zone article =
    Element.column [ Element.width Element.fill, Element.spacing 20 ]
        [ viewArticleAuthor zone article
        , Route.linkToRoute [ Element.width Element.fill ]
            { route = Route.Article article.slug
            , label =
                Element.column [ Element.spacing 20, Element.width Element.fill ]
                    [ viewArticleMain article
                    , viewArticleFooter article
                    ]
            }
        ]


viewArticleAuthor : Time.Zone -> Article -> Element Msg
viewArticleAuthor zone article =
    let
        userPicSize =
            Palette.rem 2
    in
    Element.row
        [ Element.spacing 5
        , Element.width Element.fill
        ]
        [ Route.linkToRoute []
            { route = Route.Profile { favorites = False, username = article.author.username }
            , label =
                Element.image
                    [ Element.width <| Element.px userPicSize
                    , Element.height <| Element.px userPicSize
                    , Element.Border.rounded userPicSize
                    , Element.clip
                    , Element.Background.color <| Element.rgb255 0x95 0x95 0x95
                    ]
                    { src = article.author.image
                    , description = ""
                    }
            }
        , Element.column []
            [ Route.linkToRoute
                [ Element.Font.color Palette.color
                , Palette.underlineOnHover
                ]
                { route =
                    Route.Profile
                        { favorites = False
                        , username = article.author.username
                        }
                , label = Element.text <| User.toString article.author.username
                }
            , Element.el
                [ Element.Font.color <| Element.rgb255 0xBB 0xBB 0xBB
                , Element.Font.size <| Palette.rem 0.8
                , Element.Font.light
                ]
              <|
                Element.text <|
                    TimeFormat.toString zone article.createdAt
            ]
        , viewFavoriteButton [ Element.alignRight ]
            { favoritesCount = article.favoritesCount
            , favorited = article.favorited
            }
        ]


viewFavoriteButton :
    List (Element.Attribute Msg)
    -> { favoritesCount : Int, favorited : Bool }
    -> Element Msg
viewFavoriteButton attributes { favoritesCount, favorited } =
    Element.Input.button
        (attributes
            ++ [ Element.paddingXY (Palette.rem 0.5) (Palette.rem 0.25)
               , Element.Font.color <|
                    if favorited then
                        Element.rgb 1 1 1

                    else
                        Palette.color
               , Element.Font.size <| Palette.rem 0.875
               , Element.Border.color Palette.color
               , Element.Border.width 1
               , Element.Border.rounded <| Palette.rem 0.2
               , Element.Background.color <|
                    if favorited then
                        Palette.color

                    else
                        Element.rgb 1 1 1
               , Element.mouseOver <|
                    if favorited then
                        [ Element.Background.color <| Element.rgb255 0x44 0x9D 0x44 ]

                    else
                        [ Element.Font.color <| Element.rgb 1 1 1
                        , Element.Background.color Palette.color
                        ]
               , Element.htmlAttribute <| Html.Attributes.class "icon"
               ]
        )
        { onPress = Nothing
        , label =
            Element.row
                [ Element.spacing 5
                ]
                [ Element.el
                    [ Element.centerX
                    , Element.centerY
                    ]
                  <|
                    Element.html <|
                        Ionicon.heart 14
                            (if favorited then
                                { red = 1, blue = 1, green = 1, alpha = 1 }

                             else
                                Element.toRgb Palette.color
                            )
                , Element.text <| String.fromInt favoritesCount
                ]
        }


viewArticleMain : Article -> Element Msg
viewArticleMain article =
    Element.column [ Element.spacing 10 ]
        [ Element.el
            [ Element.Font.semiBold
            , Element.Font.size <| Palette.rem 1.5
            ]
          <|
            Element.text article.title
        , Element.el
            [ Element.Font.light
            , Element.Font.color <| Element.rgb255 0x99 0x99 0x99
            ]
          <|
            Element.text article.description
        ]


viewArticleFooter : Article -> Element Msg
viewArticleFooter article =
    Element.row [ Element.width Element.fill ]
        [ Element.el
            [ Element.Font.size <| Palette.rem 0.8
            , Element.Font.light
            , Element.Font.color <| Element.rgb255 0xBB 0xBB 0xBB
            , Element.centerY
            ]
          <|
            Element.text "Read more..."
        , List.map viewTag article.tagList
            |> Element.wrappedRow [ Element.alignRight ]
        ]


viewTag : Tag -> Element Msg
viewTag tag =
    Element.el
        [ Element.paddingXY (Palette.rem 0.6) (Palette.rem 0.2)
        , Element.Font.light
        , Element.Font.size <| Palette.rem 0.8
        , Element.Font.color <| Element.rgb255 0xDD 0xDD 0xDD
        , Element.Border.width 1
        , Element.Border.color <| Element.rgb255 0xDD 0xDD 0xDD
        , Element.Border.rounded <| Palette.rem 10
        ]
    <|
        Element.text <|
            Tag.toString tag
