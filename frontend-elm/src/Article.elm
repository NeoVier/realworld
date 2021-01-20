module Article exposing (Article, decoder, viewArticles, viewFavoriteButton)

import Article.Slug exposing (Slug)
import Article.Tag exposing (Tag)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html.Attributes
import Ionicon
import Iso8601
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Palette
import Route
import Time
import TimeFormat
import User.Profile exposing (Profile)
import User.Username as Username


type alias Article =
    { title : String
    , slug : Slug
    , body : String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , tagList : List Tag
    , description : String
    , author : Profile
    , favorited : Bool
    , favoritesCount : Int
    }


decoder : Decoder Article
decoder =
    Json.Decode.succeed Article
        |> JDP.required "title" Json.Decode.string
        |> JDP.required "slug" Article.Slug.decoder
        |> JDP.required "body" Json.Decode.string
        |> JDP.required "createdAt" Iso8601.decoder
        |> JDP.required "updatedAt" Iso8601.decoder
        |> JDP.required "tagList" (Json.Decode.list Article.Tag.decoder)
        |> JDP.required "description" Json.Decode.string
        |> JDP.required "author" User.Profile.decoder
        |> JDP.required "favorited" Json.Decode.bool
        |> JDP.required "favoritesCount" Json.Decode.int



-- ARTICLE


viewArticles : Time.Zone -> Maybe (Article -> msg) -> List Article -> Element msg
viewArticles zone onFavorite articles =
    List.map
        (\article ->
            viewArticle zone
                (Maybe.map (\x -> x article) onFavorite)
                article
        )
        articles
        |> List.intersperse
            (Element.el
                [ Element.width Element.fill
                , Element.height <| Element.px 1
                , Element.Background.color <| Element.rgba 0 0 0 0.1
                ]
                Element.none
            )
        |> Element.column
            [ Element.width Element.fill
            , Element.spacing 25
            ]


viewArticle : Time.Zone -> Maybe msg -> Article -> Element msg
viewArticle zone onFavorite article =
    Element.column [ Element.width Element.fill, Element.spacing 20 ]
        [ viewArticleAuthor zone onFavorite article
        , Route.linkToRoute [ Element.width Element.fill ]
            { route = Route.Article article.slug
            , label =
                Element.column [ Element.spacing 20, Element.width Element.fill ]
                    [ viewArticleMain article
                    , viewArticleFooter article
                    ]
            }
        ]


viewArticleAuthor : Time.Zone -> Maybe msg -> Article -> Element msg
viewArticleAuthor zone onPress article =
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
                , label = Element.text <| Username.toString article.author.username
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
            { onPress = onPress
            , favoritesCount = article.favoritesCount
            , favorited = article.favorited
            , inverted = False
            }
        ]


viewFavoriteButton :
    List (Element.Attribute msg)
    ->
        { onPress : Maybe msg
        , favoritesCount : Int
        , favorited : Bool
        , inverted : Bool
        }
    -> Element msg
viewFavoriteButton attributes { onPress, favoritesCount, favorited, inverted } =
    let
        fontColor =
            if inverted then
                if favorited then
                    Element.rgba 1 1 1 0.8

                else
                    Palette.color

            else if favorited then
                Element.rgb 1 1 1

            else
                Palette.color

        backgroundColor =
            if inverted then
                if favorited then
                    Palette.color

                else
                    Element.rgba 0 0 0 0

            else if favorited then
                Palette.color

            else
                Element.rgb 1 1 1

        hoverBackgroundColor =
            if inverted then
                if favorited then
                    Palette.color

                else
                    Palette.color

            else if favorited then
                Element.rgb255 0x44 0x9D 0x44

            else
                Palette.color

        hoverFontColor =
            if inverted then
                if favorited then
                    Element.rgb 1 1 1

                else
                    Element.rgb 1 1 1

            else if favorited then
                fontColor

            else
                Element.rgb 1 1 1
    in
    Element.Input.button
        (attributes
            ++ [ Element.paddingXY (Palette.rem 0.5) (Palette.rem 0.25)
               , Element.Font.color fontColor
               , Element.Font.size <| Palette.rem 0.875
               , Element.Border.color Palette.color
               , Element.Border.width 1
               , Element.Border.rounded <| Palette.rem 0.2
               , Element.Background.color backgroundColor
               , Element.mouseOver
                    [ Element.Background.color hoverBackgroundColor
                    , Element.Font.color hoverFontColor
                    ]
               , Element.htmlAttribute <| Html.Attributes.class "icon"
               ]
        )
        { onPress = onPress
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


viewArticleMain : Article -> Element msg
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


viewArticleFooter : Article -> Element msg
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
        , List.map viewArticleTag article.tagList
            |> Element.wrappedRow
                [ Element.alignRight
                , Element.width Element.fill
                , Element.paddingEach { left = 50, right = 0, bottom = 0, top = 0 }
                ]
        ]


viewArticleTag : Tag -> Element msg
viewArticleTag tag =
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
            Article.Tag.toString tag
