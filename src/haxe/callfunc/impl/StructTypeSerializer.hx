package callfunc.impl;

import haxe.io.Bytes;

typedef StructTypeInfo = {
    size:Int,
    offsets:Array<Int>
};

class StructTypeSerializer extends DataValueSerializer {
    static final BUFFER_VALUE_SIZE = 4;
    static final NUM_PARAM_VALUE_SIZE = 4;

    public function serializeFields(fields:Array<DataType>, ?buffer:Bytes):Bytes {
        var bufferSize = BUFFER_VALUE_SIZE + NUM_PARAM_VALUE_SIZE;
        var offset = 0;

        for (field in fields) {
            bufferSize += getSerializedDataTypeSize(field);
        }

        if (buffer == null) {
            buffer = Bytes.alloc(bufferSize);
        }

        if (buffer.length < bufferSize) {
            throw "Buffer too small";
        }

        buffer.setInt32(offset, bufferSize);
        offset += BUFFER_VALUE_SIZE;

        buffer.setInt32(offset, fields.length);
        offset += NUM_PARAM_VALUE_SIZE;

        for (field in fields) {
            if (field == DataType.Void) {
                throw "Invalid type Void";
            }

            offset += serializeDataType(buffer, offset, field);
        }

        return buffer;
    }

    public function deserializeInfo(fields:Array<DataType>, buffer:Bytes):StructTypeInfo {
        var size = buffer.getInt32(0);
        var offsets = [];

        for (fieldIndex in 0...fields.length) {
            offsets.push(buffer.getInt32(4 + 4 * fieldIndex));
        }

        return {
            size: size,
            offsets: offsets
        }
    }
}
