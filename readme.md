# jenny
_the programmer assistant_

template engine: [handlebarsjs](http://handlebarsjs.com/)
because

  - [lib](https://github.com/purescript-contrib/purescript-handlebars) already existing
  - [several args for this lib](http://stackoverflow.com/questions/10555820/what-are-the-differences-between-mustache-js-and-handlebars-js)
    - Handlebars templates are compiled
    - Handlebars adds #if, #unless, #with, and #each
    - Handlebars adds helpers
    - Handlebars supports paths: `{{author.name}}`
    - Allows use of {{this}} in blocks (which outputs the current item's string value)
    - Handlebars.SafeString() (= not escaped) (and maybe some other methods)
    - Mustache supports inverted sections (i.e. if !x ...)


:memo: helpers starting with an `#` are bloc expressions

> Block expressions allow you to define helpers that will invoke a section of your template with a different context than the current. These block helpers are identified by a # preceeding the helper name and require a matching closing mustache, /, of the same name.
