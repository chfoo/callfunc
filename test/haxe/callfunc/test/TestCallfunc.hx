package callfunc.test;

import callfunc.core.CoreDataTypeTable;
import haxe.io.Bytes;
import haxe.Int64;
import utest.Assert;

using callfunc.core.DataTypeTools;

class TestCallfunc extends utest.Test {
    public function testAllocFree() {
        var ffi = Callfunc.instance();

        var pointer = ffi.alloc(100);

        Assert.notNull(pointer);
        Assert.isFalse(pointer.isNull());
        Assert.notEquals(0, pointer.address);

        pointer.free();
    }

    public function testSizeOf() {
        var ffi = Callfunc.instance();

        Assert.equals(1, ffi.sizeOf(DataType.UInt8));
        Assert.equals(1, ffi.sizeOf(DataType.SInt8));
        Assert.equals(2, ffi.sizeOf(DataType.UInt16));
        Assert.equals(2, ffi.sizeOf(DataType.SInt16));
        Assert.equals(4, ffi.sizeOf(DataType.UInt32));
        Assert.equals(4, ffi.sizeOf(DataType.SInt32));
        Assert.equals(8, ffi.sizeOf(DataType.UInt64));
        Assert.equals(8, ffi.sizeOf(DataType.SInt64));
        Assert.equals(4, ffi.sizeOf(DataType.Float));
        Assert.equals(8, ffi.sizeOf(DataType.Double));
        Assert.isTrue(ffi.sizeOf(DataType.UChar) >= 1);
        Assert.isTrue(ffi.sizeOf(DataType.SChar) >= 1);
        Assert.isTrue(ffi.sizeOf(DataType.UShort) >= 2);
        Assert.isTrue(ffi.sizeOf(DataType.SShort) >= 2);
        Assert.isTrue(ffi.sizeOf(DataType.SInt) >= 2);
        Assert.isTrue(ffi.sizeOf(DataType.UInt) >= 2);
        Assert.isTrue(ffi.sizeOf(DataType.SLong) >= 4);
        Assert.isTrue(ffi.sizeOf(DataType.ULong) >= 4);
        Assert.isTrue(ffi.sizeOf(DataType.Pointer) >= 2);
        Assert.isTrue(ffi.sizeOf(DataType.LongDouble) >= 0);
        Assert.isTrue(ffi.sizeOf(DataType.ComplexFloat) >= 0);
        Assert.isTrue(ffi.sizeOf(DataType.ComplexDouble) >= 0);
        Assert.isTrue(ffi.sizeOf(DataType.ComplexLongDouble) >= 0);
        Assert.isTrue(ffi.sizeOf(DataType.Size) >= 0);
        Assert.isTrue(ffi.sizeOf(DataType.PtrDiff) >= 0);
        Assert.isTrue(ffi.sizeOf(DataType.WChar) >= 0);
    }

    public function testGetPointer() {
        var ffi = Callfunc.instance();
        var address = Int64.make(0, 0xcafe);

        var pointer = ffi.getPointer(address);

        Assert.notNull(pointer);
        Assert.isFalse(pointer.isNull());
        Assert.notEquals(0, pointer.address);
        Assert.isTrue(Int64.eq(address, pointer.address));
    }

    #if sys
    public function testBytesToPointer() {
        var ffi = Callfunc.instance();
        var bytes = Bytes.alloc(8);

        bytes.setInt32(0, 12345678);
        bytes.setInt32(4, 87654321);

        var pointer = ffi.bytesToPointer(bytes);

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
        var ffi = Callfunc.instance();

        Assert.same(CoreDataType.SInt8, ffi.context.toCoreDataType(DataType.SInt8));
        Assert.same(CoreDataType.Double, ffi.context.toCoreDataType(DataType.Double));
        Assert.same(CoreDataType.Void, ffi.context.toCoreDataType(DataType.Void));

        Assert.notEquals(CoreDataType.UChar, ffi.context.toCoreDataType(DataType.UChar, true));
        Assert.notEquals(CoreDataType.SChar, ffi.context.toCoreDataType(DataType.SChar, true));
        Assert.notEquals(CoreDataType.SInt, ffi.context.toCoreDataType(DataType.SInt, true));
        Assert.notEquals(CoreDataType.UInt, ffi.context.toCoreDataType(DataType.UInt, true));
        Assert.notEquals(CoreDataType.SLong, ffi.context.toCoreDataType(DataType.SLong, true));
        Assert.notEquals(CoreDataType.ULong, ffi.context.toCoreDataType(DataType.ULong, true));

        for (dataType in [DataType.Size, DataType.PtrDiff, DataType.WChar]) {
            if (ffi.sizeOf(dataType) > 0) {
                ffi.context.toCoreDataType(dataType);
            }
        }
    }

    public function testCoreDataTypeTable() {
        var ffi = Callfunc.instance();
        final table = new CoreDataTypeTable(ffi.context);

        Assert.same(CoreDataType.SInt8, table.toCoreDataType(DataType.SInt8));
        Assert.same(CoreDataType.Double, table.toCoreDataType(DataType.Double));
        Assert.same(CoreDataType.Void, table.toCoreDataType(DataType.Void));

        Assert.notEquals(CoreDataType.UChar, table.toCoreDataType(DataType.UChar, true));
        Assert.notEquals(CoreDataType.SChar, table.toCoreDataType(DataType.SChar, true));
        Assert.notEquals(CoreDataType.SInt, table.toCoreDataType(DataType.SInt, true));
        Assert.notEquals(CoreDataType.UInt, table.toCoreDataType(DataType.UInt, true));
        Assert.notEquals(CoreDataType.SLong, table.toCoreDataType(DataType.SLong, true));
        Assert.notEquals(CoreDataType.ULong, table.toCoreDataType(DataType.ULong, true));

        for (dataType in [DataType.Size, DataType.PtrDiff, DataType.WChar]) {
            if (ffi.sizeOf(dataType) > 0) {
                table.toCoreDataType(dataType);
            }
        }
    }
}
