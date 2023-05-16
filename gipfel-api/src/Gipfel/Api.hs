module Gipfel.Api where

import Data.Morpheus.Types
import Data.Text (Text)
import GHC.Generics (Generic)
import Servant.API
import Servant.Extra (HTML, RawHtml)

type API = NamedRoutes GipfelAPI

data GipfelAPI mode = GipfelAPI
    { gql :: mode :- "gql" :> NamedRoutes GqlAPI
    , url :: mode :- Capture "stub" Text :> Get '[HTML] RawHtml
    }
    deriving stock (Generic)

data GqlAPI mode = GqlAPI
    { query :: mode :- ReqBody '[JSON] GQLRequest :> Post '[JSON] GQLResponse
    , schema :: mode :- "schema" :> Get '[PlainText] Text
    , playground :: mode :- "playground" :> Get '[HTML] RawHtml
    }
    deriving stock (Generic)
