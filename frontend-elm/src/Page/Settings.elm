module Page.Settings exposing (Model, Msg(..), init, update, view)

import Api
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Font
import Element.Input
import Element.Region
import Form exposing (passwordValidation)
import Http
import Palette
import Route
import Task
import User exposing (User)
import User.Username exposing (Username)



-- MODEL


type alias Model =
    { image : String
    , username : Username
    , bio : String
    , email : String
    , newPassword : String
    , errors : List String
    , submitting : Bool
    }


init : User -> ( Model, Cmd Msg )
init user =
    ( { image = user.image
      , username = user.username
      , bio = user.bio
      , email = user.email
      , newPassword = ""
      , errors = []
      , submitting = False
      }
    , Cmd.none
    )



-- MESSAGE


type Msg
    = ChangedImage String
    | ChangedUsername String
    | ChangedBio String
    | ChangedEmail String
    | ChangedPassword String
    | ClickedSubmit
    | UpdatedUser (Result Http.Error User)
    | SendToSharedModel User



-- UPDATE


update : Msg -> Model -> Nav.Key -> Maybe User -> ( Model, Cmd Msg )
update msg model navKey maybeUser =
    case msg of
        ChangedImage newImage ->
            ( { model | image = newImage }, Cmd.none )

        ChangedUsername newUsername ->
            ( { model | username = User.Username.fromString newUsername }
            , Cmd.none
            )

        ChangedBio newBio ->
            ( { model | bio = newBio }, Cmd.none )

        ChangedEmail newEmail ->
            ( { model | email = newEmail }, Cmd.none )

        ChangedPassword newPassword ->
            ( { model | newPassword = newPassword }, Cmd.none )

        ClickedSubmit ->
            case maybeUser of
                Nothing ->
                    ( { model | errors = [ "you're not logged in." ] }, Cmd.none )

                Just originalUser ->
                    let
                        errors =
                            validateFields model
                    in
                    if List.isEmpty errors then
                        ( { model | submitting = True, errors = [] }
                        , Api.updateUser originalUser.token
                            { email =
                                if originalUser.email == model.email then
                                    Nothing

                                else
                                    Just model.email
                            , username =
                                if originalUser.username == model.username then
                                    Nothing

                                else
                                    Just model.username
                            , password =
                                if String.isEmpty model.newPassword then
                                    Nothing

                                else
                                    Just model.newPassword
                            , image =
                                if String.isEmpty model.image then
                                    Nothing

                                else
                                    Just model.image
                            , bio =
                                if String.isEmpty model.bio then
                                    Nothing

                                else
                                    Just model.bio
                            }
                            UpdatedUser
                        )

                    else
                        ( { model | errors = errors }, Cmd.none )

        UpdatedUser (Ok user) ->
            ( { model | submitting = False }
            , Task.succeed user |> Task.perform SendToSharedModel
            )

        UpdatedUser (Err _) ->
            ( { model | errors = [ "there was an error" ], submitting = False }
            , Cmd.none
            )

        SendToSharedModel _ ->
            ( model, Route.replaceUrl navKey Route.Home )


validateFields : Model -> List String
validateFields model =
    let
        imageValidation =
            Form.generalValidation
                { value = model.image
                , fieldName = "image URL"
                , optional = True
                }

        usernameValidation =
            Form.usernameValidation (User.Username.toString model.username) False

        bioValidation =
            Form.generalValidation
                { value = model.bio
                , fieldName = "bio"
                , optional = True
                }

        emailValidation =
            Form.emailValidation model.email False

        passwordValidation =
            Form.passwordValidation model.newPassword True
    in
    [ imageValidation
    , usernameValidation
    , bioValidation
    , emailValidation
    , passwordValidation
    ]
        |> List.concat



-- VIEW


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Settings"
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
                Element.text "Your Settings"
            , Element.column [ Element.spacing 10, Element.paddingXY 40 10 ] <|
                List.map Form.viewError model.errors
            , Element.Input.text Form.defaultAttributes
                { onChange = ChangedImage
                , text = model.image
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "URL of profile picture")
                , label = Element.Input.labelHidden "URL of profile picture"
                }
            , Element.Input.username Form.defaultAttributes
                { onChange = ChangedUsername
                , text = User.Username.toString model.username
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Username")
                , label = Element.Input.labelHidden "Username"
                }
            , Element.Input.multiline Form.defaultAttributes
                { onChange = ChangedBio
                , text = model.bio
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Short bio about you")
                , label = Element.Input.labelHidden "Short bio about you"
                , spellcheck = True
                }
            , Element.Input.email Form.defaultAttributes
                { onChange = ChangedEmail
                , text = model.email
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Email")
                , label = Element.Input.labelHidden "Email"
                }
            , Element.Input.newPassword Form.defaultAttributes
                { onChange = ChangedPassword
                , text = model.newPassword
                , placeholder = Just <| Element.Input.placeholder [] (Element.text "Password")
                , label = Element.Input.labelHidden "Password"
                , show = False
                }
            , Form.submitButton [ Element.alignRight ]
                { onPress = ClickedSubmit
                , label = "Update Settings"
                , submitting = model.submitting
                }
            ]
        ]
    }
