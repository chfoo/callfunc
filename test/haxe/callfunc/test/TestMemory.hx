package callfunc.test;

import haxe.io.Bytes;
import haxe.Int64;
import utest.Assert;

using callfunc.MemoryTools;

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

        Assert.equals(1, memory.sizeOf(DataType.UInt8));
        Assert.equals(1, memory.sizeOf(DataType.SInt8));
        Assert.equals(2, memory.sizeOf(DataType.UInt16));
        Assert.equals(2, memory.sizeOf(DataType.SInt16));
        Assert.equals(4, memory.sizeOf(DataType.UInt32));
        Assert.equals(4, memory.sizeOf(DataType.SInt32));
        Assert.equals(8, memory.sizeOf(DataType.UInt64));
        Assert.equals(8, memory.sizeOf(DataType.SInt64));
        Assert.equals(4, memory.sizeOf(DataType.Float));
        Assert.equals(8, memory.sizeOf(DataType.Double));
        Assert.isTrue(memory.sizeOf(DataType.UChar) >= 1);
        Assert.isTrue(memory.sizeOf(DataType.SChar) >= 1);
        Assert.isTrue(memory.sizeOf(DataType.UShort) >= 2);
        Assert.isTrue(memory.sizeOf(DataType.SShort) >= 2);
        Assert.isTrue(memory.sizeOf(DataType.SInt) >= 2);
        Assert.isTrue(memory.sizeOf(DataType.UInt) >= 2);
        Assert.isTrue(memory.sizeOf(DataType.SLong) >= 4);
        Assert.isTrue(memory.sizeOf(DataType.ULong) >= 4);
        Assert.isTrue(memory.sizeOf(DataType.Pointer) >= 2);
        Assert.isTrue(memory.sizeOf(DataType.LongDouble) >= 0);
        Assert.isTrue(memory.sizeOf(DataType.ComplexFloat) >= 0);
        Assert.isTrue(memory.sizeOf(DataType.ComplexDouble) >= 0);
        Assert.isTrue(memory.sizeOf(DataType.ComplexLongDouble) >= 0);
        Assert.isTrue(memory.sizeOf(DataType.Size) >= 0);
        Assert.isTrue(memory.sizeOf(DataType.PtrDiff) >= 0);
        Assert.isTrue(memory.sizeOf(DataType.WChar) >= 0);
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

    public function testToCoreDataType() {
        var callfunc = Callfunc.instance();
        var memory = callfunc.memory;

        Assert.same(CoreDataType.SInt8, memory.toCoreDataType(DataType.SInt8));
        Assert.same(CoreDataType.Double, memory.toCoreDataType(DataType.Double));
        Assert.same(CoreDataType.Void, memory.toCoreDataType(DataType.Void));

        Assert.notEquals(CoreDataType.UChar, memory.toCoreDataType(DataType.UChar, true));
        Assert.notEquals(CoreDataType.SChar, memory.toCoreDataType(DataType.SChar, true));
        Assert.notEquals(CoreDataType.SInt, memory.toCoreDataType(DataType.SInt, true));
        Assert.notEquals(CoreDataType.UInt, memory.toCoreDataType(DataType.UInt, true));
        Assert.notEquals(CoreDataType.SLong, memory.toCoreDataType(DataType.SLong, true));
        Assert.notEquals(CoreDataType.ULong, memory.toCoreDataType(DataType.ULong, true));

        memory.toCoreDataType(DataType.Size);
        memory.toCoreDataType(DataType.PtrDiff);
        memory.toCoreDataType(DataType.WChar);
    }
}
