module User exposing (Username, fromString, toString)

-- USERNAME


type Username
    = Username String


fromString : String -> Username
fromString =
    Username


toString : Username -> String
toString (Username username) =
    username
