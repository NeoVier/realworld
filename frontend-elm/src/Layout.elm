module Layout exposing (view)

import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Region
import Html exposing (Html)
import Palette
import Route exposing (Route)
import User


maxWidth : Element.Length
maxWidth =
    Element.maximum 1110 Element.fill


minPaddingX : Int
minPaddingX =
    31


view :
    Maybe Route
    -> { title : String, body : List (Element msg) }
    -> { title : String, body : Html msg }
view activeRoute document =
    { title = document.title ++ " — Conduit"
    , body =
        Element.column
            [ Element.width Element.fill
            , Element.height Element.fill
            ]
            [ header activeRoute
            , Element.column
                [ Element.width maxWidth
                , Element.paddingXY minPaddingX 30
                , Element.spacing 20
                , Element.centerX
                , Element.Region.mainContent
                , Element.height Element.fill
                ]
                document.body
            , footer
            ]
            |> Element.layout
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Font.size <| Palette.rem 1
                , Element.Font.family
                    [ Element.Font.typeface "Source Sans Pro"
                    , Element.Font.sansSerif
                    ]
                ]
    }



-- HEADER


header : Maybe Route -> Element msg
header activeRoute =
    Element.row
        [ Element.width maxWidth
        , Element.centerX
        , Element.paddingXY minPaddingX 14
        ]
        [ headerLogo <| Palette.rem 1.5
        , headerItems activeRoute
        ]
        |> Element.el
            [ Element.width Element.fill
            , Element.Background.color <| Element.rgb 1 1 1
            , Element.Region.navigation
            ]


headerLogo : Int -> Element msg
headerLogo fontSize =
    Route.linkToRoute
        [ Element.Font.bold
        , Element.Font.size fontSize
        , Element.Font.color Palette.color
        , Element.Font.family
            [ Element.Font.typeface "Titillium Web"
            , Element.Font.sansSerif
            ]
        ]
        { route = Route.Home, label = Element.text "conduit" }


headerItems : Maybe Route -> Element msg
headerItems activeRoute =
    List.map (headerItem activeRoute) [ Route.Home, Route.Login, Route.Register ]
        |> Element.row [ Element.alignRight, Element.spacing <| Palette.rem 1 ]


headerItem : Maybe Route -> Route -> Element msg
headerItem activeRoute itemRoute =
    let
        isActive =
            case activeRoute of
                Nothing ->
                    False

                Just r ->
                    r == itemRoute
    in
    Route.linkToRoute
        [ if isActive then
            Element.Font.color <| Element.rgba 0 0 0 0.8

          else
            Element.Font.color <| Element.rgba 0 0 0 0.3
        , Element.mouseOver <|
            if isActive then
                []

            else
                [ Element.Font.color <| Element.rgba 0 0 0 0.6 ]
        ]
        { route = itemRoute
        , label = Element.text <| routeTitle itemRoute
        }


routeTitle : Route -> String
routeTitle route =
    case route of
        Route.Home ->
            "Home"

        Route.Login ->
            "Sign in"

        Route.Register ->
            "Sign up"

        Route.Settings ->
            "Settings"

        Route.Editor _ ->
            "New Article"

        Route.Article _ ->
            "View Article"

        Route.Profile { username } ->
            User.toString username



-- FOOTER


footer : Element msg
footer =
    Element.wrappedRow
        [ Element.width maxWidth
        , Element.centerX
        , Element.paddingXY minPaddingX <| Palette.rem 1.25
        , Element.spacing 10
        ]
        [ Element.el [ Palette.underlineOnHover ] <| headerLogo <| Palette.rem 1
        , Element.paragraph []
            [ Element.text "An interactive learning project from "
            , Element.newTabLink
                [ Element.Font.color Palette.color
                , Palette.underlineOnHover
                ]
                { url = "https://thinkster.io"
                , label = Element.text "Thinkster"
                }
            , Element.text ". Code & design licensed under MIT."
            ]
        ]
        |> Element.el
            [ Element.width Element.fill
            , Element.Background.color <| Element.rgb255 0xF3 0xF3 0xF3
            , Element.Region.footer
            , Element.Font.color <| Element.rgb255 0xBB 0xBB 0xBB
            , Element.Font.size <| Palette.rem 0.8
            , Element.Font.light
            ]
