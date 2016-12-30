require('colors')
var jsdiff = require('diff');

exports.showDiff = function(one){
  return function(other){
    return function (){

      var diff = jsdiff.diffChars(one, other);
      diff.forEach(function(part){
        //  - green for additions
        //  - red for deletions
        //  - grey for common parts
        var color =
          part.added   ? 'green' :
          part.removed ? 'red'   :
                         'grey'  ;
        process.stderr.write(part.value[color]);
      });
      console.log()
    }
  }
}
