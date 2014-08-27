package comments;

using StringTools;
using Lambda;

class StringTransform {
	static public function unindent(string:String):String {
		var spR = ~/^\s+/; //spaces
		var allSpR = ~/^\s*$/; //all spaces
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
			if (lines.foreach(function(l) return allSpR.match(l) || l.startsWith(ind))) {
				lines = [for (l in lines) allSpR.match(l) ? "" : l.substr(ind.length)];
				return lines.join(string.indexOf("\r\n") >= 0 ? "\r\n" : "\n");
			}
		}
		return string;
	}
}