var watchman = require('fb-watchman');

exports.debug = function(a){
  return function(){
    console.log(a)
  }
}

exports.watch =
  function(dir_of_interest) {
  return function(match){
  return function(action){
  return function(){


  var client = new watchman.Client();

  client.capabilityCheck(
    {optional:[], required:['relative_root']},

    function (error, resp) {
      if (error) { console.log(error); client.end(); return; }

      client.command(
        ['watch-project', dir_of_interest],

        function (error, resp) {
          if (error) { console.error('Error initiating watch:', error); return;}
          if ('warning' in resp) { console.log('warning: ', resp.warning);}
          console.log('watch established on ', resp.watch)
          console.log('relative_path', resp.relative_path)

          var sub = {
            expression: ["allof", ["match", match]],
            fields: ["name", "size", "mtime_ms", "exists", "type"]
          };
          if (resp.relative_path) { sub.relative_root = resp.relative_path; }

          client.command(['subscribe', resp.watch, 'mysubscription', sub],
            function (error, resp) {
              if (error) { console.error('failed to subscribe: ', error); return; }
              console.log('subscription ' + resp.subscribe + ' established');
            });

          client.on('subscription', function (resp) {
            if (resp.subscription !== 'mysubscription') {return;}
            console.log(resp.files)
            console.log(action)
            action(resp.files)();
          });
        } // end function

      );

    }
  );

}}}}
