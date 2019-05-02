module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, button, div, p, text)
import Html.Events exposing (onClick)
import Http
import Platform.Sub exposing (Sub)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- Model


type alias Model =
    { result : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { result = "" }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Click
    | GotRepo (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click ->
            ( model
            , Http.get
                { url = "https://api.github.com/repos/elm/core"
                , expect = Http.expectString GotRepo
                }
            )

        GotRepo (Ok repo) ->
            ( { model | result = repo }, Cmd.none )

        GotRepo (Err error) ->
            ( { model | result = Debug.toString error }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Click ] [ text "Get Repository Info" ]
        , p [] [ text model.result ]
        ]
