package comments;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;
import sys.io.*;
using StringTools;
#end

class CommentString {
	macro static public function comment(transforms:Array<ExprOf<String->String>>):ExprOf<String> {
		var pos = Context.getPosInfos(Context.currentPos());
		var str = File.getContent(Context.resolvePath(pos.file)).substring(pos.max);
		var cms = try {
			readComments(str);
		} catch (e:Dynamic) {
			Context.error(e, Context.currentPos());
		}

		if (cms.length == 0)
			Context.error("No comment was found.", Context.currentPos());

		var expr:Expr = macro $v{cms.join("")};

		while (transforms.length > 0) {
			var t = transforms.shift();
			expr = macro $t($expr);
		}

		return expr;
	}

	macro static public function format(string:ExprOf<String>):ExprOf<String> {
		return switch (string.expr) {
			case EConst(CString(s)):
				haxe.macro.MacroStringTools.formatString(s, string.pos);
			case _:
				var inner = Context.getTypedExpr(Context.typeExpr(string));
				macro comments.CommentString.format($inner);
		}
	}

	macro static public function unindent(string:ExprOf<String>):ExprOf<String> {
		return switch (string.expr) {
			case EConst(CString(string)):
				macro $v{StringTransform.unindent(string)};
			case _:
				var inner = Context.getTypedExpr(Context.typeExpr(string));
				macro comments.StringTransform.unindent($inner);
		}
	}

	#if macro
	/**
		Read comments, skip spaces, until there is something is neither comment or space.
	**/
	static function readComments(string:String):Array<String> {
		var cm = []; //all the comment strings

		var mlR  = ~/(?s)^\/\*(.*?)\*\//;              //multi-line comment, i.e. /*comment*/
		var slsR = ~/^\/\/([^\r\n]*\r?\n)(?=\s*\/\/)/; //single-line comment, follows by another single-line comment
		var slR  = ~/^\/\/([^\r\n]*)/;                 //single-line comment, i.e. //comment
		var spR  = ~/^\s+/;                            //spaces
		while (string != "") {
			if (mlR.match(string)) {
				var c = mlR.matched(1);
				if (c.startsWith("*") || c.endsWith("*")) {
					var lines = ~/(?:\r\n|\n)/g.split(c);
					if (c.startsWith("*")) {
						var first = lines.shift();
						if (!~/^\*\s*$/.match(first)) {
							throw "There should not be any non-space character in the first line, after `/**`.";
						}
					}
					if (c.endsWith("*")) {
						var last = lines.pop();
						if (!~/^\s*\*$/.match(last)) {
							throw "There should not be any non-space character in the last line, before `**/`.";
						}
					}
					c = lines.length > 0 ? lines.join(c.indexOf("\r\n") >= 0 ? "\r\n" : "\n") : null;
				}
				if (c != null)
					cm.push(c);
				string = mlR.matchedRight();
			} else if (slsR.match(string)) {
				cm.push(slsR.matched(1));
				string = slsR.matchedRight();
			}  else if (slR.match(string)) {
				cm.push(slR.matched(1));
				string = slR.matchedRight();
			} else if (spR.match(string)) {
				string = spR.matchedRight();
			} else {
				break;
			}
		}

		return cm;
	}
	#end
}

enum CM {
	multi(s:String);
	single(s:String);
}