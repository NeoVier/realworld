module User.Profile exposing (Profile, decoder, viewFollowButton)

import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Ionicon
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Palette
import User.Username as Username exposing (Username)


type alias Profile =
    { username : Username
    , bio : String
    , image : String
    , following : Bool
    }


decoder : Decoder Profile
decoder =
    Json.Decode.succeed Profile
        |> JDP.required "username" Username.decoder
        |> JDP.optional "bio" Json.Decode.string ""
        |> JDP.required "image" Json.Decode.string
        |> JDP.required "following" Json.Decode.bool


viewFollowButton :
    List (Element.Attribute msg)
    ->
        { onPress : Maybe msg
        , username : Username
        , following : Bool
        , inverted : Bool
        }
    -> Element msg
viewFollowButton attributes { onPress, username, following, inverted } =
    let
        fontColor =
            if inverted then
                if following then
                    Element.rgb255 0x37 0x3A 0x3C

                else
                    Element.rgba255 0xCC 0xCC 0xCC 0.8

            else
                Element.rgb255 0x99 0x99 0x99

        hoverFontColor =
            if inverted then
                if following then
                    fontColor

                else
                    Element.rgb 1 1 1

            else
                fontColor

        backgroundColor =
            if inverted then
                if following then
                    Element.rgb255 0xD6 0xD6 0xD6

                else
                    Element.rgba 0 0 0 0

            else
                Element.rgba 0 0 0 0

        hoverBackgroundColor =
            if inverted then
                if following then
                    Element.rgb255 0xE6 0xE6 0xE6

                else
                    Element.rgb255 0xCC 0xCC 0xCC

            else
                Element.rgb255 0xE6 0xE6 0xE6
    in
    Element.Input.button
        ([ Element.paddingXY 8 4
         , Element.Font.size <| Palette.rem 0.875
         , Element.Font.color fontColor
         , Element.Border.color fontColor
         , Element.Border.width 1
         , Element.Border.rounded <| Palette.rem 0.2
         , Element.Background.color <| backgroundColor
         , Element.mouseOver
            [ Element.Background.color hoverBackgroundColor
            , Element.Font.color hoverFontColor
            ]
         ]
            ++ attributes
        )
        { onPress = onPress
        , label =
            Element.row [ Element.spacing 3 ]
                [ Element.el [] <|
                    Element.html <|
                        Ionicon.plusRound 16 (Element.toRgb fontColor)
                , Element.text <|
                    (if following then
                        "Unfollow "

                     else
                        "Follow "
                    )
                        ++ Username.toString username
                ]
        }
