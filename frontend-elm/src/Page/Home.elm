module Page.Home exposing (Model, Msg(..), init, update, view)

import Element exposing (Element)
import Element.Background
import Element.Font
import Html.Attributes
import Palette



-- MODEL


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



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
-- TODO


view : Model -> { title : String, body : List (Element Msg) }
view _ =
    { title = "Home"
    , body =
        [ banner ]
    }


banner : Element Msg
banner =
    Element.column
        [ Element.width Element.fill
        , Element.paddingEach { left = 0, right = 0, top = 35, bottom = 39 }
        , Element.spacing 16
        , Element.Background.color Palette.color
        , Element.Font.color <| Element.rgb 1 1 1
        , Element.htmlAttribute <| Html.Attributes.class "banner-shadow"
        ]
        [ Element.el
            [ Element.centerX
            , Palette.logoFont
            , Element.Font.bold
            , Element.Font.size <| Palette.rem 3.5
            , Element.Font.shadow
                { offset = ( 0, 1 )
                , blur = 3
                , color = Element.rgba 0 0 0 0.3
                }
            ]
          <|
            Element.text "conduit"
        , Element.el
            [ Element.centerX
            , Element.Font.light
            , Element.Font.size <| Palette.rem 1.5
            ]
          <|
            Element.text "A place to share your knowledge."
        ]
