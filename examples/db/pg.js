var fs = require('fs');
var PostgresSchema = require('pg-json-schema-export');
var connection = {
  'user': 'rvion',
  'password': '',
  'host': 'localhost',
  'port': 5432,
  'database': ''
};
PostgresSchema.toJSON(connection, 'public')
  .then(function (schemas) {
    // handle json object
    // console.log(schemas)
    fs.writeFile(
      "db/test.dump.json",
      JSON.stringify(schemas, null, 4),
      function(err) {
        if(err) {
            return console.log(err);
        }
        console.log("The file was saved!");
    });
    // console.log(schemas.tables.actor.columns)
  })
  .catch(function (error) {
    console.log("!!!!!!!!!error", error)
    // handle error
  });
