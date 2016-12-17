var Handlebars = require('handlebars');
Handlebars.registerHelper('agree_button', function() {
  return new Handlebars.SafeString(
    "<button>I agree. I am cool</button>"
  );
});
var Main = require("./output/Main/index.js")
Main.main()
