package callfunc.test;

import haxe.io.Bytes;
import haxe.Int64;
import utest.Assert;

class TestMemory extends utest.Test {
    public function testAllocFree() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;

        var pointer = memory.alloc(100);

        Assert.notNull(pointer);
        Assert.isFalse(pointer.isNull());
        Assert.notEquals(0, pointer.address);

        memory.free(pointer);
    }

    public function testSizeOf() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;

        Assert.equals(1, memory.sizeOf(DataType.SChar));
    }

    public function testGetPointer() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;
        var address = Int64.make(0, 0xcafe);

        var pointer = memory.getPointer(address);

        Assert.notNull(pointer);
        Assert.isFalse(pointer.isNull());
        Assert.notEquals(0, pointer.address);
    }

    #if sys
    public function testBytesToPointer() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;
        var bytes = Bytes.alloc(8);

        bytes.setInt32(0, 12345678);
        bytes.setInt32(4, 87654321);

        var pointer = memory.bytesToPointer(bytes);

        Assert.notNull(pointer);
        Assert.isFalse(pointer.isNull());
        Assert.notEquals(0, pointer.address);
        Assert.equals(12345678, pointer.get(DataType.SInt32, 0));
        Assert.equals(87654321, pointer.get(DataType.SInt32, 4));

        bytes.setInt32(0, 1111);
        bytes.setInt32(4, 2222);

        Assert.equals(1111, pointer.get(DataType.SInt32, 0));
        Assert.equals(2222, pointer.get(DataType.SInt32, 4));
    }

    public function testPointerToBytes() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;
        var pointer = memory.alloc(8, true);

        pointer.set(12345678, DataType.SInt32, 0);
        pointer.set(87654321, DataType.SInt32, 4);

        var bytes = memory.pointerToBytes(pointer, 8);

        Assert.equals(12345678, bytes.getInt32(0));
        Assert.equals(87654321, bytes.getInt32(4));

        pointer.set(1111, DataType.SInt32, 0);
        pointer.set(2222, DataType.SInt32, 4);

        Assert.equals(1111, bytes.getInt32(0));
        Assert.equals(2222, bytes.getInt32(4));

        memory.free(pointer);
    }
    #end

    public function testPointerToDataView() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;
        var pointer = memory.alloc(8, true);

        pointer.set(12345678, DataType.SInt32, 0);
        pointer.set(87654321, DataType.SInt32, 4);

        var view = memory.pointerToDataView(pointer, 8);

        Assert.equals(12345678, view.getInt32(0));
        Assert.equals(87654321, view.getInt32(4));

        pointer.set(1111, DataType.SInt32, 0);
        pointer.set(2222, DataType.SInt32, 4);

        Assert.equals(1111, view.getInt32(0));
        Assert.equals(2222, view.getInt32(4));

        memory.free(pointer);
    }
}
