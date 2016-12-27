-- | Low-level, unsafe bindings to the Dot templating library.

module Template.Dot where

import Template.Data (Template)

-- import Control.Monad.Eff (Eff)
foreign import data Dot :: *
foreign import template :: String -> Template Dot
foreign import render :: Template Dot -> String
foreign import renderWith :: forall a. Template Dot -> a -> String
foreign import compile :: forall a. String -> a -> String
