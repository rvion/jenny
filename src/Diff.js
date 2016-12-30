require('colors')
var jsdiff = require('diff');

exports.showDiff = function(one){
  return function(other){
    return function (){

      var diff = jsdiff.diffChars(one, other);
      var pad = '\n    | '
      process.stderr.write("    | ");
      diff.forEach(function(part){
        //  - green for additions
        //  - red for deletions
        //  - grey for common parts
        var color =
          part.added   ? 'green' :
          part.removed ? 'red'   :
                         'grey'  ;
        // console.log(part)

        // Attempt 1:
        // var lines = part.value.match(/[^\r\n]+/g);
        // for (var i = 0; i < lines.length; i++) {
        //   lines[i] = "   | " + lines[i]
        // }
        // lines = lines.join("\n")
        // process.stderr.write(lines[color]);

        // Attempt 2:

        process.stderr.write(part.value.replace(/\n/g,pad)[color]);
        // process.stderr.write("foo"["blue"]);
      });
      console.log()
    }
  }
}

function replaceAll(str, find, replace) {
  return str.replace(new RegExp(find, 'g'), replace);
}
