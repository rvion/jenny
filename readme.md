# jenny

_the programmer assistant_


### dev

```shell
git clone https://github.com/rvion/jenny
bower i
npm i
pulp -w --then "pulp test" build
```

### Template engines

  - [handlebarsjs](http://handlebarsjs.com/) ([docs](doc here: https://www.npmjs.com/package/handlebars))
  - [dotjs](https://www.dotjs.io/) ([docs](http://olado.github.io/doT/index.html), [example](https://github.com/olado/doT/blob/master/examples/advancedsnippet.txt))

:memo: dotjs seems better so far.

### Temporary todo

  1. handle holes:
    ```
    {{#each files}}
    <<FILE gen/{{name}}.html>>
      <div class="entry">
        -- <<HOLE foobar>>        <- this
                                     the syntax should change
        -- <</HOLE foobar>>
      </div>
    {{/each}}
    ```
  2. several built-in `helpers`
    - ([see here](https://help.compose.com/docs/connecting-to-postgresql))
    ```handlebars
    {{#database postgres://[username]:[password]@[host]:[port]/[database]}}
      {{#each tables}}
        {{...}}
      {{}}
    {{/datase}}
    ```
  3. watch-recompile
  4. improve CLI
      ```
       jenny \
        -gen ./template:./data \
        -gen ./template2:./data2 \
        -watch
      ```
  5. add logic in templates
  6. ability to check templates and give proper errors
  7. logo
  8. examples

### Misc ideas:

```
{{#database postgres://[username]:[password]@[host]:[port]/[database]}}
{{/database}}

{{=database postgres://[username]:[password]@[host]:[port]/[database]}}
```
