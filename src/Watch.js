var watchman = require('fb-watchman');

exports.debug = function(a){
  return function(){
    console.log(a)
  }
}

exports.newWatchClient = function(){
  return new watchman.Client();
}

exports.watch =
  function(client) {
  return function(dir_of_interest) {
  return function(match){
  return function(action){
  return function(){

  // var client = new watchman.Client();
  client.capabilityCheck(
    {optional:[], required:['relative_root']},

    function (error, resp) {
      if (error) { console.log(error); client.end(); return; }
      var eventName = 'event-' + dir_of_interest.trim().replace(/[ \/@\\]/g, '-');
      client.command(['watch-project', dir_of_interest],
          function (error, resp) {
            if (error) {console.error('[watchman] Error initiating watch:', error); return;}
            if ('warning' in resp) { console.log('[watchman] warning: ', resp.warning);}
            console.log('[watchman] watch established on ', resp.watch)
            console.log('[watchman] relative_path', resp.relative_path)
            var sub = {
              expression: ["allof", ["match", match]],
              fields: ["name", "size", "mtime_ms", "exists", "type"]
            };
            if (resp.relative_path) {sub.relative_root = resp.relative_path;}
            client.command(['subscribe', resp.watch, eventName, sub],
              function (error, resp) {
                if (error) { console.error('[watchman] failed to subscribe: ', error); return; }
                console.log('[watchman] subscription ' + resp.subscribe + ' established');
              });
            client.on('subscription', function (resp) {
              if (resp.subscription !== eventName) {return;}
              console.log("[watchman]", resp.files, "changed")
              action(resp.files)();
            });
          }
      );

    }
  );

}}}}}
