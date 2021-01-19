module Page.Login exposing (Model, Msg(..), init, update, view)

import Api
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Element.Region
import Form
import Http
import Palette
import Route
import User exposing (User)



-- MODEL


type alias Model =
    { email : String
    , password : String
    , errors : List String
    , submitting : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { email = ""
      , password = ""
      , errors = []
      , submitting = False
      }
    , Cmd.none
    )



-- MESSAGE


type Msg
    = ChangedEmail String
    | ChangedPassword String
    | ClickedSubmit
    | LoggedIn (Result Http.Error User)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedEmail newEmail ->
            ( { model | email = newEmail }, Cmd.none )

        ChangedPassword newPassword ->
            ( { model | password = newPassword }, Cmd.none )

        ClickedSubmit ->
            let
                errors =
                    Form.emailValidation model.email
                        ++ Form.passwordValidation model.password
            in
            if List.isEmpty errors then
                -- TODO - Use API
                ( { model | submitting = True, errors = [] }
                , Api.login { email = model.email, password = model.password } LoggedIn
                )

            else
                ( { model | errors = errors }
                , Cmd.none
                )

        LoggedIn (Ok user) ->
            ( model, Cmd.none )

        LoggedIn (Err error) ->
            let
                error2 =
                    Debug.log "error" error
            in
            ( { model
                | errors = [ "couldn't log in" ]
                , submitting = False
              }
            , Cmd.none
            )



-- VIEW
-- TODO


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Login"
    , body =
        [ Element.column
            [ Element.width <| Element.maximum 600 Element.fill
            , Element.paddingXY Palette.minPaddingX 26
            , Element.centerX
            , Element.spacing 14
            , Element.Font.color <| Element.rgb255 0x37 0x3A 0x3C
            ]
            [ Element.el
                [ Element.centerX
                , Element.Font.size <| Palette.rem 2.5
                , Element.Region.heading 1
                ]
              <|
                Element.text "Sign in"
            , Route.linkToRoute
                [ Element.centerX
                , Element.paddingEach { top = 0, left = 0, right = 0, bottom = 6 }
                , Element.Font.color Palette.color
                , Palette.underlineOnHover
                ]
                { route = Route.Register, label = Element.text "Need an account?" }
            , Element.column
                [ Element.spacing 10
                , Element.paddingXY 40 10
                ]
              <|
                List.map viewError model.errors
            , Element.Input.email
                Form.defaultAttributes
                { onChange = ChangedEmail
                , text = model.email
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Email")
                , label = Element.Input.labelHidden "Email"
                }
            , Element.Input.currentPassword Form.defaultAttributes
                { onChange = ChangedPassword
                , text = model.password
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Password")
                , label = Element.Input.labelHidden "Password"
                , show = False
                }
            , Element.Input.button
                [ Element.alignRight
                , Element.paddingXY (Palette.rem 1.6) (Palette.rem 0.85)
                , Element.Font.size (Palette.rem 1.25)
                , Element.Font.color <| Element.rgb 1 1 1
                , Element.Border.rounded (Palette.rem 0.2)
                , Element.Background.color <|
                    if model.submitting then
                        Element.rgb255 143 214 143

                    else
                        Palette.color
                ]
                { onPress =
                    if model.submitting then
                        Nothing

                    else
                        Just ClickedSubmit
                , label = Element.text "Sign in"
                }
            ]
        ]
    }


viewError : String -> Element Msg
viewError error =
    Element.text error
        |> Element.el
            [ Element.Font.color <| Element.rgb255 0xB8 0x5C 0x5C
            , Element.Font.bold
            ]
