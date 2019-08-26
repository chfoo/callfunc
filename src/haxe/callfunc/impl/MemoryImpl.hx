package callfunc.impl;

import callfunc.impl.ExternDef.ExternBytesData;
import haxe.Int64;
import haxe.ds.Vector;
import haxe.io.ArrayBufferView;
import haxe.io.Bytes;
import haxe.io.BytesData;

using Safety;

class MemoryImpl implements Memory {
    final sizeOfTable:Vector<Int>;
    final context:ContextImpl;

    public function new(context:ContextImpl) {
        this.context = context;
        sizeOfTable = getSizeOfTable();
    }

    public function alloc(size:Int, initZero:Bool = false):Pointer {
        var nativePointer = ExternDef.alloc(size, initZero);

        if (nativePointer == null) {
            throw "Alloc failed";
        }

        return new PointerImpl(
            #if cpp
            cpp.Pointer.fromRaw(nativePointer)
            #else
            nativePointer
            #end
            , context);
    }

    public function free(pointer:Pointer) {
        var pointerImpl = cast(pointer, PointerImpl);
        ExternDef.free(pointerImpl.nativePointer);
    }

    public function sizeOf(type:DataType):Int {
        switch type {
            case DataType.UInt8: return sizeOfTable.get(0);
            case DataType.SInt8: return sizeOfTable.get(1);
            case DataType.UInt16: return sizeOfTable.get(2);
            case DataType.SInt16: return sizeOfTable.get(3);
            case DataType.UInt32: return sizeOfTable.get(4);
            case DataType.SInt32: return sizeOfTable.get(5);
            case DataType.UInt64: return sizeOfTable.get(6);
            case DataType.SInt64: return sizeOfTable.get(7);
            case DataType.Float: return sizeOfTable.get(8);
            case DataType.Double: return sizeOfTable.get(9);
            case DataType.UChar: return sizeOfTable.get(10);
            case DataType.SChar: return sizeOfTable.get(11);
            case DataType.UShort: return sizeOfTable.get(12);
            case DataType.SShort: return sizeOfTable.get(13);
            case DataType.SInt: return sizeOfTable.get(14);
            case DataType.UInt: return sizeOfTable.get(15);
            case DataType.SLong: return sizeOfTable.get(16);
            case DataType.ULong: return sizeOfTable.get(17);
            case DataType.Pointer: return sizeOfTable.get(18);
            case DataType.LongDouble: return sizeOfTable.get(19);
            case DataType.ComplexFloat: return sizeOfTable.get(20);
            case DataType.ComplexDouble: return sizeOfTable.get(21);
            case DataType.ComplexLongDouble: return sizeOfTable.get(22);
            case DataType.Size: return sizeOfTable.get(23);
            case DataType.PtrDiff: return sizeOfTable.get(24);
            case DataType.WChar: return sizeOfTable.get(25);
            default: throw "not supported";
        }
    }

    function getSizeOfTable() {
        var buffer = Bytes.alloc(27);

        ExternDef.getSizeOfTable(bytesToBytesData(buffer));

        var table = new Vector(buffer.length);

        for (index in 0...buffer.length) {
            table.set(index, buffer.get(index));
        }
        return table;
    }

    public static function bytesToBytesData(bytes:Bytes):ExternBytesData {
        #if cpp
        var array = bytes.getData();
        return cpp.Pointer.ofArray(array);

        #elseif hl
        return hl.Bytes.fromBytes(bytes);

        #else
        #error
        #end
    }

    public function getPointer(address:Int64):Pointer {
        var nativePointer = ExternDef.int64ToPointer(address);

        return new PointerImpl(
            #if cpp
            cpp.Pointer.fromRaw(nativePointer)
            #else
            nativePointer
            #end
            , context);
    }

    public function bytesToPointer(bytes:Bytes):Pointer {
        #if cpp
        var managedPointer = bytesToBytesData(bytes);
        return new PointerImpl(cast managedPointer.raw, context);

        #elseif hl
        return getPointer(bytesToBytesData(bytes).address());

        #else
        #error

        #end
    }

    public function pointerToBytes(pointer:Pointer, count:Int):Bytes {
        #if cpp
        var bytesData = new BytesData();
        var pointerImpl = cast(pointer, PointerImpl);
        cpp.NativeArray.setUnmanagedData(
            bytesData,
            cast cpp.Pointer.fromRaw(pointerImpl.nativePointer),
            count);
        return Bytes.ofData(bytesData);

        #elseif hl

        var hlBytes = hl.Bytes.fromAddress(pointer.address);
        return hlBytes.toBytes(count);

        #else
        #error

        #end
    }

    public function pointerToDataView(pointer:Pointer, count:Int):DataView {
        return new BytesDataView(pointerToBytes(pointer, count));
    }
}
