module Servant.Extra where

import Data.ByteString.Lazy (LazyByteString)
import Data.OpenApi
import GHC.Generics (Generic)
import Network.HTTP.Media ((//), (/:))
import Servant.API (Accept (..), MimeRender (mimeRender))
import Prelude

data HTML = HTML
    deriving stock (Generic)

newtype RawHtml = RawHtml {unRaw :: LazyByteString}
    deriving stock (Generic)

instance Accept HTML where
    contentType _ = "text" // "html" /: ("charset", "utf-8")

instance MimeRender HTML RawHtml where
    mimeRender _ = unRaw

instance ToSchema RawHtml where
    declareNamedSchema _ = pure $ NamedSchema (Just "HTML") mempty
