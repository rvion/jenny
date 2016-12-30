module Template where

import Template.Dot as Dot
import Template.Handlebars as Handlebars
import Control.Monad.Eff (Eff)
import Template.Data (Template)
import Template.Dot (Dot)
import Template.Handlebars (Handlebars)

type TE engine = {
  template    :: forall eff.   String -> Eff eff (Template engine),
  render      :: forall eff.   Template engine -> Eff eff String,
  renderWith  :: forall eff a. Template engine -> a -> Eff eff String,
  compile     :: forall eff a. String -> a -> Eff eff String
}

dot :: TE Dot
dot = {
  template: Dot.template,
  render: Dot.render,
  renderWith: Dot.renderWith,
  compile: Dot.compile
}

handlebars :: TE Handlebars
handlebars = {
  template: Handlebars.template,
  render: Handlebars.render,
  renderWith: Handlebars.renderWith,
  compile: Handlebars.compile
}
