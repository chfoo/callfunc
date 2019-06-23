package callfunc.test;

import haxe.Int64;
import utest.Assert;
import haxe.io.Bytes;
import callfunc.BytesDataView;
import utest.Test;

class TestDataView extends Test {
    public function testGetSet() {
        var view:DataView = new BytesDataView(Bytes.alloc(24), 8, 8);

        view.set(0, 123);
        Assert.equals(123, view.get(0));

        view.setUInt8(0, 123);
        Assert.equals(123, view.getUInt8(0));
        view.setInt8(0, -123);
        Assert.equals(-123, view.getInt8(0));

        view.setUInt16(0, 12345);
        Assert.equals(12345, view.getUInt16(0));
        view.setInt16(0, -32100);
        Assert.equals(-32100, view.getInt16(0));

        view.setUInt32(0, 12345678);
        Assert.equals(12345678, view.getUInt32(0));
        view.setInt32(0, -12345678);
        Assert.equals(-12345678, view.getInt32(0));

        view.setInt64(0, Int64.fromFloat(-12345678901234));
        Assert.isTrue(Int64.fromFloat(-12345678901234) == view.getInt64(0));

        view.setFloat(0, 123.456);
        Assert.floatEquals(123.456, view.getFloat(0));

        view.setDouble(0, 123.456);
        Assert.floatEquals(123.456, view.getDouble(0));
    }

    public function testFill() {
        var view:DataView = new BytesDataView(Bytes.alloc(24), 8, 8);

        view.fill(0, 8, 123);

        for (index in 0...8) {
            Assert.equals(123, view.get(index));
        }
    }

    public function testBlit() {
        var view:DataView = new BytesDataView(Bytes.alloc(24), 8, 8);
        var view2:DataView = new BytesDataView(Bytes.alloc(24), 8, 8);

        view.set(0, 1);
        view.set(1, 2);
        view.set(2, 3);
        view.set(3, 4);

        view2.blit(2, view, 2, 1);

        Assert.equals(0, view2.get(0));
        Assert.equals(0, view2.get(1));
        Assert.equals(3, view2.get(2));
        Assert.equals(0, view2.get(3));
    }

    public function testSub() {
        var view:DataView = new BytesDataView(Bytes.alloc(24), 8, 8);
        var view2 = view.sub(2, 2);

        view.set(2, 123);

        Assert.equals(10, view2.byteOffset);
        Assert.equals(2, view2.byteLength);
        Assert.equals(123, view2.get(0));
        Assert.equals(0, view2.get(1));
    }
}
