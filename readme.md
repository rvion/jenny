# jenny

_the programmer assistant_

example usage:

```sh
$ jenny --help

Jenny: the programmer assistant

Options:
  --help                Show help                                      [boolean]
  --version             Show version number                            [boolean]
  --template, -t        generate given template file
                        [you can pass several --template opts]          [string]
  --watch-folder, -w    watch *.jenny templates in folder
                        [you can specify several folder to watch]       [string]
  -p, --prefix, --path  local output path prefix (default: 'gen')       [string]
  -d, --debug           debug                                          [boolean]

Examples:
  # gen ./foo/demo.jenny in ./foo/bar/ folder
  jenny --template=./foo/demo.jenny --prefix=bar --debug                      

  # watch all *.jenny files in
  jenny --watch $(pwd)/examples/db/ --debug
```

### dev

```shell
#git clone https://github.com/rvion/jenny
git clone git@github.com:rvion/jenny.git
bower install
npm install
pulp --watch --then "pulp test" build
```

### Template engines

  - [dotjs](https://www.dotjs.io/) ([docs](http://olado.github.io/doT/index.html), [example](https://github.com/olado/doT/blob/master/examples/advancedsnippet.txt))

:memo: dotjs seems better so far.
