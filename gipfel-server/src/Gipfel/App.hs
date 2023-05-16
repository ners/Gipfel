module Gipfel.App where

import Control.Monad.IO.Class (MonadIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Control.Monad.Logger (MonadLogger, MonadLoggerIO)
import Control.Monad.Metrics (MonadMetrics (getMetrics), Metrics)
import Control.Monad.Reader (MonadReader)
import Control.Monad.Trans.Reader (ReaderT, runReaderT)
import GHC.Generics (Generic)
import Prelude

data AppState = AppState
    {
    }
    deriving stock (Generic)

newtype AppT m a = App {runApp :: ReaderT AppState m a}
    deriving newtype
        ( Functor
        , Applicative
        , Monad
        , MonadReader AppState
        , MonadLogger
        , MonadLoggerIO
        , MonadIO
        , MonadUnliftIO
        )

type App = AppT IO

instance Monad m => MonadMetrics (AppT m) where
    getMetrics :: AppT m Metrics
    getMetrics = error "getMetrics: not yet implemented"

unliftApp :: AppState -> AppT m a -> m a
unliftApp state App{..} = runReaderT runApp state
