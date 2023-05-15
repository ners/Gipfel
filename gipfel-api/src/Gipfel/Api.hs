module Gipfel.Api where

import Data.Morpheus.Types
import Data.Text (Text)
import GHC.Generics (Generic)
import Servant.API
import Servant.Extra (HTML, RawHtml)

type API = NamedRoutes GipfelAPI

data GipfelAPI mode = GipfelApi
    { resolver :: mode :- NamedRoutes ResolverAPI
    , gql :: mode :- "gql" :> GqlAPI
    }
    deriving stock (Generic)

data ResolverAPI mode = ResolverAPI
    { resolveUrl :: mode :- Capture "stub" Text :> Get '[HTML] RawHtml
    }
    deriving stock (Generic)

type GqlAPI =
    (ReqBody '[JSON] GQLRequest :> Post '[JSON] GQLResponse)
        :<|> ("schema" :> Get '[PlainText] Text)
        :<|> (Get '[HTML] RawHtml)
