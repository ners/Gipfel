module Servant.Extra where

import Data.ByteString.Lazy (LazyByteString)
import Network.HTTP.Media ((//), (/:))
import Servant.API (Accept (..), MimeRender (mimeRender))

data HTML = HTML

newtype RawHtml = RawHtml {unRaw :: LazyByteString}

instance Accept HTML where
    contentType _ = "text" // "html" /: ("charset", "utf-8")

instance MimeRender HTML RawHtml where
    mimeRender _ = unRaw
