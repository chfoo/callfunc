package callfunc.impl;

import haxe.io.Bytes;
import callfunc.impl.ExternDef;
import haxe.Int64;

class PointerImpl implements Pointer {
    public var address(get, never):Int64;

    final _address:Int64;
    public final nativePointer:ExternVoidStar;
    final buffer:Bytes;
    final serializer:DataValueSerializer;

    public function new(
            #if cpp
            haxePointer:cpp.Pointer<cpp.Void>
            #else
            nativePointer:ExternVoidStar
            #end,
            memory:Memory) {

        #if cpp
        nativePointer = haxePointer.raw;
        #else
        this.nativePointer = nativePointer;
        #end

        _address = ExternDef.pointerToInt64(nativePointer);
        buffer = Bytes.alloc(8);
        serializer = new DataValueSerializer(memory);
    }

    function get_address():Int64 {
        return _address;
    }

    public function isNull():Bool {
        return address == 0;
    }

    public function get(dataType:DataType, offset:Int = 0):Any {
        ExternDef.pointerGet(nativePointer, dataType.toInt(),
            MemoryImpl.bytesToBytesData(buffer), offset);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function set(value:Any, dataType:DataType, offset:Int = 0) {
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerSet(nativePointer, dataType.toInt(),
            MemoryImpl.bytesToBytesData(buffer), offset);
    }

    public function arrayGet(dataType:DataType, index:Int):Any {
        ExternDef.pointerArrayGet(nativePointer, dataType.toInt(),
            MemoryImpl.bytesToBytesData(buffer), index);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function arraySet(value:Any, dataType:DataType, index:Int) {
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerArraySet(nativePointer, dataType.toInt(),
            MemoryImpl.bytesToBytesData(buffer), index);
    }
}
