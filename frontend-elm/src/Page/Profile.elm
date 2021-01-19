module Page.Profile exposing (Model, Msg(..), init, update, view)

import Element exposing (Element)
import User.Username exposing (Username)



-- MODEL


type Model
    = Loading
    | WithUser String
    | WithError String


init : { favorites : Bool, username : Username } -> ( Model, Cmd Msg )
init _ =
    -- TODO
    ( Loading, Cmd.none )



-- MESSAGE


type Msg
    = NoOp



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Profile"
    , body =
        [ case model of
            Loading ->
                Element.text "Loading"

            WithUser user ->
                Element.text user

            WithError err ->
                Element.text err
        ]
    }
