module Page.Register exposing (Model, Msg(..), init, update, view)

import Element exposing (Element)
import Element.Input



-- MODEL


type alias Model =
    { username : String
    , email : String
    , password : String
    }


init : ( Model, Cmd Msg )
init =
    ( { username = "", email = "", password = "" }, Cmd.none )



-- MESSAGE


type Msg
    = ChangedUsername String
    | ChangedEmail String
    | ChangedPassword String



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedUsername newUsername ->
            ( { model | username = newUsername }, Cmd.none )

        ChangedEmail newEmail ->
            ( { model | email = newEmail }, Cmd.none )

        ChangedPassword newPassword ->
            ( { model | password = newPassword }, Cmd.none )



-- VIEW


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Sign up"
    , body =
        [ Element.Input.username []
            { onChange = ChangedUsername
            , text = model.username
            , placeholder = Just <| Element.Input.placeholder [] (Element.text "Username")
            , label = Element.Input.labelHidden "Username"
            }
        ]
    }
