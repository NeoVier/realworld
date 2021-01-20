module Page.Editor exposing (Model, Msg(..), init, update, view)

import Api
import Article exposing (Article)
import Article.Slug exposing (Slug)
import Article.Tag exposing (Tag)
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Font
import Element.Input
import Form
import Http
import Palette
import Route
import User exposing (User)



-- MODEL


type Model
    = Loading
    | Editing EditableArticleFields
    | WithError String


type alias EditableArticleFields =
    { title : String
    , description : String
    , body : String
    , tags : List Tag
    , errors : List String
    , submitting : Bool
    , slug : Maybe Article.Slug.Slug
    }


init : Maybe Slug -> ( Model, Cmd Msg )
init maybeSlug =
    case maybeSlug of
        Nothing ->
            ( Editing
                { title = ""
                , description = ""
                , body = ""
                , tags = []
                , errors = []
                , submitting = False
                , slug = Nothing
                }
            , Cmd.none
            )

        Just slug ->
            ( Loading, Api.fetchArticle slug Nothing GotArticle )



-- MESSAGE


type Msg
    = GotArticle (Result Http.Error Article)
    | ChangedTitle String
    | ChangedDescription String
    | ChangedBody String
    | ChangedTags String
    | ClickedSubmit
    | SentArticle (Result Http.Error Article)



-- UPDATE


update : Msg -> Model -> Nav.Key -> Maybe User -> ( Model, Cmd Msg )
update msg model navKey maybeUser =
    case ( msg, model ) of
        ( GotArticle (Ok article), _ ) ->
            ( Editing
                { title = article.title
                , description = article.description
                , body = article.description
                , tags = article.tagList
                , errors = []
                , submitting = False
                , slug = Just article.slug
                }
            , Cmd.none
            )

        ( GotArticle (Err _), _ ) ->
            ( WithError "Something went wrong", Cmd.none )

        ( ChangedTitle newTitle, Editing editableArticle ) ->
            ( Editing { editableArticle | title = newTitle }, Cmd.none )

        ( ChangedDescription newDescription, Editing editableArticle ) ->
            ( Editing { editableArticle | description = newDescription }, Cmd.none )

        ( ChangedBody newBody, Editing editableArticle ) ->
            ( Editing { editableArticle | body = newBody }, Cmd.none )

        ( ChangedTags tagsString, Editing editableArticle ) ->
            ( Editing
                { editableArticle
                    | tags =
                        String.split " " tagsString
                            |> List.map Article.Tag.fromString
                }
            , Cmd.none
            )

        ( ClickedSubmit, Editing editableArticle ) ->
            let
                errors =
                    validateArticle editableArticle
            in
            case maybeUser of
                Nothing ->
                    ( model, Route.replaceUrl navKey Route.Login )

                Just user ->
                    if List.isEmpty errors then
                        ( Editing { editableArticle | errors = [], submitting = True }
                        , case editableArticle.slug of
                            Nothing ->
                                Api.createArticle
                                    { title = editableArticle.title
                                    , description = editableArticle.description
                                    , body = editableArticle.body
                                    , tagList = editableArticle.tags
                                    }
                                    user
                                    SentArticle

                            Just slug ->
                                Api.updateArticle
                                    { title = editableArticle.title
                                    , description = editableArticle.description
                                    , body = editableArticle.body
                                    , tagList = editableArticle.tags
                                    }
                                    slug
                                    user
                                    SentArticle
                        )

                    else
                        ( Editing { editableArticle | errors = errors }, Cmd.none )

        ( SentArticle (Ok article), Editing _ ) ->
            ( model, Route.replaceUrl navKey (Route.Article article.slug) )

        ( SentArticle (Err _), Editing editableArticle ) ->
            ( Editing
                { editableArticle
                    | submitting = False
                    , errors = [ "something went wrong." ]
                }
            , Cmd.none
            )

        -- Invalid Msgs
        ( ChangedTitle _, _ ) ->
            ( model, Cmd.none )

        ( ChangedDescription _, _ ) ->
            ( model, Cmd.none )

        ( ChangedBody _, _ ) ->
            ( model, Cmd.none )

        ( ChangedTags _, _ ) ->
            ( model, Cmd.none )

        ( ClickedSubmit, _ ) ->
            ( model, Cmd.none )

        ( SentArticle _, _ ) ->
            ( model, Cmd.none )


validateArticle : EditableArticleFields -> List String
validateArticle article =
    let
        titleErrors =
            Form.generalValidation
                { value = article.title
                , fieldName = "title"
                , optional = False
                }

        descriptionErrors =
            Form.generalValidation
                { value = article.description
                , fieldName = "description"
                , optional = False
                }

        bodyErrors =
            Form.generalValidation
                { value = article.body
                , fieldName = "body"
                , optional = False
                }
    in
    titleErrors ++ descriptionErrors ++ bodyErrors



-- VIEW


view : Model -> { title : String, body : List (Element Msg) }
view model =
    { title = "Settings"
    , body =
        [ case model of
            Loading ->
                Element.text "Loading"

            Editing article ->
                viewEditableArticle article

            WithError err ->
                Element.text err
        ]
    }


viewEditableArticle : EditableArticleFields -> Element Msg
viewEditableArticle { title, body, description, tags, errors, submitting } =
    Element.column
        [ Element.width <| Element.maximum 1000 Element.fill
        , Element.paddingXY Palette.minPaddingX 26
        , Element.centerX
        , Element.spacing 14
        , Element.Font.color <| Element.rgb255 0x37 0x3A 0x3C
        ]
        [ Element.column [ Element.spacing 10, Element.paddingXY 40 10 ] <|
            List.map Form.viewError errors
        , Element.Input.spellChecked Form.defaultAttributes
            { onChange = ChangedTitle
            , text = title
            , placeholder = Just <| Element.Input.placeholder [] (Element.text "Article Title")
            , label = Element.Input.labelHidden "Article Title"
            }
        , Element.Input.spellChecked
            (Form.defaultAttributes
                ++ [ Element.Font.size <| Palette.rem 1
                   , Element.paddingXY 18 10
                   ]
            )
            { onChange = ChangedDescription
            , text = description
            , placeholder = Just <| Element.Input.placeholder [] (Element.text "What's this article about?")
            , label = Element.Input.labelHidden "What's this article about?"
            }
        , Element.Input.multiline
            (Form.defaultAttributes
                ++ [ Element.Font.size <| Palette.rem 1
                   , Element.paddingXY 18 10
                   , Element.height <| Element.minimum 200 Element.fill
                   ]
            )
            { onChange = ChangedBody
            , text = body
            , placeholder = Just <| Element.Input.placeholder [] (Element.text "Write your article (in markdown)")
            , label = Element.Input.labelHidden "Write your article (in markdown)"
            , spellcheck = True
            }
        , Element.Input.spellChecked
            (Form.defaultAttributes
                ++ [ Element.Font.size <| Palette.rem 1
                   , Element.paddingXY 18 10
                   ]
            )
            { onChange = ChangedTags
            , text = List.map Article.Tag.toString tags |> String.join " "
            , placeholder = Just <| Element.Input.placeholder [] (Element.text "Enter tags")
            , label = Element.Input.labelHidden "Enter tags"
            }
        , Form.submitButton [ Element.alignRight ]
            { onPress = ClickedSubmit
            , label = "Publish Article"
            , submitting = submitting
            }
        ]
