"use strict";
// \{\{\@(?:\}\}|\s*([\s\S]+?)\|\s*([\w]+)\s*(?:(?<ok>[\w]+)\s*)*?\}\})
var doT = {
	version: "1.1.1",
	templateSettings: {
		evaluate:    /\{\{([\s\S]+?(\}?)+)\}\}/g,
		interpolate: /\{\{=([\s\S]+?)\}\}/g,
		interpolate_indent: /\{\{\|=([\s\S]+?)\}\}/g,
		stripperl: 	 /\s*\{\{\<\%\}\}/g,
		stripperr: 	 /\{\{\%\>\}\}\s*/g,
		stripperlr:  /\s*\{\{\%\}\}\s*/g,
		encode:      /\{\{!([\s\S]+?)\}\}/g,
		use:         /\{\{#([\s\S]+?)\}\}/g,
		useParams:   /(^|[^\w$])def(?:\.|\[[\'\"])([\w$\.]+)(?:[\'\"]\])?\s*\:\s*([\w$\.]+|\"[^\"]+\"|\'[^\']+\'|\{[^\}]+\})/g,
		define:      /\{\{##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\}\}/g,
		defineParams:/^\s*([\w$]+):([\s\S]+)/,
		conditional: /\{\{\?(\?)?\s*([\s\S]*?)\s*\}\}/g,
		iterate:     /\{\{~\s*(?:\}\}|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\}\})/g,
		varname:	"it",
		strip:		true,
		append:		true,
		selfcontained: false,
		doNotSkipEncoded: false
	},
	template: undefined, //fn, compile template
	compile:  undefined, //fn, for express
	log: true
}, _globals;

doT.encodeHTMLSource = function(doNotSkipEncoded) {
	var encodeHTMLRules = { "&": "&#38;", "<": "&#60;", ">": "&#62;", '"': "&#34;", "'": "&#39;", "/": "&#47;" },
		matchHTML = doNotSkipEncoded ? /[&<>"'\/]/g : /&(?!#?\w+;)|<|>|"|'|\//g;
	return function(code) {
		return code ? code.toString().replace(matchHTML, function(m) {return encodeHTMLRules[m] || m;}) : "";
	};
};

_globals = (function(){ return this || (0,eval)("this"); }());

/* istanbul ignore else */
// if (typeof module !== "undefined" && module.exports) {
// 	module.exports = doT;
// } else if (typeof define === "function" && define.amd) {
// 	define(function(){return doT;});
// } else {
// 	_globals.doT = doT;
// }

var startend = {
	append: { start: "'+(",      end: ")+'",      startencode: "'+encodeHTML(" },
	split:  { start: "';out+=(", end: ");out+='", startencode: "';out+=encodeHTML(" }
}, skip = /$^/;

function resolveDefs(c, block, def) {
	return ((typeof block === "string") ? block : block.toString())
	.replace(c.define || skip, function(m, code, assign, value) {
		if (code.indexOf("def.") === 0) {
			code = code.substring(4);
		}
		if (!(code in def)) {
			if (assign === ":") {
				if (c.defineParams) value.replace(c.defineParams, function(m, param, v) {
					def[code] = {arg: param, text: v};
				});
				if (!(code in def)) def[code]= value;
			} else {
				new Function("def", "def['"+code+"']=" + value)(def);
			}
		}
		return "";
	})
	.replace(c.use || skip, function(m, code) {
		if (c.useParams) code = code.replace(c.useParams, function(m, s, d, param) {
			if (def[d] && def[d].arg && param) {
				var rw = (d+":"+param).replace(/'|\\/g, "_");
				def.__exp = def.__exp || {};
				def.__exp[rw] = def[d].text.replace(new RegExp("(^|[^\\w$])" + def[d].arg + "([^\\w$])", "g"), "$1" + param + "$2");
				return s + "def.__exp['"+rw+"']";
			}
		});
		var v = new Function("def", "return " + code)(def);
		return v ? resolveDefs(c, v, def) : v;
	});
}

function unescape(code) {
	return code.replace(/\\('|\\)/g, "$1").replace(/[\r\t\n]/g, " ");
}

doT.template = function(tmpl, c, def) {
	c = c || doT.templateSettings;
	var cse = c.append ? startend.append : startend.split, needhtmlencode, sid = 0, indv,
		str  = (c.use || c.define) ? resolveDefs(c, tmpl, def || {}) : tmpl;

	str = ("var out='" + (c.strip ? str.replace(/(^|\r|\n)\t* +| +\t*(\r|\n|$)/g," ")
				.replace(/\r|\n|\t|\/\*[\s\S]*?\*\//g,""): str)
		.replace(/'|\\/g, "\\$&")
		.replace(c.interpolate_indent || skip, function(m, code, offset, init) {
			console.log(m, code, offset, init)
			var indent = 0, pad ="";
			while (init[offset-indent ] != '\n'){indent +=1;pad+=" "}
			pad = pad.slice(0, -1);
			return cse.start + "toS("+unescape(code)+",'"+pad+"')" + cse.end;
		})
		.replace(c.interpolate || skip, function(m, code) {
			return cse.start + "toS("+unescape(code)+",'')" + cse.end;
		})
		.replace(c.encode || skip, function(m, code) {
			needhtmlencode = true;
			return cse.startencode + unescape(code) + cse.end;
		})
		.replace(c.conditional || skip, function(m, elsecase, code) {
			return elsecase ?
				(code ? "';}else if(" + unescape(code) + "){out+='" : "';}else{out+='") :
				(code ? "';if(" + unescape(code) + "){out+='" : "';}out+='");
		})
		.replace(c.iterate || skip, function(m, iterate, kname, vname) {
			if (!iterate) return "';} } out+='";
			sid+=1;
			kname=kname|| "k";//+sid;
			vname=vname|| "v";//+sid;
			iterate=unescape(iterate);
			return "';var arr"+sid+"="+iterate+";if(arr"+sid+"){for (var "
				+kname+" in arr"+sid+"){"
				+vname+"=arr"+sid+"["+kname+"];out+='";
		})
		.replace(c.stripperl || skip,'') // only strip at the end to keep strip-indent working
		.replace(c.stripperr || skip,'')
		.replace(c.stripperlr || skip,'')
		.replace(c.evaluate || skip, function(m, code) {
			return "';" + unescape(code) + "out+='";
		})
		+ "';return out;")
		.replace(/\n/g, "\\n").replace(/\t/g, '\\t').replace(/\r/g, "\\r")
		.replace(/(\s|;|\}|^|\{)out\+='';/g, '$1').replace(/\+''/g, "");
		//.replace(/(\s|;|\}|^|\{)out\+=''\+/g,'$1out+=');

	if (needhtmlencode) {
		if (!c.selfcontained && _globals && !_globals._encodeHTML) _globals._encodeHTML = doT.encodeHTMLSource(c.doNotSkipEncoded);
		str = "var encodeHTML = typeof _encodeHTML !== 'undefined' ? _encodeHTML : ("
			+ doT.encodeHTMLSource.toString() + "(" + (c.doNotSkipEncoded || '') + "));"
			+ str;
	}
	str = 'var toS=function(a,pad){console.log(a);return (null!==a&&"object"==typeof a?JSON.stringify(a,null,2):String(a)).replace(/\\n/g,"\\n"+pad)};' + str;
	// replace(/^/,pad).
	try {
		// console.log(str)
		return new Function(c.varname, str);
	} catch (e) {
		/* istanbul ignore else */
		if (typeof console !== "undefined") console.log("Could not create a template function: " + str);
		throw e;
	}
};

doT.compile = function(tmpl, def) {
	return doT.template(tmpl, null, def);
};













// var dot = require('dot');
var dot = doT
var fs = require('fs');

dot.templateSettings.strip = false;

var defs = {
	file: function(path) {
  	return fs.readFileSync(defs.templPath + "/" + path, "utf8");
	},
	json: function(path) {
  	return fs.readFileSync(defs.templPath + "/" + path, "utf8");
	}
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
      defs.templPath = context
			var template = dot.template(source, null, defs);
      return template(defs);
    }
  };
};
