package callfunc.impl;

import callfunc.impl.ExternDef.ExternBytesData;
import haxe.Int64;
import haxe.io.ArrayBufferView;
import haxe.io.Bytes;
import haxe.io.BytesData;

using Safety;

class MemoryImpl implements Memory {
    final sizeOfTable:Map<DataType,Int>;
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
        return sizeOfTable.get(type).sure();
    }

    function getSizeOfTable():Map<DataType,Int> {
        var buffer = Bytes.alloc(27);

        ExternDef.getSizeOfTable(bytesToBytesData(buffer));

        return DataValueSerializer.deserializeSizeOfTable(buffer);
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
