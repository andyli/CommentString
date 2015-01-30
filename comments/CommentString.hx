package comments;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.*;
using haxe.macro.ExprTools;
import sys.io.*;
using StringTools;
using Lambda;
#end

class CommentString {
	macro static public function comment(transforms:Array<ExprOf<String->String>>):ExprOf<String> {
		var pos = Context.getPosInfos(Context.currentPos());
		var str = File.getContent(Context.resolvePath(pos.file)).substring(pos.max);
		var cms = try {
			readComments(str, pos.max);
		} catch (e:Dynamic) {
			Context.error(e, Context.currentPos());
		}

		if (cms.length == 0)
			Context.error("No comment was found.", Context.currentPos());

		var exprs = [for (l in cms) {
			var pos = Context.makePosition({ file: pos.file, min: l.min, max: l.min + l.str.length});
			macro @:pos(pos) $v{l.str};
		}];
		var expr = exprs.slice(1).fold(function(l, e) {
			return macro $e + $l;
		}, exprs[0]);

		while (transforms.length > 0) {
			var t = transforms.shift();
			expr = macro @:pos(t.pos) $t($expr);
		}

		return expr;
	}

	macro static public function format(string:ExprOf<String>):ExprOf<String> {
		return switch (string.expr) {
			case EConst(CString(s)):
				MacroStringTools.formatString(s, string.pos);
			case EBinop(OpAdd, e1, e2):
				macro comments.CommentString.format($e1) + comments.CommentString.format($e2);
			case _:
				var inner = Context.getTypedExpr(Context.typeExpr(string));
				switch (inner.expr) {
					case EConst(CString(_)) | EBinop(OpAdd, _, _):
						macro comments.CommentString.format($inner);
					case _:
						throw "expecting string literals.";
				}
		}
	}

	macro static public function unindent(string:ExprOf<String>):ExprOf<String> {
		return switch (string) {
			case e = {expr:EConst(CString(string)), pos:pos}:
				var spR = ~/^\s+/; //spaces
				var allSpR = ~/^\s*$/; //all spaces
				var posInfos = Context.getPosInfos(pos);

				var lines = breakDown(string, posInfos);

				var indents = 
				[
					for (line in lines) 
						if (spR.match(line.line))
							spR.matched(0);
						else
							""
				];
				indents.sort(function(s1, s2) return s1.length - s2.length);
				while (indents.length > 0) {
					var ind = indents.pop();
					if (ind.length == 0) break;
					if (lines.foreach(function(l) return allSpR.match(l.line) || l.line.startsWith(ind))) {
						var lines = [
							for (l in lines)
							allSpR.match(l.line) ?
								{
									var pos = Context.makePosition({file:posInfos.file, min: l.min, max: l.max});
									macro @:pos(pos) $v{l.lb};
								}:
								{
									var pos = Context.makePosition({file:posInfos.file, min: l.min, max: l.max});
									macro @:pos(pos) $v{l.line.substr(ind.length) + l.lb};
								}
						];
						return lines.slice(1).fold(function(l, e) {
							return macro $e + $l;
						}, lines[0]);
					}
				}
				return e;
			case _:
				var inner = Context.getTypedExpr(Context.typeExpr(string));
				macro @:pos(string.pos) comments.StringTransform.unindent($inner);
		}
	}

	#if macro
	static function breakDown(s:String, posInfos:{min:Int, max:Int}):Array<{line:String, lb:String, min:Int, max:Int}> {
		var linebreakR = ~/(?:\r\n|\n)/g;
		var lines = [];
		var min = posInfos.min;
		var correctPos = s.length == posInfos.max - posInfos.min;
		// trace(correctPos);
		while (linebreakR.match(s)) {
			var line = linebreakR.matchedLeft();
			var lb = linebreakR.matched(0);
			var max = correctPos ? min + line.length + lb.length : posInfos.max;
			lines.push({
				line: line,
				lb: lb,
				min: min,
				max: max,
			});
			s = linebreakR.matchedRight();
			if (correctPos) min = max;
		}
		lines.push({
			line: s,
			lb: "",
			min: min,
			max: correctPos ? min + s.length : posInfos.max
		});
		return lines;
	}
	/**
		Read comments, skip spaces, until there is something is neither comment or space.
	**/
	static function readComments(string:String, min:Int):Array<{str:String, min:Int}> {
		var cm = []; //all the comment strings

		var mlR  = ~/(?s)^\/\*(.*?)\*\//;              //multi-line comment, i.e. /*comment*/
		var slsR = ~/^\/\/([^\r\n]*\r?\n)(?=\s*\/\/)/; //single-line comment, follows by another single-line comment
		var slR  = ~/^\/\/([^\r\n]*)/;                 //single-line comment, i.e. //comment
		var spR  = ~/^\s+/;                            //spaces
		while (string != "") {
			if (mlR.match(string)) {
				min += mlR.matched(0).length - mlR.matched(1).length - 2;
				var c = { str: mlR.matched(1), min: min };
				if (c.str.startsWith("*") || c.str.endsWith("*")) {
					var lines = breakDown(c.str, {min:c.min, max: c.min+c.str.length-1});
					if (c.str.startsWith("*")) {
						var first = lines.shift();
						if (!~/^\*\s*$/.match(first.line)) {
							throw "There should not be any non-space character in the first line, after `/**`.";
						}
					}
					if (c.str.endsWith("*")) {
						var last = lines.pop();
						if (!~/^\s*\*$/.match(last.line)) {
							throw "There should not be any non-space character in the last line, before `**/`.";
						}
					}
					{
						var last = lines[lines.length-1];
						var correctPos = last.line.length + last.lb.length == last.max - last.min;
						// trace(correctPos);
						if (correctPos) {
							last.max -= last.lb.length;
						}
						last.lb = "";
					}
					c = lines.length > 0 ? { str:[for (l in lines) l.line + l.lb].join(""), min: lines[0].min } : null;
				}
				if (c != null)
					cm.push(c);
				min += mlR.matched(0).length;
				string = mlR.matchedRight();
			} else if (slsR.match(string)) {
				min += 2;
				cm.push({
					str: slsR.matched(1),
					min: min
				});
				min += slsR.matched(0).length;
				string = slsR.matchedRight();
			}  else if (slR.match(string)) {
				min += 2;
				cm.push({
					str: slR.matched(1),
					min: min
				});
				min += slR.matched(0).length;
				string = slR.matchedRight();
			} else if (spR.match(string)) {
				min += spR.matched(0).length;
				string = spR.matchedRight();
			} else {
				break;
			}
		}

		return cm;
	}
	#end
}