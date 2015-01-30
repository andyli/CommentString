import comments.CommentString.*;

import haxe.unit.*;

typedef Pos = {
	file:String,
	min:Int,
	max:Int,
}

class Test extends TestCase
{

public function testSimple():Void {

assertEquals("", comment() /**/);
assertEquals(
"",
comment() //
);

assertEquals(" ", comment() /* */);

assertEquals("123", comment() /*123*/);

assertEquals(
"123", 
comment() //123
);

} //testSimple


public function testSpace():Void {
assertEquals(" 123 ", comment() /* 123 */);

assertEquals(
"
	123
", comment() /*
	123
*/
);

} //testSpace

public function testMultiple():Void {

assertEquals("123123", comment() /*123*/ /*123*/ );
assertEquals("123123", comment()
	/*123*/
	/*123*/
);

assertEquals(
"123
123",
comment()
	//123
	//123
);

assertEquals(
"123123123123"
, comment()
	//123
	/*123*/
	//123
	/*123*/
);

} //testMultiple

public function testTrim():Void {

assertEquals("123", comment()
	/**
123
	**/
);

assertEquals(
"
123", comment()
	/*
123
	**/
);

assertEquals(
"123
	", comment()
	/**
123
	*/
);

} //testTrim


public function testTransform():Void {
assertEquals("123", comment(unindent)
	/**
		123
	**/
);

assertEquals(
"123
456", comment(unindent)
	/**
		123
		456
	**/
);

assertEquals(
"123
	456", comment(unindent)
	/**
		123
			456
	**/
);

assertEquals(
"	123
456", comment(unindent)
	/**
			123
		456
	**/
);


//have lines with only spaces
assertEquals(
"123

456", comment(unindent)
	/**
		123
	
		456
	**/
);


assertEquals(
"123
456
789", comment(unindent)
	// 123
	// 456
	// 789
);

assertEquals(
"abc
def
ghi", comment(unindent)
	// abc
	// def

	// ghi
);

} //testTransform

public function testInterpolation():Void {

var abc = "ABC";

assertEquals("ABC", comment(format)/*$abc*/);

assertEquals("First letter of \"ABC\": A", comment(format)/*First letter of "$abc": ${abc.charAt(0)}*/);

assertEquals("First letter of \"ABC\": A", comment(unindent, format)/**
	First letter of "$abc": ${abc.charAt(0)}
**/);

} //testInterpolation


public function testError():Void {

assertCompliationError(comment());

assertCompliationError(comment() /****/);

assertCompliationError(comment() 
/**
**/);

assertCompliationError(comment() 
/**0
123
**/);

assertCompliationError(comment() 
/**
123
4**/);

}

public function testPos():Void {

var a1:Pos, a2:Pos;
	'
	${a1 = getPos()}
	test

	${a2 = getPos()}
	';

var b1:Pos, b2:Pos;
comment(format)
	/*
	${b1 = getPos()}
	test

	${b2 = getPos()}
	*/;

assertEquals(a2.min - a1.min, b2.min - b1.min);
assertEquals(a2.max - a1.max, b2.max - b1.max);
assertEquals(a1.max - a1.min, b1.max - b1.min);
assertEquals(a2.max - a2.min, b2.max - b2.min);
assertTrue(b1.min != b2.min);
assertTrue(b1.max != b2.max);



var a1:Pos, a2:Pos;
	'
	${a1 = getPos()}
	test

	${a2 = getPos()}
	';

var b1:Pos, b2:Pos;
comment(unindent, format)
	/*
	${b1 = getPos()}
	test

	${b2 = getPos()}
	*/;

assertEquals(a2.min - a1.min, b2.min - b1.min);
assertEquals(a2.max - a1.max, b2.max - b1.max);
assertEquals(a1.max - a1.min, b1.max - b1.min);
assertEquals(a2.max - a2.min, b2.max - b2.min);
assertTrue(b1.min != b2.min);
assertTrue(b1.max != b2.max);



var a1:Pos, a2:Pos;
	'
	${a1 = getPos()}
	test

	${a2 = getPos()}
	';

var b1:Pos, b2:Pos;
comment(unindent, format)
	/**
	${b1 = getPos()}
	test

	${b2 = getPos()}
	**/;

assertEquals(a2.min - a1.min, b2.min - b1.min);
assertEquals(a2.max - a1.max, b2.max - b1.max);
assertEquals(a1.max - a1.min, b1.max - b1.min);
assertEquals(a2.max - a2.min, b2.max - b2.min);
assertTrue(b1.min != b2.min);
assertTrue(b1.max != b2.max);
}

	macro static function assertCompliationError(e:haxe.macro.Expr) {
		var errored = try {
			haxe.macro.Context.typeof(e);
			haxe.macro.Context.error('expecting compliation error', e.pos);
			false;
		} catch(e:Dynamic) {
			true;
		}
		return macro assertTrue($v{errored});
	}

	macro static function getPos() {
		var pos = haxe.macro.Context.currentPos();
		var posInfo = haxe.macro.Context.getPosInfos(pos);
		return macro $v{posInfo};
	}

	static function main() {
		var runner = new TestRunner();
		runner.add(new Test());
		var success = runner.run();

		#if sys
		Sys.exit(success ? 0 : 1);
		#elseif nodejs
		js.Node.process.exit(success ? 0 : 1);
		#end
	}
}