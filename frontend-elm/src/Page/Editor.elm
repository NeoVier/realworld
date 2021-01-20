module Page.Editor exposing (Model, Msg(..), init, update, view)

import Article exposing (Article)
import Article.Slug exposing (Slug)
import Element exposing (Element)



-- MODEL


type Model
    = Loading
    | WithArticle Article
    | WithError String


init : Maybe Slug -> ( Model, Cmd Msg )
init maybeSlug =
    case maybeSlug of
        Nothing ->
            ( Loading, Cmd.none )

        Just _ ->
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
    { title = "Settings"
    , body =
        [ case model of
            Loading ->
                Element.text "Loading"

            WithArticle _ ->
                Element.text "WithArticle"

            WithError err ->
                Element.text err
        ]
    }
