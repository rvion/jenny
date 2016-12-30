"use strict";

var dot = require('dot');
var fs = require('fs');

dot.templateSettings.strip = false;

var defs = {}
defs.loadfile = function(path) {
  // https://regex101.com/
  // return fs.readFileSync(process.argv[1].replace(/\/[^\/]*$/,path));
	// return fs.readFileSync(process.argv[1].replace(/[^\/]*$/,path));
	// return fs.readFileSync(defs.templPath.replace(/[^\/]*$/,path));
	return fs.readFileSync(defs.templPath + "/" + path);
};

exports.template = function(str){
  return function(){
    return dot.template(str, null, defs);
  }
}
exports.render = function(template) {
  return function(){
    return template({})
  }
}
exports.renderWith = function(template) {
  return function(data) {
    return function(){
      return template(data)
    }
  }
}

exports.compile = function(source) {
  return function(context) {
    return function(){
      defs.templPath = context;
      var template = dot.template(source, null, defs);
      return template(context);
    }
  };
};
