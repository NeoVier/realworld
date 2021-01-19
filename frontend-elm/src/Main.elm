module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Element exposing (Element)
import Html
import Layout
import Page.Article
import Page.Editor
import Page.Home
import Page.Login
import Page.NotFound
import Page.Profile
import Page.Register
import Page.Settings
import Route exposing (Route)
import Slug
import Url
import User.Username as Username



-- MODEL


type Page
    = Home Page.Home.Model
    | Login Page.Login.Model
    | Register Page.Register.Model
    | Settings Page.Settings.Model
    | Editor Page.Editor.Model
    | Article Page.Article.Model
    | Profile Page.Profile.Model
    | NotFound


type alias Model =
    { navKey : Nav.Key, currPage : Page, device : Element.Device }


type alias Dimmensions =
    { width : Int, height : Int }


type alias Flags =
    Dimmensions


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.fromUrl url)
        { navKey = navKey
        , currPage = NotFound
        , device = Element.classifyDevice flags
        }



-- MESSAGE


type Msg
    = ChangedUrl Url.Url
    | RequestedUrl Browser.UrlRequest
    | Resized Dimmensions
    | GotHomeMsg Page.Home.Msg
    | GotLoginMsg Page.Login.Msg
    | GotRegisterMsg Page.Register.Msg
    | GotSettingsMsg Page.Settings.Msg
    | GotEditorMsg Page.Editor.Msg
    | GotArticleMsg Page.Article.Msg
    | GotProfileMsg Page.Profile.Msg



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = RequestedUrl
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.currPage ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( RequestedUrl request, _ ) ->
            case request of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( Resized dimm, _ ) ->
            ( { model | device = Element.classifyDevice dimm }, Cmd.none )

        ( GotHomeMsg subMsg, Home subModel ) ->
            Page.Home.update subMsg subModel
                |> updateWith model Home GotHomeMsg

        ( GotLoginMsg subMsg, Login subModel ) ->
            Page.Login.update subMsg subModel
                |> updateWith model Login GotLoginMsg

        ( GotRegisterMsg subMsg, Register subModel ) ->
            Page.Register.update subMsg subModel
                |> updateWith model Register GotRegisterMsg

        ( GotSettingsMsg subMsg, Settings subModel ) ->
            Page.Settings.update subMsg subModel
                |> updateWith model Settings GotSettingsMsg

        ( GotEditorMsg subMsg, Editor subModel ) ->
            Page.Editor.update subMsg subModel
                |> updateWith model Editor GotEditorMsg

        ( GotArticleMsg subMsg, Article subModel ) ->
            Page.Article.update subMsg subModel
                |> updateWith model Article GotArticleMsg

        ( GotProfileMsg subMsg, Profile subModel ) ->
            Page.Profile.update subMsg subModel
                |> updateWith model Profile GotProfileMsg

        -- Invalid messages
        ( GotHomeMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotLoginMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotRegisterMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotSettingsMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotEditorMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotArticleMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotProfileMsg _, _ ) ->
            ( model, Cmd.none )


updateWith :
    Model
    -> (subModel -> Page)
    -> (subMsg -> Msg)
    -> ( subModel, Cmd subMsg )
    -> ( Model, Cmd Msg )
updateWith model toPage toMsg ( subModel, subCmd ) =
    ( { model | currPage = toPage subModel }, Cmd.map toMsg subCmd )



-- VIEW


viewPage :
    Maybe Route
    -> { title : String, body : List (Element subMsg) }
    -> (subMsg -> Msg)
    -> Browser.Document Msg
viewPage activeRoute page toMsg =
    let
        layoutView =
            Layout.view
                activeRoute
                { title = page.title
                , body = page.body
                }
    in
    { title = layoutView.title
    , body = [ layoutView.body |> Html.map toMsg ]
    }


viewStaticPage :
    Maybe Route
    -> { title : String, body : List (Element msg) }
    -> Browser.Document msg
viewStaticPage activeRoute page =
    let
        layoutView =
            Layout.view activeRoute { title = page.title, body = page.body }
    in
    { title = layoutView.title
    , body = [ layoutView.body ]
    }


view : Model -> Browser.Document Msg
view model =
    case model.currPage of
        NotFound ->
            viewStaticPage Nothing { title = "Not Found", body = [ Page.NotFound.view ] }

        Home subModel ->
            viewPage (Just Route.Home) (Page.Home.view subModel) GotHomeMsg

        Login subModel ->
            viewPage (Just Route.Login) (Page.Login.view subModel) GotLoginMsg

        Register subModel ->
            viewPage (Just Route.Register) (Page.Register.view subModel) GotRegisterMsg

        Settings subModel ->
            viewPage (Just Route.Settings) (Page.Settings.view subModel) GotSettingsMsg

        Editor subModel ->
            -- TODO ?
            viewPage (Just (Route.Editor Nothing))
                (Page.Editor.view subModel)
                GotEditorMsg

        Article subModel ->
            -- TODO ?
            viewPage (Just (Route.Article <| Slug.fromString ""))
                (Page.Article.view subModel)
                GotArticleMsg

        Profile subModel ->
            -- TODO ?
            viewPage
                (Just
                    (Route.Profile
                        { favorites = False, username = Username.fromString "" }
                    )
                )
                (Page.Profile.view subModel)
                GotProfileMsg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize (\w h -> Resized { width = w, height = h })



-- UTILS


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | currPage = NotFound }, Cmd.none )

        Just Route.Home ->
            Page.Home.init
                |> updateWith model Home GotHomeMsg

        Just Route.Login ->
            Page.Login.init
                |> updateWith model Login GotLoginMsg

        Just Route.Register ->
            Page.Register.init
                |> updateWith model Register GotRegisterMsg

        Just Route.Settings ->
            Page.Settings.init
                |> updateWith model Settings GotSettingsMsg

        Just (Route.Editor maybeSlug) ->
            Page.Editor.init maybeSlug
                |> updateWith model Editor GotEditorMsg

        Just (Route.Article slug) ->
            Page.Article.init slug
                |> updateWith model Article GotArticleMsg

        Just (Route.Profile options) ->
            Page.Profile.init options
                |> updateWith model Profile GotProfileMsg
