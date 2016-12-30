-- | Low-level, unsafe bindings to the Handlebars templating library.

module Template.Handlebars where

import Control.Monad.Eff (Eff)
import Template.Data (Template)

-- | Compile a string into a template which can be applied to a context.
-- |
-- | This function should be partially applyied, resulting in a compiled function
-- | which can be reused, instead of compiling the template on each
-- | application.
-- |
-- | _Note_: This function performs no verification on the template string,
-- | so it is recommended that an appropriate type signature be given to the
-- | resulting function. For example:
-- |
-- | ```purescript
-- | hello :: { name :: String } -> String
-- | hello = compile "Hello, {{name}}!"
-- | ```
foreign import data Handlebars :: *
foreign import template   :: forall eff. String -> Eff eff (Template Handlebars)
foreign import render     :: forall eff. Template Handlebars -> Eff eff String
foreign import renderWith :: forall a eff. Template Handlebars -> a -> Eff eff String
foreign import compile    :: forall a eff. String -> a -> Eff eff String

foreign import helpers :: forall eff a. Eff eff a
