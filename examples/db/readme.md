
## db administration website

[download](http://www.postgresqltutorial.com/postgresql-sample-database/#)
[extract](http://www.postgresqltutorial.com/load-postgresql-sample-database/)


```sh
unzip dvdrental.zip
pg_restore -U rvion -d dvdrental ./dvdrental.tar
```

```sh
npm i pg-json-schema-export --save-dev
```

```sh
time node examples/db/pg.js
The file was saved!
node examples/db/pg.js  0.28s user 0.04s system 83% cpu 0.382 total
```
