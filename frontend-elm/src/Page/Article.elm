module Page.Article exposing (Model, Msg(..), init, update, view)

import Article exposing (Article)
import Element exposing (Element)
import Slug exposing (Slug)



-- MODEL


type Model
    = Loading
    | WithArticle Article
    | WithError String


init : Slug -> ( Model, Cmd Msg )
init _ =
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
    -- TODO
    { title = "Article"
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
