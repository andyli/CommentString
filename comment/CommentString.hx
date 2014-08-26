package comment;

import haxe.macro.Context;
import haxe.macro.Expr;
using StringTools;
using Lambda;

class CommentString {
	static function process<T>(?comment:ExprOf<Array<T>>):String {
		var pos = switch (comment) {
			case (macro [${null}]) | (macro @:this this) | (macro null):
				Context.getPosInfos(comment.pos);
			case _: throw comment;
		}
		
		var str = sys.io.File.getContent(Context.resolvePath(pos.file)).substring(pos.min, pos.max);
		var callR = ~/(?s)[\(\[](.*)[\)\]]/;
		callR.match(str);
		var argStr = callR.matched(1); //the part within () or []
		var cm = []; //all the comment strings

		var mlR = ~/(?s)^\/\*(.*?)\*\//; //multi-line comment, i.e. /*comment*/
		var slR = ~/^\/\/(.*[\r\n]+)/;   //single-line comment, i.e. //comment
		var spR = ~/^\s+/;               //spaces
		while (argStr != "") {
			if (mlR.match(argStr)) {
				var c = mlR.matched(1);
				if (c.startsWith("*") || c.endsWith("*")) {
					var lines = ~/(?:\r\n|\n)/g.split(c);
					if (c.startsWith("*"))
						lines.shift();
					if (c.endsWith("*"))
						lines.pop();
					c = lines.join(c.indexOf("\r\n") >= 0 ? "\r\n" : "\n");
				}
				cm.push(c);
				argStr = mlR.matchedRight();
			} else if (slR.match(argStr)) {
				cm.push(slR.matched(1));
				argStr = slR.matchedRight();
			} else if (spR.match(argStr)) {
				argStr = spR.matchedRight();
			} else {
				throw argStr;
			}
		}

		return cm.join("");
	}

	macro static public function istr<T>(?comment:ExprOf<Array<T>>):ExprOf<String> {
		return haxe.macro.MacroStringTools.formatString(process(comment), comment.pos);
	}
	macro static public function str<T>(?comment:ExprOf<Array<T>>):ExprOf<String> {
		return macro $v{process(comment)};
	}

	static public function unindent(string:String):String {
		var spR = ~/^\s+/; //spaces
		var lines = ~/(?:\r\n|\n)/g.split(string);

		var indents = 
		[
			for (line in lines)
				if (spR.match(line))
					spR.matched(0);
				else
					""
		];
		indents.sort(function(s1, s2) return s1.length - s2.length);
		while (indents.length > 0) {
			var ind = indents.pop();
			if (lines.foreach(function(l) return l.startsWith(ind))) {
				lines = [for (l in lines) l.substr(ind.length)];
				return lines.join(string.indexOf("\r\n") >= 0 ? "\r\n" : "\n");
			}
		}
		return string;
	}
}