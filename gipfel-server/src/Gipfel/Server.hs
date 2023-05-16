module Gipfel.Server where

import Control.Monad.IO.Class (liftIO)
import Data.Function ((&))
import Data.Kind (Type)
import Data.Morpheus (deriveApp, httpPlayground)
import Data.Morpheus qualified as Morpheus
import Data.Morpheus.Subscriptions (PubApp, httpPubApp, webSocketsApp)
import Data.Morpheus.Types (render)
import Data.Text (Text)
import Data.Text.Lazy qualified as Text.Lazy
import Data.Text.Lazy.Encoding qualified as Text.Lazy
import Gipfel.Api
import Gipfel.App (App, AppState (..), unliftApp)
import Gipfel.RootResolver
import Network.Wai.Handler.Warp (defaultSettings, runSettings, setPort)
import Network.Wai.Handler.WebSockets (websocketsOr)
import Network.WebSockets (ServerApp, defaultConnectionOptions)
import Servant (Proxy (Proxy), Server, serve)
import Servant.Extra (RawHtml (RawHtml))
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
    let settings = defaultSettings & setPort 8080
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
    -> GipfelAPI AsServer
server state publish =
    GipfelAPI
        { gql = gqlServer state publish gqlApp
        , url = urlHandler
        }

urlHandler :: Text -> Handler RawHtml
urlHandler = error "urlHandler: not yet implemented"

runServer :: IO ()
runServer = do
    let state = AppState{}
    (wsApp, publish) <- unliftApp state (webSocketsApp gqlApp)
    unliftApp state $ startServer wsApp (Proxy @API) (server state [publish])
