package callfunc.test;

import utest.Assert;
import haxe.Int64;
import utest.Test;

class TestAnyInt extends Test {
    public function testToInt() {
        var a:AnyInt = 123;
        var b:AnyInt = Int64.make(123, 456);
        var c:AnyInt = "abc";

        Assert.equals(123, a.toInt());
        Assert.equals(456, b.toInt());
        Assert.raises(b.toInt.bind(true), String);

        Assert.raises(() -> c.toInt(), String);
    }

    public function testToInt64() {
        var a:AnyInt = 123;
        var b:AnyInt = Int64.make(123, 456);
        var c:AnyInt = "abc";

        Assert.isTrue(Int64.eq(Int64.make(0, 123), a.toInt64()));
        Assert.isTrue(Int64.eq(Int64.make(123, 456), b.toInt64()));
        Assert.raises(() -> c.toInt64(), String);
    }
}
