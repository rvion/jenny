"use strict";
var Handlebars = require('handlebars');

Handlebars.registerHelper('agree_button', function() {
  return new Handlebars.SafeString(
    "<button>I agree. I am cool</button>"
  );
});

exports.helpers = function() {
  return Handlebars.helpers
}

exports.compile = function(source) {
    var template = Handlebars.compile(source);
    return function(context) {
        return template(context);
    };
};
