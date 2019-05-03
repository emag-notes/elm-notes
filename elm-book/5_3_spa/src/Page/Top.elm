module Page.Top exposing (Model, Msg, init, update, view)

-- MODEL

import GitHub exposing (User)
import Html exposing (Html, a, button, div, form, input, li, pre, text, ul)
import Html.Attributes exposing (autofocus, disabled, href, placeholder, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Url.Builder


type alias Model =
    { input : String
    , status : LoadingStatus
    }


type LoadingStatus
    = Init
    | Waiting
    | Loaded (List User)
    | Failed Http.Error


init : Model
init =
    Model "" Init



-- UPDATE


type Msg
    = Input String
    | Send
    | Receive (Result Http.Error (List User))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input newInput ->
            ( { model | input = newInput }, Cmd.none )

        Send ->
            ( { model | input = "", status = Waiting }
            , GitHub.searchUsers Receive model.input
            )

        Receive (Ok users) ->
            ( { model | status = Loaded users }, Cmd.none )

        Receive (Err e) ->
            ( { model | status = Failed e }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ form [ onSubmit Send ]
            [ input
                [ onInput Input
                , autofocus True
                , placeholder "GitHub name"
                , value model.input
                ]
                []
            , button
                [ disabled (not (isValidInput model.input)) ]
                [ text "Send" ]
            ]
        , case model.status of
            Init ->
                text ""

            Waiting ->
                text "Waiting..."

            Loaded users ->
                viewUsers users

            Failed e ->
                case e of
                    Http.BadBody message ->
                        pre [] [ text message ]

                    _ ->
                        text (Debug.toString e)
        ]


isValidInput : String -> Bool
isValidInput input =
    String.length input >= 1


viewUsers : List User -> Html Msg
viewUsers users =
    ul [] (List.map viewUser users)


viewUser : User -> Html Msg
viewUser user =
    viewLink (Url.Builder.absolute [ user.login ] [])


viewLink : String -> Html Msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]
