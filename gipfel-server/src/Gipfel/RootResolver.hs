module Gipfel.RootResolver where

import Data.Morpheus.Subscriptions
import Data.Morpheus.Types hiding (App)
import Data.Text (Text)
import GHC.Generics (Generic)
import Gipfel.App (App)
import Gipfel.GqlSchema
import Prelude

data Channel
    = NewUrl
    deriving stock (Eq, Show, Generic)
    deriving anyclass (Hashable)

newtype Content = Content {contentId :: Int}

type EVENT = Event Channel Content

rootResolver :: RootResolver App EVENT Query Mutation Subscription
rootResolver =
    RootResolver
        { queryResolver = Query{..}
        , mutationResolver = Mutation{..}
        , subscriptionResolver = Subscription{..}
        }
  where
    getUrls :: Resolver QUERY EVENT App [Url (Resolver QUERY EVENT App)]
    getUrls = fail "getUrls: not yet implemented"

    getUrlByStub :: Arg "stub" Text -> Resolver QUERY EVENT App (Url (Resolver QUERY EVENT App))
    getUrlByStub _ = fail "getUrlByStub: not yet implemented"

    createUrl :: CreateUrlArgs -> Resolver MUTATION EVENT App (Url (Resolver MUTATION EVENT App))
    createUrl _ = fail "createUrl: not yet implemented"

    newUrl :: SubscriptionField (Resolver SUBSCRIPTION EVENT App (Url (Resolver SUBSCRIPTION EVENT App)))
    newUrl = subscribe NewUrl $ pure $ const $ fail "newUrl: not yet implemented"
