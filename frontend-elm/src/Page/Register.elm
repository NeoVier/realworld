module Page.Register exposing (Model, Msg(..), init, update, view)

import Api
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Font
import Element.Input
import Element.Region
import Form
import Http
import Palette
import Route
import Task
import User exposing (User)



-- MODEL


type alias Model =
    { username : String
    , email : String
    , password : String
    , errors : List String
    , submitting : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { username = ""
      , email = ""
      , password = ""
      , errors = []
      , submitting = False
      }
    , Cmd.none
    )



-- MESSAGE


type Msg
    = ChangedUsername String
    | ChangedEmail String
    | ChangedPassword String
    | ClickedSubmit
    | Registered (Result Http.Error User)
    | SendToSharedModel User



-- UPDATE


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg )
update msg model navKey =
    case msg of
        ChangedUsername newUsername ->
            ( { model | username = newUsername }, Cmd.none )

        ChangedEmail newEmail ->
            ( { model | email = newEmail }, Cmd.none )

        ChangedPassword newPassword ->
            ( { model | password = newPassword }, Cmd.none )

        ClickedSubmit ->
            let
                errors =
                    Form.usernameValidation model.username
                        ++ Form.emailValidation model.email
                        ++ Form.passwordValidation model.password
            in
            if List.isEmpty errors then
                ( { model | submitting = True, errors = [] }
                , Api.register
                    { username = model.username
                    , email = model.email
                    , password = model.password
                    }
                    Registered
                )

            else
                ( { model | errors = errors }, Cmd.none )

        Registered (Ok user) ->
            ( model, Task.succeed user |> Task.perform SendToSharedModel )

        Registered (Err _) ->
            ( { model | errors = [ "couln't register." ], submitting = False }
            , Cmd.none
            )

        SendToSharedModel _ ->
            ( model, Route.replaceUrl navKey Route.Home )



-- VIEW


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Register"
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
                Element.text "Sign up"
            , Route.linkToRoute
                [ Element.centerX
                , Element.paddingEach { top = 0, left = 0, right = 0, bottom = 6 }
                , Element.Font.color Palette.color
                , Palette.underlineOnHover
                ]
                { route = Route.Login, label = Element.text "Have an account?" }
            , Element.column [ Element.spacing 10, Element.paddingXY 40 10 ] <|
                List.map Form.viewError model.errors
            , Element.Input.username Form.defaultAttributes
                { onChange = ChangedUsername
                , text = model.username
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Username")
                , label = Element.Input.labelHidden "Username"
                }
            , Element.Input.email Form.defaultAttributes
                { onChange = ChangedEmail
                , text = model.email
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Email")
                , label = Element.Input.labelHidden "Email"
                }
            , Element.Input.newPassword Form.defaultAttributes
                { onChange = ChangedPassword
                , text = model.password
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Password")
                , label = Element.Input.labelHidden "Password"
                , show = False
                }
            , Form.submitButton [ Element.alignRight ]
                { onPress = ClickedSubmit
                , label = "Sign up"
                , submitting = model.submitting
                }
            ]
        ]
    }
