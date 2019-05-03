module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, h1, pre, text)
import Html.Attributes exposing (href)
import Http
import Page.Repo
import Page.Top
import Page.User
import Platform.Sub exposing (Sub)
import Route exposing (Route)
import Url exposing (Protocol(..), Url)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- Model


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = NotFound
    | ErrorPage Http.Error
    | TopPage Page.Top.Model
    | UserPage Page.User.Model
    | RepoPage Page.Repo.Model


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    Model key (TopPage Page.Top.init) |> goTo (Route.parse url)



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | TopMsg Page.Top.Msg
    | UserMsg Page.User.Msg
    | RepoMsg Page.Repo.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            goTo (Route.parse url) model

        TopMsg topMsg ->
            case model.page of
                TopPage topModel ->
                    let
                        ( newTopModel, topCmd ) =
                            Page.Top.update topMsg topModel
                    in
                    ( { model | page = TopPage newTopModel }
                    , Cmd.map TopMsg topCmd
                    )

                _ ->
                    ( model, Cmd.none )

        UserMsg userMsg ->
            case model.page of
                UserPage userModel ->
                    let
                        ( newUserModel, userCmd ) =
                            Page.User.update userMsg userModel
                    in
                    ( { model | page = UserPage newUserModel }
                    , Cmd.map UserMsg userCmd
                    )

                _ ->
                    ( model, Cmd.none )

        RepoMsg repoMsg ->
            case model.page of
                RepoPage repoModel ->
                    let
                        ( newRepoModel, repoCmd ) =
                            Page.Repo.update repoMsg repoModel
                    in
                    ( { model | page = RepoPage newRepoModel }
                    , Cmd.map RepoMsg repoCmd
                    )

                _ ->
                    ( model, Cmd.none )


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            ( { model | page = TopPage Page.Top.init }, Cmd.none )

        Just (Route.User userName) ->
            let
                ( userModel, userCmd ) =
                    Page.User.init userName
            in
            ( { model | page = UserPage userModel }
            , Cmd.map UserMsg userCmd
            )

        Just (Route.Repo userName projectName) ->
            let
                ( repoModel, repoCmd ) =
                    Page.Repo.init userName projectName
            in
            ( { model | page = RepoPage repoModel }
            , Cmd.map RepoMsg repoCmd
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "My GitHub Viewer"
    , body =
        [ a [ href "/" ] [ h1 [] [ text "My GitHub Viewer" ] ]
        , case model.page of
            NotFound ->
                viewNotFound

            ErrorPage error ->
                viewError error

            TopPage topPageModel ->
                Page.Top.view topPageModel |> Html.map TopMsg

            UserPage userPageModel ->
                Page.User.view userPageModel |> Html.map UserMsg

            RepoPage repoPageModel ->
                Page.Repo.view repoPageModel |> Html.map RepoMsg
        ]
    }


viewNotFound : Html msg
viewNotFound =
    text "not found"


viewError : Http.Error -> Html msg
viewError error =
    case error of
        Http.BadBody message ->
            pre [] [ text message ]

        _ ->
            text (Debug.toString error)
