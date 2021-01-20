module Form exposing
    ( defaultAttributes
    , emailValidation
    , generalValidation
    , passwordValidation
    , submitButton
    , usernameValidation
    , viewError
    )

import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
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


usernameValidation : String -> List String
usernameValidation username =
    fieldValidation
        { fieldName = "username"
        , fieldValue = username
        , minLength = 3
        , canBeEmpty = False
        }


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
        , minLength = 8
        , canBeEmpty = False
        }


generalValidation : { value : String, fieldName : String } -> List String
generalValidation { value, fieldName } =
    fieldValidation
        { fieldName = fieldName
        , fieldValue = value
        , minLength = 0
        , canBeEmpty = False
        }


viewError : String -> Element msg
viewError error =
    Element.text error
        |> Element.el
            [ Element.Font.color <| Element.rgb255 0xB8 0x5C 0x5C
            , Element.Font.bold
            ]


submitButton :
    List (Element.Attribute msg)
    -> { onPress : msg, label : String, submitting : Bool }
    -> Element msg
submitButton attributes { onPress, label, submitting } =
    Element.Input.button
        ([ Element.paddingXY (Palette.rem 1.6) (Palette.rem 0.85)
         , Element.Font.size (Palette.rem 1.25)
         , Element.Font.color <| Element.rgb 1 1 1
         , Element.Border.rounded (Palette.rem 0.2)
         , Element.Background.color <|
            if submitting then
                Element.rgb255 143 214 143

            else
                Palette.color
         ]
            ++ attributes
        )
        { onPress =
            if submitting then
                Nothing

            else
                Just onPress
        , label = Element.text label
        }
