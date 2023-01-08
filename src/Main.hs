module Main where

import Data.Text (Text)
import Network.Wai.Handler.Warp (run)
import Servant

type API = "hello" :> Get '[PlainText] Text

hello :: Handler Text
hello = return "Hello Haskell!"

server :: Server API
server = hello

main :: IO ()
main = run 8080 $ serve (Proxy @API) server
