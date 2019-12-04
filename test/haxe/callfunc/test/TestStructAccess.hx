package callfunc.test;

import utest.Assert;
import utest.Test;

class TestStructAccess extends Test {
    public function test() {
        var callfunc = Callfunc.instance();
        var pointer = callfunc.alloc(100);
        var structDef = callfunc.defineStruct(
            [DataType.SInt32, DataType.Double, DataType.UInt8],
            ["a", "b", "c"]
        );

        var struct = structDef.access(pointer);

        struct.a = 123;
        struct.b = 123.456;
        struct["c"] = 200;

        Assert.equals(123, struct["a"]);
        Assert.equals(123.456, struct["b"]);
        Assert.equals(200, struct.c);

        Assert.raises(struct.get.bind("nonexist"));
        Assert.raises(struct.set.bind("nonexist", 123));
    }
}
