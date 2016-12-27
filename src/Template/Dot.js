"use strict";
var dot= require('dot');
dot.templateSettings.strip = false;
//
// Handlebars.registerHelper('agree_button', function() {
//   return new Handlebars.SafeString(
//     "<button>I agree. I am cool</button>"
//   );
// });

// exports.helpers = function() {
//   return Handlebars.helpers
// }

exports.template = function(str){
  // return function(){
    return dot.template(str);
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
    var template = dot.template(source);
    return function(context) {
        // console.log("/--")
        // console.log("foo",template)
        // console.log("--/")
        return template(context);
    };
};
