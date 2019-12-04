package callfunc.core.impl;

import callfunc.core.impl.ExternDef;
import callfunc.core.serialization.DataValueSerializer;
import haxe.io.Bytes;
import haxe.Int64;

using callfunc.core.DataTypeTools;

class PointerImpl implements BasicPointer {
    public var address(get, never):Int64;

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
        serializer = new DataValueSerializer(context);
    }

    function get_address():Int64 {
        return _address;
    }

    public function get(dataType:DataType, offset:Int = 0):Any {
        ExternDef.pointerGet(nativePointer,
            context.toCoreDataType(dataType).toInt(),
            ContextImpl.bytesToBytesData(buffer), offset);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function set(value:Any, dataType:DataType, offset:Int = 0) {
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerSet(nativePointer,
            context.toCoreDataType(dataType).toInt(),
            ContextImpl.bytesToBytesData(buffer), offset);
    }

    public function arrayGet(index:Int, dataType:DataType):Any {
        ExternDef.pointerArrayGet(nativePointer,
            context.toCoreDataType(dataType).toInt(),
            ContextImpl.bytesToBytesData(buffer), index);

        return serializer.deserializeValue(buffer, 0, dataType);
    }

    public function arraySet(index:Int, value:Any, dataType:DataType) {
        serializer.serializeValue(buffer, 0, dataType, value);

        ExternDef.pointerArraySet(nativePointer,
            context.toCoreDataType(dataType).toInt(),
            ContextImpl.bytesToBytesData(buffer), index);
    }
}
