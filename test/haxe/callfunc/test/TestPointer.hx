package callfunc.test;

import haxe.Int64;
import utest.Assert;

class TestPointer extends utest.Test {
    public function testGetSet() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;

        var pointer = memory.alloc(8);

        pointer.set(-1, DataType.SInt8);
        Assert.equals(-1, pointer.get(DataType.SInt8));

        pointer.set(200, DataType.UInt8);
        Assert.equals(200, pointer.get(DataType.UInt8));

        pointer.set(11111, DataType.UInt16);
        Assert.equals(11111, pointer.get(DataType.UInt16, 0));

        pointer.set(50000, DataType.UInt16);
        Assert.equals(50000, pointer.get(DataType.UInt16, 0));

        pointer.set(-32111, DataType.SInt16);
        Assert.equals(-32111, pointer.get(DataType.SInt16));

        pointer.set(-11111111, DataType.SInt32);
        Assert.equals(-11111111, pointer.get(DataType.SInt32));

        pointer.set(0xffaabbcc, DataType.UInt32);
        Assert.equals(0xffaabbcc, pointer.get(DataType.UInt32));

        pointer.set(Int64.make(0x12345678, 0xc001cafe), DataType.SInt64);
        // Assert.equals(Int64.make(0x12345678, 0xc001cafe), pointer.get(DataType.SInt64));
        Assert.isTrue(Int64.make(0x12345678, 0xc001cafe) == pointer.get(DataType.SInt64));

        pointer.set(123.456, DataType.Float);
        Assert.floatEquals(123.456, pointer.get(DataType.Float, 0));

        pointer.set(123.456, DataType.Double);
        Assert.equals(123.456, pointer.get(DataType.Double, 0));

        memory.free(pointer);
    }

    public function testPointerArray() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;

        var pointer = memory.alloc(16);

        pointer.arraySet(0, 1, DataType.SInt32);
        pointer.arraySet(1, 2, DataType.SInt32);
        pointer.arraySet(2, 3, DataType.SInt32);
        pointer.arraySet(3, 4, DataType.SInt32);

        Assert.equals(1, pointer.arrayGet(0, DataType.SInt32));
        Assert.equals(2, pointer.arrayGet(1, DataType.SInt32));
        Assert.equals(3, pointer.arrayGet(2, DataType.SInt32));
        Assert.equals(4, pointer.arrayGet(3, DataType.SInt32));

        memory.free(pointer);
    }

    public function testDefaultDataType() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;

        var pointer = memory.alloc(8);
        pointer.dataType = DataType.SInt16;

        function clear () {
            for (index in 0...8) {
                pointer.set(0, DataType.SInt8, index);
            }
        }

        // These tests assume little endian
        clear();
        pointer.set(-1);
        Assert.equals(-1, pointer.get());
        Assert.equals(0xffff, pointer.get(DataType.SInt32));

        clear();
        pointer.set(0xc001cafe, DataType.SInt32);
        Assert.equals(-13570, pointer.get());

        clear();
        pointer.arraySet(0, -1);
        Assert.equals(-1, pointer.arrayGet(0));
        Assert.equals(0xffff, pointer.arrayGet(0, DataType.SInt32));

        clear();
        pointer.arraySet(0, 0xc001cafe, DataType.SInt32);
        Assert.equals(-13570, pointer.arrayGet(0));

        memory.free(pointer);
    }
}
