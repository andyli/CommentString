CommentString
=============

[![TravisCI Build Status](https://travis-ci.org/andyli/CommentString.svg?branch=master)](https://travis-ci.org/andyli/CommentString)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/andyli/CommentString?branch=master&svg=true)](https://ci.appveyor.com/project/andyli/CommentString)

A Haxe library that allows you to use `/*Comment*/` as [Heredoc String](http://en.wikipedia.org/wiki/Here_document).

## Usage

```haxe

import comments.CommentString.*;

class Test {
	static function main():Void {
		var name = "John";
		var age = 33;
		var str = comment(unindent, format) /**
			My name is <strong>$name</strong> and I'm <em>$age</em> years old.
		**/;
		trace(str); // Test.hx:10: My name is <strong>John</strong> and I'm <em>33</em> years old.
	}
}
```

## Details

`CommentString.comment()` is a macro function that will read the immediately trailing comment(s) and 
return it as a constant `String`.

It accepts optional, variable-lengthed `transform:String->String` arguments to format the `String`.
There are 2 transform functions provided by `CommentString`:

 * `unindent` is a macro function that removes the leading indentation of each line.
 * `format` is a macro function that applies [Haxe string interpolation](http://haxe.org/manual/lf-string-interpolation.html).
 
Note that custom transform function, being macro function or not, can also be used.

Despite of normal haxe single-line comment `//comment`, or multi-line comment `/*comment*/`, 
there is a special one:
```haxe
var str = comment()
/**
Comment.
**/;
```
which will trim the first and the last lines, such that the above would be `"Comment."` instead of `"\nComment.\n"`. Notice the `;` has to be placed after the comment.

It is also possible to use multiple single-line comments:
```haxe
var str = comment(unindent)
// A sentence
// that is
// so long.
;
```
which will be read as `"A sentence\nthat is\nso long."`. It is useful since a lot of editors allow commenting out block of text in this style (e.g. Sublime Text, <kbd>ctrl</kbd> + <kbd>/</kbd>). Additionally in this style there is no need to escape anything in the comment, unlike `/**/` which you have to avoid `*/` in the comment. However, usually the `unindent` transform is needed since there are spaces after `//`.

## Like CommentString?

Support me to maintain it -> http://www.patreon.com/andyli

## License

The MIT License (MIT)

> Copyright (c) 2015 Andy Li

> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:

> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.

> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.
