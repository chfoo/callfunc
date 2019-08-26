package callfunc.impl;

import callfunc.impl.ExternDef;
import haxe.io.Bytes;
import haxe.Int64;
import Safety;

using callfunc.MemoryTools;

class PointerImpl implements Pointer {
    public var address(get, never):Int64;
    public var memory(get, never):Memory;
    public var dataType(get, set):DataType;

    final _address:Int64;
    public final nativePointer:ExternVoidStar;
    final buffer:Bytes;
    final context:ContextImpl;
    final serializer:DataValueSerializer;

    var _dataType:DataType;

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
        _dataType = DataType.SInt;
        serializer = new DataValueSerializer(context.memory);
    }

    function get_address():Int64 {
        return _address;
    }

    function get_memory():Memory {
        return context.memory;
    }

    function get_dataType():DataType {
        return _dataType;
    }

    function set_dataType(value:DataType):DataType {
        return _dataType = value;
    }

    public function isNull():Bool {
        return address == 0;
    }

    public function get(?dataType:DataType, offset:Int = 0):Any {
        dataType = Safety.or(dataType, _dataType);

        ExternDef.pointerGet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), offset);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function set(value:Any, ?dataType:DataType, offset:Int = 0) {
        dataType = Safety.or(dataType, _dataType);
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerSet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), offset);
    }

    public function arrayGet(index:Int, ?dataType:DataType):Any {
        dataType = Safety.or(dataType, _dataType);

        ExternDef.pointerArrayGet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), index);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function arraySet(index:Int, value:Any, ?dataType:DataType) {
        dataType = Safety.or(dataType, _dataType);
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerArraySet(nativePointer,
            context.memory.toCoreDataType(dataType).toInt(),
            MemoryImpl.bytesToBytesData(buffer), index);
    }
}
