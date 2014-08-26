import comment.CommentString.*;
import comment.CommentString.str in cm;
using comment.CommentString;

import haxe.unit.*;

class Test extends TestCase
{

public function testSimple():Void {
assertEquals("123", str(/*123*/));
assertEquals("123", CommentString.str(/*123*/));
assertEquals("123", cm(/*123*/));
assertEquals("123", [/*123*/].str());

assertEquals("123", str( /*123*/ ));
assertEquals("123", CommentString.str( /*123*/ ));
assertEquals("123", cm( /*123*/ ));
assertEquals("123", [ /*123*/ ].str());

assertEquals("123", str(
	/*123*/
));
assertEquals("123", CommentString.str(
	/*123*/
));
assertEquals("123", cm(
	/*123*/
));
assertEquals("123", [
	/*123*/
].str());
} //testSimple


public function testSpace():Void {
assertEquals(" 123 ", str(/* 123 */));

assertEquals("
	123
", str(/*
	123
*/));
} //testSpace

public function testMultiple():Void {

assertEquals("123123", str(/*123*//*123*/));
assertEquals("123123", str(
	/*123*/
	/*123*/
));

assertEquals(
"123
123
"
, str(
	//123
	//123
)
);

assertEquals(
"123
123123
123"
, str(
	//123
	/*123*/
	//123
	/*123*/
)
);

} //testMultiple

public function testTrim():Void {

assertEquals("123", str(
	/**
123
	**/
));

assertEquals(
"
123", str(
	/*
123
	**/
)
);

assertEquals(
"123
	", str(
	/**
123
	*/
)
);

} //testTrim

public function testUnindent():Void {

assertEquals("123", unindent(str(
	/**
		123
	**/
)));

assertEquals(
"123
456", unindent(str(
	/**
		123
		456
	**/
)));

assertEquals(
"123
	456", unindent(str(
	/**
		123
			456
	**/
)));

assertEquals(
"	123
456", unindent(str(
	/**
			123
		456
	**/
)));

} //testUnindent

public function testInterpolation():Void {

var abc = "ABC";

assertEquals("ABC", istr(/*$abc*/));

assertEquals("First letter of \"ABC\": A", istr(/*First letter of "$abc": ${abc.charAt(0)}*/));

} //testInterpolation

	static function main() {
		var runner = new TestRunner();
		runner.add(new Test());
		var success = runner.run();

		#if sys
		Sys.exit(success ? 0 : 1);
		#end
	}
}