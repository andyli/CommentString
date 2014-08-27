CommentString
=============

A Haxe library that allows you to use /*Comment*/ as [Heredoc String](http://en.wikipedia.org/wiki/Here_document).

## Usage

```haxe

import comments.CommentString.*;

class Test {
	static function main():Void {
		var name = "Join";
		var age = 33;
		var str = comment(unindent, format) /**
			My name is <strong>$name</strong> and I'm <em>$age</em> years old.
		**/;
		trace(str); // Test.hx:10: My name is <strong>Join</strong> and I'm <em>33</em> years old.
	}
}
```

## Details

`CommentString.comment()` is a macro function that will read the immediately trailing comment(s) and 
reture it as a String constant.

Despite of normal haxe single-line comment `//comment`, or multi-line comment `/*comment*/`, 
there is a special one:

```haxe
/**
Comment.
**/
```
which will trim the first and the last lines, such that the above would be `"Comment."` instead of `"\nComment.\n"`.

`CommentString.comment()` accepts optional, variable-lengthed `transform:String->String` arguments to format the String.
There are 2 transform functions provided by `CommentString`:

 * `unindent` is a macro function that removes the leading indentation of each line.
 * `format` is a macro function that applies [Haxe string interpolation](http://haxe.org/manual/lf-string-interpolation.html).
 
Note that custom transform function, being macro function or not, can also be used.
