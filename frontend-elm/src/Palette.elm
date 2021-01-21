module Palette exposing
    ( color
    , logoFont
    , maxWidth
    , minPaddingX
    , regularFont
    , rem
    , serifFont
    , underlineOnHover
    )

import Element
import Element.Font
import Html.Attributes


color : Element.Color
color =
    Element.rgb255 0x5C 0xB8 0x5C


rem : Float -> Int
rem f =
    Element.modular 16 f 2
        |> round


underlineOnHover : Element.Attribute msg
underlineOnHover =
    Html.Attributes.class "underline"
        |> Element.htmlAttribute


maxWidth : Element.Length
maxWidth =
    Element.maximum (1140 + minPaddingX) Element.fill


minPaddingX : Int
minPaddingX =
    30


logoFont : Element.Attribute msg
logoFont =
    Element.Font.family
        [ Element.Font.typeface "Titillium Web"
        , Element.Font.sansSerif
        ]


regularFont : Element.Attribute msg
regularFont =
    Element.Font.family
        [ Element.Font.typeface "Source Sans Pro"
        , Element.Font.sansSerif
        ]


serifFont : Element.Attribute msg
serifFont =
    Element.Font.family
        [ Element.Font.typeface "Source Serif Pro"
        , Element.Font.serif
        ]
