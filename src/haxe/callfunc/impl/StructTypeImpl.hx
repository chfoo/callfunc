package callfunc.impl;

import haxe.io.Bytes;
import callfunc.impl.ExternDef;

class StructTypeImpl implements StructType {
    public var size(get, never):Int;
    public var dataTypes(get, never):Array<DataType>;
    public var offsets(get, never):Array<Int>;

    final nativePointer:ExternStructType;
    final _dataTypes:Array<DataType>;
    final _size:Int;
    final _offsets:Array<Int>;
    final serializer:StructTypeSerializer;

    public function new(dataTypes:Array<DataType>, memory:Memory) {
        _dataTypes = dataTypes;
        serializer = new StructTypeSerializer(memory);

        nativePointer = ExternDef.newStructType();

        if (nativePointer == null) {
            throw "Failed to allocate struct type";
        }

        var definitionBuffer = serializer.serializeFields(dataTypes);
        var infoBuffer = Bytes.alloc(4 * (1 + dataTypes.length));

        var error = ExternDef.structTypeDefine(nativePointer,
            MemoryImpl.bytesToBytesData(definitionBuffer),
            MemoryImpl.bytesToBytesData(infoBuffer)
        );

        if (error != 0) {
            throw ExternDef.getErrorMessage();
        }

        var info = serializer.deserializeInfo(dataTypes, infoBuffer);
        _size = info.size;
        _offsets = info.offsets;
    }

    function get_size():Int {
        return _size;
    }

    function get_dataTypes():Array<DataType> {
        return _dataTypes;
    }

    function get_offsets():Array<Int> {
        return _offsets;
    }

    public function dispose() {
        ExternDef.delStructType(nativePointer);
    }
}
