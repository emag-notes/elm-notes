port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { answer : Maybe Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing, Cmd.none )



-- UPDATE


type Msg
    = Confirm
    | ReceiveAnswer Bool


port confirm : String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Confirm ->
            ( model, confirm "本当に商品を購入してよろしいですか?" )

        ReceiveAnswer answer ->
            ( Model (Just answer), Cmd.none )



-- SUBSCRIPTIONS


port receiveAnswer : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveAnswer ReceiveAnswer



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ case model.answer of
            Nothing ->
                button [ onClick Confirm ] [ text "商品を購入する" ]

            Just True ->
                text "商品を購入しました"

            Just False ->
                text "キャンセルしました"
        ]
