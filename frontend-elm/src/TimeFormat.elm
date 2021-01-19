module TimeFormat exposing (toString)

import Time exposing (Month(..))


toString : Time.Zone -> Time.Posix -> String
toString zone time =
    let
        month =
            case Time.toMonth zone time of
                Jan ->
                    "January"

                Feb ->
                    "February"

                Mar ->
                    "March"

                Apr ->
                    "April"

                May ->
                    "May"

                Jun ->
                    "June"

                Jul ->
                    "July"

                Aug ->
                    "August"

                Sep ->
                    "September"

                Oct ->
                    "October"

                Nov ->
                    "November"

                Dec ->
                    "December"

        day =
            Time.toDay zone time
                |> String.fromInt

        year =
            Time.toYear zone time
                |> String.fromInt
    in
    month ++ " " ++ day ++ ", " ++ year
