module Page.Profile exposing (Model, Msg(..), init, update, view)

import Api
import Article exposing (Article)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Feed exposing (ProfileFeed)
import Html.Attributes
import Http
import Palette
import Time
import User exposing (User)
import User.Profile exposing (Profile)
import User.Username



-- MODEL


type ArticlesStatus
    = LoadingArticles
    | WithArticles (List Article)
    | WithArticlesError String


type Model
    = Loading ProfileFeed
    | WithData
        { profile : Profile
        , articles : ArticlesStatus
        , feed : ProfileFeed
        }
    | WithError String


init : ProfileFeed -> Maybe User -> ( Model, Cmd Msg )
init feed maybeUser =
    let
        username =
            case feed of
                Feed.OwnArticles owner ->
                    owner

                Feed.Favorited owner ->
                    owner
    in
    ( Loading feed
    , Api.fetchProfile username maybeUser GotProfile
    )



-- MESSAGE


type Msg
    = GotProfile (Result Http.Error Profile)
    | GotArticles (Result Http.Error (List Article))
    | ClickedFollow User
    | FollowedUser (Result Http.Error Profile)
    | ChangedFeed ProfileFeed
    | ClickedFavorite Article
    | NoOp



-- UPDATE


update : Msg -> Model -> Maybe User -> ( Model, Cmd Msg )
update msg model maybeUser =
    case ( msg, model ) of
        ( GotProfile (Ok profile), Loading feed ) ->
            ( WithData { profile = profile, feed = feed, articles = LoadingArticles }
            , Api.fetchProfileFeed feed maybeUser GotArticles
            )

        ( GotProfile (Err _), _ ) ->
            ( WithError "something went wrong.", Cmd.none )

        ( GotArticles (Ok articles), WithData wd ) ->
            ( WithData { wd | articles = WithArticles articles }
            , Cmd.none
            )

        ( GotArticles (Err _), WithData wd ) ->
            ( WithData { wd | articles = WithArticlesError "something went wrong." }
            , Cmd.none
            )

        ( ClickedFollow user, WithData { profile } ) ->
            ( model
            , if profile.following then
                Api.unfollowUser profile.username user FollowedUser

              else
                Api.followUser profile.username user FollowedUser
            )

        ( FollowedUser (Ok profile), WithData wd ) ->
            ( WithData { wd | profile = profile }, Cmd.none )

        ( FollowedUser (Err _), _ ) ->
            ( model, Cmd.none )

        ( ChangedFeed newFeed, WithData wd ) ->
            ( WithData { wd | feed = newFeed }
            , Api.fetchProfileFeed newFeed maybeUser GotArticles
            )

        ( ClickedFavorite favoritedArticle, WithData wd ) ->
            case ( wd.articles, maybeUser ) of
                ( WithArticles articles, Just user ) ->
                    let
                        isFavorite =
                            favoritedArticle.favorited

                        newArticles =
                            List.map
                                (\article ->
                                    if article == favoritedArticle then
                                        { article
                                            | favorited = not article.favorited
                                            , favoritesCount =
                                                if isFavorite then
                                                    article.favoritesCount - 1

                                                else
                                                    article.favoritesCount + 1
                                        }

                                    else
                                        article
                                )
                                articles
                    in
                    ( WithData { wd | articles = WithArticles newArticles }
                    , if isFavorite then
                        Api.unfavoriteArticle favoritedArticle user (always NoOp)

                      else
                        Api.favoriteArticle favoritedArticle user (always NoOp)
                    )

                _ ->
                    ( model, Cmd.none )

        ( NoOp, _ ) ->
            ( model, Cmd.none )

        -- Invalid msgs
        ( GotProfile _, _ ) ->
            ( model, Cmd.none )

        ( GotArticles _, _ ) ->
            ( model, Cmd.none )

        ( ClickedFollow _, _ ) ->
            ( model, Cmd.none )

        ( FollowedUser _, _ ) ->
            ( model, Cmd.none )

        ( ChangedFeed _, _ ) ->
            ( model, Cmd.none )

        ( ClickedFavorite _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Time.Zone -> Maybe User -> { title : String, body : List (Element Msg) }
view model timeZone maybeUser =
    { title =
        case model of
            WithData data ->
                if Maybe.map .username maybeUser == Just data.profile.username then
                    "My Profile"

                else
                    User.Username.toString data.profile.username

            _ ->
                "Profile"
    , body =
        case model of
            Loading _ ->
                [ Element.text "Loading" ]

            WithData data ->
                [ banner data.profile maybeUser
                , Element.column
                    [ Element.width Palette.maxWidth
                    , Element.centerX
                    , Element.paddingXY Palette.minPaddingX 0
                    , Element.spacing 30
                    ]
                    [ viewFeed maybeUser data.feed
                    , case data.articles of
                        LoadingArticles ->
                            Element.text "Loading"

                        WithArticles articles ->
                            Article.viewArticles timeZone (Just ClickedFavorite) articles

                        WithArticlesError err ->
                            Element.text err
                    ]
                ]

            WithError err ->
                [ Element.text err ]
    }



-- BANNER


banner : Profile -> Maybe User -> Element Msg
banner profile maybeUser =
    let
        imgSize =
            100
    in
    Element.column
        [ Element.width Element.fill
        , Element.paddingEach { left = 0, right = 0, top = 35, bottom = 39 }
        , Element.spacing 16
        , Element.Background.color <| Element.rgb255 0xF3 0xF3 0xF3
        ]
        [ Element.image
            [ Element.height <| Element.px imgSize
            , Element.width <| Element.px imgSize
            , Element.clip
            , Element.centerX
            , Element.Border.rounded imgSize
            ]
            { src = profile.image, description = "" }
        , Element.el
            [ Element.centerX
            , Element.Font.bold
            , Element.Font.size <| Palette.rem 1.5
            ]
          <|
            Element.text <|
                User.Username.toString profile.username
        , case maybeUser of
            Nothing ->
                Element.none

            Just user ->
                if user.username == profile.username then
                    Element.none

                else
                    Element.el
                        [ Element.width <| Palette.maxWidth
                        , Element.paddingXY Palette.minPaddingX 0
                        , Element.centerX
                        ]
                    <|
                        User.Profile.viewFollowButton [ Element.alignRight ]
                            { onPress = Just <| ClickedFollow user
                            , username = profile.username
                            , following = profile.following
                            , inverted = False
                            }
        ]



-- FEED


viewFeed : Maybe User -> ProfileFeed -> Element Msg
viewFeed maybeUser currentFeed =
    let
        profileOwner =
            case currentFeed of
                Feed.OwnArticles username ->
                    username

                Feed.Favorited username ->
                    username

        feeds =
            [ Feed.OwnArticles profileOwner, Feed.Favorited profileOwner ]
                |> List.map
                    (\f ->
                        ( Feed.profileFeedToString maybeUser f, f == currentFeed )
                    )
    in
    List.map
        (\( feedName, isActive ) ->
            Element.Input.button
                [ Element.paddingXY 8 16
                , Element.Font.color <|
                    if isActive then
                        Palette.color

                    else
                        Element.rgb255 0xAA 0xAA 0xAA
                , Element.Border.widthEach { bottom = 2, top = 0, right = 0, left = 0 }
                , Element.Border.color <|
                    if isActive then
                        Palette.color

                    else
                        Element.rgba 0 0 0 0
                , Element.mouseOver <|
                    if isActive then
                        []

                    else
                        [ Element.Font.color <| Element.rgb255 0x37 0x3A 0x3C ]
                ]
                { onPress =
                    Just <|
                        ChangedFeed <|
                            Feed.profileFeedFromString feedName profileOwner
                , label = Element.text feedName
                }
        )
        feeds
        |> Element.row
            [ Element.width Element.fill
            , Element.paddingXY 8 0
            , Element.spacing 30
            , Element.Border.color <| Element.rgba 0 0 0 0.1
            , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Element.htmlAttribute <| Html.Attributes.class "no-focus-border"
            ]
