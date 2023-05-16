module Gipfel.Api
    ( module Servant.Extra
    , API
    , GipfelAPI (..)
    , GipfelDocumentedAPI (..)
    , GqlAPI (..)
    )
where

import Data.Morpheus.Types
import Data.OpenApi (OpenApi)
import Data.Text (Text)
import GHC.Generics (Generic)
import Servant.API
import Servant.Extra

type API = NamedRoutes GipfelDocumentedAPI

data GipfelAPI mode = GipfelAPI
    { gql :: mode :- "gql" :> NamedRoutes GqlAPI
    , url :: mode :- Capture "stub" Text :> Get '[HTML] RawHtml
    }
    deriving stock (Generic)

data GipfelDocumentedAPI mode = GipfelDocumentedAPI
    { doc :: mode :- "doc" :> Get '[JSON] OpenApi
    , api :: mode :- NamedRoutes GipfelAPI
    }
    deriving stock (Generic)

data GqlAPI mode = GqlAPI
    { query :: mode :- ReqBody '[JSON] GQLRequest :> Post '[JSON] GQLResponse
    , schema :: mode :- "schema" :> Get '[PlainText] Text
    , playground :: mode :- "playground" :> Get '[HTML] RawHtml
    }
    deriving stock (Generic)
