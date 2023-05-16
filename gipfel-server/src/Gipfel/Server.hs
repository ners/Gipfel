{-# OPTIONS_GHC -Wno-orphans #-}

module Gipfel.Server where

import Control.Lens
import Control.Monad.IO.Class (liftIO)
import Data.Kind (Type)
import Data.Morpheus (deriveApp, httpPlayground)
import Data.Morpheus qualified as Morpheus
import Data.Morpheus.Extra ()
import Data.Morpheus.Subscriptions (PubApp, httpPubApp, webSocketsApp)
import Data.Morpheus.Types (render)
import Data.OpenApi (OpenApi, description, info, title, version)
import Data.Text (Text)
import Data.Text.Lazy qualified as Text.Lazy
import Data.Text.Lazy.Encoding qualified as Text.Lazy
import Gipfel.Api
import Gipfel.App (App, AppState (..), unliftApp)
import Gipfel.RootResolver
import Network.Wai.Handler.Warp (defaultSettings, runSettings, setPort)
import Network.Wai.Handler.WebSockets (websocketsOr)
import Network.WebSockets (ServerApp, defaultConnectionOptions)
import Servant (NamedRoutes, Proxy (Proxy), Server, serve)
import Servant.OpenApi (toOpenApi)
import Servant.Server (Handler, HasServer)
import Servant.Server.Generic (AsServer)
import Prelude

startServer
    :: forall (api :: Type)
     . (HasServer api '[])
    => ServerApp
    -> Proxy api
    -> Server api
    -> App ()
startServer wsApp proxy api = do
    let settings = defaultSettings & setPort 3000
    liftIO $
        runSettings settings $
            websocketsOr defaultConnectionOptions wsApp (serve proxy api)

withSchema :: (Applicative f) => Morpheus.App e m -> f Text
withSchema = pure . Text.Lazy.toStrict . Text.Lazy.decodeUtf8 . render

gqlServer
    :: forall e
     . (PubApp e)
    => AppState
    -> [e -> App ()]
    -> Morpheus.App e App
    -> GqlAPI AsServer
gqlServer state publish app =
    GqlAPI
        { query = liftIO . unliftApp state . httpPubApp publish app
        , schema = withSchema app
        , playground = pure $ RawHtml httpPlayground
        }

gqlApp :: Morpheus.App EVENT App
gqlApp = deriveApp rootResolver

server
    :: AppState
    -> [EVENT -> App ()]
    -> GipfelDocumentedAPI AsServer
server state publish =
    GipfelDocumentedAPI
        { doc = docHandler
        , api =
            GipfelAPI
                { gql = gqlServer state publish gqlApp
                , url = urlHandler
                }
        }

docHandler :: Handler OpenApi
docHandler =
    pure $
        toOpenApi (Proxy :: Proxy (NamedRoutes GipfelAPI))
            & info . title .~ "Gipfel API"
            & info . version .~ "1.0.0"
            & info . description ?~ "API endpoints for the Gipfel API"

urlHandler :: Text -> Handler RawHtml
urlHandler = error "urlHandler: not yet implemented"

runServer :: IO ()
runServer = do
    let state = AppState{}
    (wsApp, publish) <- unliftApp state (webSocketsApp gqlApp)
    unliftApp state $ startServer wsApp (Proxy @API) (server state [publish])
