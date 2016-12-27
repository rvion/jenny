module Template where

import Template.Dot as Dot
import Template.Handlebars as Handlebars
import Template.Data (Template)
import Template.Dot (Dot)
import Template.Handlebars (Handlebars)

type TE engine = {
  template :: String -> Template engine,
  render :: Template engine -> String,
  renderWith :: forall a. Template engine -> a -> String,
  compile :: forall a. String -> a -> String
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
