module Api exposing (listArticles)

import Article exposing (Article)
import Http
import Json.Decode


baseUrl : String
baseUrl =
    "https://conduit.productionready.io/api"


listArticles : (Result Http.Error (List Article) -> msg) -> Cmd msg
listArticles toMsg =
    Http.get
        { url = baseUrl ++ "/articles"
        , expect =
            Http.expectJson toMsg
                (Json.Decode.field "articles" (Json.Decode.list Article.decoder))
        }
