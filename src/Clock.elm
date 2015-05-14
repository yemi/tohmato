module Clock (Model, init, Action, signal, update, updateClockState, updateTimerLength, view) where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import LocalChannel (..)
import Signal
import Time (..)

import StartStopButtons (StartStopButtonsAction(..))
import TimerLengthButtons (TimerLengthButtonsAction(..))

-- MODEL

type ClockState = Running | Stopped | Ended

type alias Model =
    { time: Time
    , state: ClockState
    }

init : Time -> Model
init initialTime =
    { time = initialTime
    , state = Running
    }

-- UPDATE

type Action = Tick Time

update : Action -> Model -> (Model, Bool)
update action model =
  case action of
    Tick tickTime ->
        let state = model.state
            updatedTime = model.time - tickTime
            hasEnded = updatedTime <= 1
        in case state of
            Running ->
                let newModel =
                        { model | time <- if hasEnded then 0 else updatedTime
                                , state <- if hasEnded then Ended else Running }
                in (newModel, hasEnded)
            Ended ->
                let newModel = { model | time <- 0 }
                in (newModel, True)
            Stopped -> (model, False)

updateTimerLength : TimerLengthButtonsAction -> Model -> Model
updateTimerLength timerLengthButtonsAction model =
    case timerLengthButtonsAction of
        ClickPomodoro -> 25 * second |> init
        ClickShortBreak -> 5 * second |> init
        ClickLongBreak -> 10 * second |> init

updateClockState : StartStopButtonsAction -> Model -> Model
updateClockState startStopButtonsAction model =
    let oldState = model.state
    in case startStopButtonsAction of
        ClickStart ->
            { model | state <- if oldState == Stopped then Running else oldState }
        ClickStop ->
            { model | state <- if oldState == Running then Stopped else oldState }

-- VIEW

view : Model -> Html
view model =
  div []
    [ (toString model.time ++ toString model.state) |> text ]

signal : Signal Action
signal = Signal.map (always (1 * second) >> Tick) (every second)
