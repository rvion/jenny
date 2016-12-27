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


exports.template = function(str){
  // return function(){
    return Handlebars.compile(str);
  // }
}
exports.render = function(template) {
  // return function(){
    return template({})
  // }
}
exports.renderWith = function(template) {
  return function(data) {
    // return function(){
      return template(data)
    // }
  }
}

exports.compile = function(source) {
    var template = Handlebars.compile(source);
    return function(context) {
        return template(context);
    };
};
