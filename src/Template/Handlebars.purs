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
foreign import template :: String -> Template Handlebars
foreign import render :: Template Handlebars -> String
foreign import renderWith :: forall a. Template Handlebars -> a -> String
foreign import compile :: forall a. String -> a -> String

foreign import helpers :: forall eff a. Eff eff a
