module Form exposing (defaultAttributes, emailValidation, passwordValidation)

import Element
import Element.Border
import Element.Font
import Palette


defaultAttributes : List (Element.Attribute msg)
defaultAttributes =
    [ Element.paddingXY 23 15
    , Element.Font.color <| Element.rgb255 0x55 0x59 0x5C
    , Element.Font.size <| Palette.rem 1.25
    , Element.Border.width 1
    , Element.Border.color <| Element.rgba 0 0 0 0.15
    ]


fieldValidation :
    { fieldName : String
    , fieldValue : String
    , minLength : Int
    , canBeEmpty : Bool
    }
    -> List String
fieldValidation { fieldName, fieldValue, minLength, canBeEmpty } =
    let
        emptyValidation =
            if String.isEmpty fieldValue && not canBeEmpty then
                [ fieldName ++ " can't be blank." ]

            else
                []

        lengthValidation =
            if not (String.isEmpty fieldValue) && String.length fieldValue < minLength then
                [ fieldName
                    ++ " must be at least "
                    ++ String.fromInt minLength
                    ++ " characters long."
                ]

            else
                []
    in
    emptyValidation ++ lengthValidation


emailValidation : String -> List String
emailValidation email =
    fieldValidation
        { fieldName = "email"
        , fieldValue = email
        , minLength = 4
        , canBeEmpty = False
        }


passwordValidation : String -> List String
passwordValidation password =
    fieldValidation
        { fieldName = "password"
        , fieldValue = password
        , minLength = 3
        , canBeEmpty = False
        }
