package callfunc.impl;

import haxe.io.Bytes;

typedef StructTypeInfo = {
    size:Int,
    offsets:Array<Int>
};

class StructTypeSerializer extends DataValueSerializer {
    final NUM_PARAM_VALUE_SIZE = 4;

    public function serializeFields(fields:Array<DataType>, ?buffer:Bytes):Bytes {
        var bufferSize = NUM_PARAM_VALUE_SIZE + fields.length;

        if (buffer == null) {
            buffer = Bytes.alloc(bufferSize);
        }

        if (buffer.length < bufferSize) {
            throw "Buffer too small";
        }

        buffer.setInt32(0, fields.length);

        for (fieldIndex in 0...fields.length) {
            if (fields[fieldIndex] == DataType.Void) {
                throw "Invalid type Void";
            }

            serializeDataType(buffer, NUM_PARAM_VALUE_SIZE + fieldIndex, fields[fieldIndex]);
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
