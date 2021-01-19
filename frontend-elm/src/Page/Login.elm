module Page.Login exposing (Model, Msg(..), init, update, view)

import Element exposing (Element)
import Element.Input



-- MODEL


type alias Model =
    { email : String
    , password : String
    }


init : ( Model, Cmd Msg )
init =
    ( { email = "", password = "" }, Cmd.none )



-- MESSAGE


type Msg
    = ChangedEmail String
    | ChangedPassword String



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedEmail newEmail ->
            ( { model | email = newEmail }, Cmd.none )

        ChangedPassword newPassword ->
            ( { model | password = newPassword }, Cmd.none )



-- VIEW
-- TODO


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Sign in"
    , body =
        [ Element.Input.email []
            { onChange = ChangedEmail
            , text = model.email
            , placeholder = Just <| Element.Input.placeholder [] (Element.text "Email")
            , label = Element.Input.labelHidden "Email"
            }
        ]
    }
