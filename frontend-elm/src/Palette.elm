module Palette exposing (color, rem, underlineOnHover)

import Element
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
