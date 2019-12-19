package callfunc.test;

import haxe.io.Bytes;
import haxe.Int64;
import utest.Assert;

using callfunc.core.DataTypeTools;

class TestCallfunc extends utest.Test {
    public function testAllocFree() {
        var callfunc = Callfunc.instance();

        var pointer = callfunc.alloc(100);

        Assert.notNull(pointer);
        Assert.isFalse(pointer.isNull());
        Assert.notEquals(0, pointer.address);

        pointer.free();
    }

    public function testSizeOf() {
        var callfunc = Callfunc.instance();

        Assert.equals(1, callfunc.sizeOf(DataType.UInt8));
        Assert.equals(1, callfunc.sizeOf(DataType.SInt8));
        Assert.equals(2, callfunc.sizeOf(DataType.UInt16));
        Assert.equals(2, callfunc.sizeOf(DataType.SInt16));
        Assert.equals(4, callfunc.sizeOf(DataType.UInt32));
        Assert.equals(4, callfunc.sizeOf(DataType.SInt32));
        Assert.equals(8, callfunc.sizeOf(DataType.UInt64));
        Assert.equals(8, callfunc.sizeOf(DataType.SInt64));
        Assert.equals(4, callfunc.sizeOf(DataType.Float));
        Assert.equals(8, callfunc.sizeOf(DataType.Double));
        Assert.isTrue(callfunc.sizeOf(DataType.UChar) >= 1);
        Assert.isTrue(callfunc.sizeOf(DataType.SChar) >= 1);
        Assert.isTrue(callfunc.sizeOf(DataType.UShort) >= 2);
        Assert.isTrue(callfunc.sizeOf(DataType.SShort) >= 2);
        Assert.isTrue(callfunc.sizeOf(DataType.SInt) >= 2);
        Assert.isTrue(callfunc.sizeOf(DataType.UInt) >= 2);
        Assert.isTrue(callfunc.sizeOf(DataType.SLong) >= 4);
        Assert.isTrue(callfunc.sizeOf(DataType.ULong) >= 4);
        Assert.isTrue(callfunc.sizeOf(DataType.Pointer) >= 2);
        Assert.isTrue(callfunc.sizeOf(DataType.LongDouble) >= 0);
        Assert.isTrue(callfunc.sizeOf(DataType.ComplexFloat) >= 0);
        Assert.isTrue(callfunc.sizeOf(DataType.ComplexDouble) >= 0);
        Assert.isTrue(callfunc.sizeOf(DataType.ComplexLongDouble) >= 0);
        Assert.isTrue(callfunc.sizeOf(DataType.Size) >= 0);
        Assert.isTrue(callfunc.sizeOf(DataType.PtrDiff) >= 0);

        try {
            Assert.isTrue(callfunc.sizeOf(DataType.WChar) >= 0);
        } catch (error:String) {
            Assert.warn('Possible error or just unsupported on platform: $error');
        }
    }

    public function testGetPointer() {
        var callfunc = Callfunc.instance();
        var address = Int64.make(0, 0xcafe);

        var pointer = callfunc.getPointer(address);

        Assert.notNull(pointer);
        Assert.isFalse(pointer.isNull());
        Assert.notEquals(0, pointer.address);
        Assert.isTrue(Int64.eq(address, pointer.address));
    }

    #if sys
    public function testBytesToPointer() {
        var callfunc = Callfunc.instance();
        var bytes = Bytes.alloc(8);

        bytes.setInt32(0, 12345678);
        bytes.setInt32(4, 87654321);

        var pointer = callfunc.bytesToPointer(bytes);

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
    #end

    public function testToCoreDataType() {
        var callfunc = Callfunc.instance();

        Assert.same(CoreDataType.SInt8, callfunc.context.toCoreDataType(DataType.SInt8));
        Assert.same(CoreDataType.Double, callfunc.context.toCoreDataType(DataType.Double));
        Assert.same(CoreDataType.Void, callfunc.context.toCoreDataType(DataType.Void));

        Assert.notEquals(CoreDataType.UChar, callfunc.context.toCoreDataType(DataType.UChar, true));
        Assert.notEquals(CoreDataType.SChar, callfunc.context.toCoreDataType(DataType.SChar, true));
        Assert.notEquals(CoreDataType.SInt, callfunc.context.toCoreDataType(DataType.SInt, true));
        Assert.notEquals(CoreDataType.UInt, callfunc.context.toCoreDataType(DataType.UInt, true));
        Assert.notEquals(CoreDataType.SLong, callfunc.context.toCoreDataType(DataType.SLong, true));
        Assert.notEquals(CoreDataType.ULong, callfunc.context.toCoreDataType(DataType.ULong, true));

        callfunc.context.toCoreDataType(DataType.Size);
        callfunc.context.toCoreDataType(DataType.PtrDiff);
        callfunc.context.toCoreDataType(DataType.WChar);
    }
}
