package callfunc.impl;

import callfunc.impl.ExternDef;
import haxe.io.Bytes;
import haxe.Int64;

using callfunc.MemoryTools;

class PointerImpl implements Pointer {
    public var address(get, never):Int64;
    public var memory(get, never):Memory;

    final _address:Int64;
    public final nativePointer:ExternVoidStar;
    final buffer:Bytes;
    final context:ContextImpl;
    final serializer:DataValueSerializer;

    public function new(
            #if cpp
            haxePointer:cpp.Pointer<cpp.Void>
            #else
            nativePointer:ExternVoidStar
            #end,
            context:ContextImpl) {

        #if cpp
        nativePointer = haxePointer.raw;
        #else
        this.nativePointer = nativePointer;
        #end

        _address = ExternDef.pointerToInt64(nativePointer);
        buffer = Bytes.alloc(8);
        this.context = context;
        serializer = new DataValueSerializer(context.memory);
    }

    function get_address():Int64 {
        return _address;
    }

    function get_memory():Memory {
        return context.memory;
    }

    public function isNull():Bool {
        return address == 0;
    }

    public function get(dataType:DataType, offset:Int = 0):Any {
        ExternDef.pointerGet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), offset);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function set(value:Any, dataType:DataType, offset:Int = 0) {
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerSet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), offset);
    }

    public function arrayGet(dataType:DataType, index:Int):Any {
        ExternDef.pointerArrayGet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), index);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function arraySet(value:Any, dataType:DataType, index:Int) {
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerArraySet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), index);
    }
}
