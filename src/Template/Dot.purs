-- | Low-level, unsafe bindings to the Dot templating library.

module Template.Dot where

import Control.Monad.Eff (Eff)
import Template.Data (Template)

foreign import data Dot :: *
foreign import template   :: forall   eff. String -> Eff eff (Template Dot)
foreign import render     :: forall   eff. Template Dot      -> Eff eff String
foreign import renderWith :: forall a eff. Template Dot -> a -> Eff eff String
foreign import compile    :: forall a eff. String -> a -> Eff eff String
