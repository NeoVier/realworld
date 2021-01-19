module Route exposing (Route(..), fromUrl, linkToRoute, replaceUrl)

import Browser.Navigation as Nav
import Element exposing (Element)
import Slug exposing (Slug(..))
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)
import User.Username as Username exposing (Username)



-- ROUTING


type Route
    = Home
    | Login
    | Register
    | Settings
    | Editor (Maybe Slug)
    | Article Slug
    | Profile { favorites : Bool, username : Username }


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Login (Parser.s "login")
        , Parser.map Register (Parser.s "register")
        , Parser.map Settings (Parser.s "settings")
        , Parser.map (Editor Nothing) (Parser.s "editor")
        , Parser.map (Editor << Just << Slug.fromString) (Parser.s "editor" </> Parser.string)
        , Parser.map (Article << Slug.fromString) (Parser.s "article" </> Parser.string)
        , Parser.map
            (\username ->
                Profile { favorites = False, username = Username.fromString username }
            )
            (Parser.s "profile" </> Parser.string)
        , Parser.map
            (\username ->
                Profile { favorites = True, username = Username.fromString username }
            )
            (Parser.s "profile" </> Parser.string </> Parser.s "favorites")
        ]



-- PUBLIC HELPERS


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser


linkToRoute :
    List (Element.Attribute msg)
    -> { route : Route, label : Element msg }
    -> Element msg
linkToRoute attrs { route, label } =
    Element.link attrs { url = toString route, label = label }


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toString route)



-- INTERNAL


toString : Route -> String
toString route =
    "/" ++ String.join "/" (routeToPieces route)


routeToPieces : Route -> List String
routeToPieces route =
    case route of
        Home ->
            []

        Login ->
            [ "login" ]

        Register ->
            [ "register" ]

        Settings ->
            [ "settings" ]

        Editor maybeSlug ->
            case maybeSlug of
                Nothing ->
                    [ "editor" ]

                Just slug ->
                    [ "editor", Slug.toString slug ]

        Article slug ->
            [ "article", Slug.toString slug ]

        Profile { favorites, username } ->
            [ "profile", Username.toString username ]
                ++ (if favorites then
                        [ "favorites" ]

                    else
                        []
                   )
