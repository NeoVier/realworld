module Page.Article exposing (Model, Msg(..), init, update, view)

import Api
import Article exposing (Article)
import Article.Comment exposing (Comment)
import Article.Slug exposing (Slug)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Http
import Palette
import Route
import Time
import TimeFormat
import User exposing (User)
import User.Profile exposing (Profile)
import User.Username



-- MODEL


type CommentsStatus
    = LoadingComments
    | WithComments (List Comment)
    | WithCommentsError String


type Model
    = Loading
    | WithArticle
        { article : Article
        , comments : CommentsStatus
        }
    | WithError String


init : Slug -> Maybe User -> ( Model, Cmd Msg )
init slug maybeUser =
    ( Loading, Api.fetchArticle slug maybeUser GotArticle )



-- MESSAGE


type Msg
    = GotArticle (Result Http.Error Article)
    | GotComments (Result Http.Error (List Comment))
    | ClickedFollow
    | FollowedProfile (Result Http.Error Profile)
    | ClickedFavorite
    | FavoritedArticle (Result Http.Error Article)



-- UPDATE


update : Msg -> Model -> Maybe User -> ( Model, Cmd Msg )
update msg model maybeUser =
    case ( msg, model ) of
        ( GotArticle (Ok article), Loading ) ->
            ( WithArticle { article = article, comments = LoadingComments }
            , Api.fetchComments article.slug maybeUser GotComments
            )

        ( GotArticle (Err _), _ ) ->
            ( WithError "something went wrong.", Cmd.none )

        ( GotComments (Ok comments), WithArticle wc ) ->
            ( WithArticle { wc | comments = WithComments comments }, Cmd.none )

        ( GotComments (Err _), WithArticle wc ) ->
            ( WithArticle { wc | comments = WithCommentsError "something went wrong." }
            , Cmd.none
            )

        ( ClickedFollow, WithArticle { article } ) ->
            case maybeUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model
                    , if article.author.following then
                        Api.unfollowUser article.author.username user FollowedProfile

                      else
                        Api.followUser article.author.username user FollowedProfile
                    )

        ( FollowedProfile (Ok profile), WithArticle ({ article } as wc) ) ->
            let
                newArticle =
                    { article | author = profile }
            in
            ( WithArticle { wc | article = newArticle }, Cmd.none )

        ( ClickedFavorite, WithArticle { article } ) ->
            case maybeUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model
                    , if article.favorited then
                        Api.unfavoriteArticle article user FavoritedArticle

                      else
                        Api.favoriteArticle article user FavoritedArticle
                    )

        ( FavoritedArticle (Ok article), WithArticle wc ) ->
            ( WithArticle { wc | article = article }, Cmd.none )

        -- Invalid msgs
        ( GotArticle _, _ ) ->
            ( model, Cmd.none )

        ( GotComments _, _ ) ->
            ( model, Cmd.none )

        ( ClickedFollow, _ ) ->
            ( model, Cmd.none )

        ( FollowedProfile _, _ ) ->
            ( model, Cmd.none )

        ( ClickedFavorite, _ ) ->
            ( model, Cmd.none )

        ( FavoritedArticle _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Time.Zone -> Maybe User -> { title : String, body : List (Element Msg) }
view model timeZone maybeUser =
    { title = "Article"
    , body =
        case model of
            Loading ->
                [ Element.text "Loading" ]

            WithArticle { article } ->
                [ banner article timeZone maybeUser ]

            WithError err ->
                [ Element.text err ]
    }



-- BANNER


banner : Article -> Time.Zone -> Maybe User -> Element Msg
banner article timeZone maybeUser =
    Element.column
        [ Element.width Palette.maxWidth
        , Element.paddingXY Palette.minPaddingX 32
        , Element.centerX
        , Element.spacing 32
        , Element.Font.color <| Element.rgb 1 1 1
        ]
        [ Element.el
            [ Element.Font.size <| Palette.rem 2.8
            , Element.Font.bold
            , Element.Font.shadow
                { offset = ( 0, 1 )
                , blur = 3
                , color = Element.rgba 0 0 0 0.3
                }
            ]
          <|
            Element.text article.title
        , articleMeta False timeZone article maybeUser
        ]
        |> Element.el
            [ Element.width Element.fill
            , Element.Background.color <| Element.rgb255 0x33 0x33 0x33
            ]



-- ARTICLE META


articleMeta : Bool -> Time.Zone -> Article -> Maybe User -> Element Msg
articleMeta backgroundIsLight timeZone article maybeUser =
    let
        imageSize =
            32
    in
    Element.row [ Element.spacing 5 ]
        [ Route.linkToRoute []
            { route = Route.Profile { favorites = False, username = article.author.username }
            , label =
                Element.image
                    [ Element.width <| Element.px imageSize
                    , Element.height <| Element.px imageSize
                    , Element.clip
                    , Element.Border.rounded imageSize
                    ]
                    { src = article.author.image, description = "" }
            }
        , Element.column
            [ Element.paddingEach { left = 0, right = 19, top = 0, bottom = 0 }
            , Element.spacing 2
            ]
            [ Route.linkToRoute [ Palette.underlineOnHover ]
                { route = Route.Profile { favorites = False, username = article.author.username }
                , label = Element.text <| User.Username.toString article.author.username
                }
            , Element.el
                [ Element.Font.size <| Palette.rem 0.7
                , Element.Font.color <| Element.rgb255 0xBB 0xBB 0xBB
                , Element.Font.extraLight
                ]
              <|
                Element.text <|
                    TimeFormat.toString timeZone article.updatedAt
            ]
        , User.Profile.viewFollowButton [ Element.height Element.fill ]
            { onPress = Just ClickedFollow
            , username = article.author.username
            , following = article.author.following
            , inverted = not backgroundIsLight
            }
        , Article.viewFavoriteButton [ Element.height Element.fill ]
            { onPress = Just ClickedFavorite
            , favoritesCount = article.favoritesCount
            , favorited = article.favorited
            , inverted = True
            }
        ]
