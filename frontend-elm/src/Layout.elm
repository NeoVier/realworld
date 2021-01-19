module Layout exposing (view)

import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Region
import Html exposing (Html)
import Html.Attributes
import Ionicon
import Palette
import Route exposing (Route)
import User exposing (User)
import User.Username as Username


view :
    Maybe Route
    -> Maybe User
    -> { title : String, body : List (Element msg) }
    -> { title : String, body : Html msg }
view activeRoute activeUser document =
    { title = document.title ++ " - Conduit"
    , body =
        Element.column
            [ Element.width Element.fill
            , Element.height Element.fill
            ]
            [ header activeRoute activeUser
            , Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.spacing 20
                , Element.Region.mainContent
                ]
                document.body
            , footer
            ]
            |> Element.layout
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Font.size <| Palette.rem 1
                , Palette.regularFont
                ]
    }



-- HEADER


header : Maybe Route -> Maybe User -> Element msg
header activeRoute activeUser =
    Element.row
        [ Element.width Palette.maxWidth
        , Element.centerX
        , Element.paddingXY Palette.minPaddingX 0
        ]
        [ headerLogo <| Palette.rem 1.5
        , headerItems activeRoute activeUser
        ]
        |> Element.el
            [ Element.width Element.fill
            , Element.Background.color <| Element.rgb 1 1 1
            , Element.Region.navigation
            , Element.paddingEach { right = 0, left = 0, top = 14, bottom = 18 }
            ]


headerLogo : Int -> Element msg
headerLogo fontSize =
    Route.linkToRoute
        [ Element.Font.bold
        , Element.Font.size fontSize
        , Element.Font.color Palette.color
        , Palette.logoFont
        ]
        { route = Route.Home, label = Element.text "conduit" }


headerItems : Maybe Route -> Maybe User -> Element msg
headerItems activeRoute activeUser =
    let
        items =
            case activeUser of
                Nothing ->
                    [ Route.Home, Route.Login, Route.Register ]

                Just user ->
                    [ Route.Home
                    , Route.Editor Nothing
                    , Route.Settings
                    , Route.Profile { favorites = False, username = user.username }
                    ]
    in
    List.map (headerItem activeRoute) items
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

        iconSize =
            15

        activeColor =
            Element.rgba 0 0 0 0.8

        inactiveColor =
            Element.rgba 0 0 0 0.3

        hoverColor =
            Element.rgba 0 0 0 0.6

        iconColor =
            { red = 0, blue = 0, green = 0, alpha = 1 }

        ( name, icon ) =
            routeTitle itemRoute
    in
    Route.linkToRoute
        [ Element.Font.color <|
            if isActive then
                activeColor

            else
                inactiveColor
        , Element.mouseOver <|
            if isActive then
                []

            else
                [ Element.Font.color hoverColor ]
        , Element.htmlAttribute <|
            Html.Attributes.classList
                [ ( "nav-icon", True ), ( "active", isActive ) ]
        ]
        { route = itemRoute
        , label =
            Element.row [ Element.spacing 2 ]
                [ Maybe.map
                    (\i ->
                        i iconSize iconColor
                            |> Element.html
                            |> Element.el [ Element.centerY ]
                    )
                    icon
                    |> Maybe.withDefault Element.none
                , Element.text name
                ]
        }


routeTitle :
    Route
    ->
        ( String
        , Maybe
            (Int
             -> { red : Float, blue : Float, green : Float, alpha : Float }
             -> Html msg
            )
        )
routeTitle route =
    case route of
        Route.Home ->
            ( "Home", Nothing )

        Route.Login ->
            ( "Sign in", Nothing )

        Route.Register ->
            ( "Sign up", Nothing )

        Route.Settings ->
            ( "Settings", Just Ionicon.gearA )

        Route.Editor _ ->
            ( "New Article", Just Ionicon.compose )

        Route.Article _ ->
            ( "View Article", Nothing )

        Route.Profile { username } ->
            ( Username.toString username, Just Ionicon.person )



-- FOOTER


footer : Element msg
footer =
    Element.wrappedRow
        [ Element.width Palette.maxWidth
        , Element.centerX
        , Element.paddingXY Palette.minPaddingX <| Palette.rem 1.25
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
