{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-missing-deriving-strategies #-}

module Gipfel.GqlSchema where

import Data.FileEmbed (makeRelativeToProject)
import Data.Morpheus.Document (importGQLDocument)
import Data.Text (Text)
import Prelude

makeRelativeToProject "assets/schema.gql" >>= importGQLDocument
