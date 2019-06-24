package callfunc.impl;

import haxe.Int64;
import haxe.io.Bytes;

using callfunc.MemoryTools;

class ArgSerializer extends DataValueSerializer {
    static final NUM_PARAM_VALUE_SIZE = 4;
    static final RETURN_VALUE_SIZE = 8;

    public function serializeParams(params:Array<DataType>, ?returnType:DataType, ?buffer:Bytes):Bytes {
        var bufferSize = NUM_PARAM_VALUE_SIZE + 1 + params.length;

        if (buffer == null) {
            buffer = Bytes.alloc(bufferSize);
        }

        if (buffer.length < bufferSize) {
            throw "Buffer too small";
        }

        buffer.setInt32(0, params.length);
        buffer.set(
            NUM_PARAM_VALUE_SIZE,
            returnType != null ?
                memory.toCoreDataType(returnType).toInt() :
                CoreDataType.Void.toInt());

        for (paramIndex in 0...params.length) {
            if (params[paramIndex] == DataType.Void) {
                throw "Void can only be used to indicate no return type";
            }

            serializeDataType(buffer, NUM_PARAM_VALUE_SIZE + 1 + paramIndex, params[paramIndex]);
        }

        return buffer;
    }

    public function getArgBufferLength(params:Array<DataType>):Int {
        var bufferSize = NUM_PARAM_VALUE_SIZE + RETURN_VALUE_SIZE;

        for (dataType in params) {
            bufferSize += 1 + memory.sizeOf(dataType);
        }

        return bufferSize;
    }

    public function serializeArgs(params:Array<DataType>, args:Array<Any>, ?buffer:Bytes):Bytes {
        var bufferSize = getArgBufferLength(params);

        if (buffer == null) {
            buffer = Bytes.alloc(bufferSize);
        }

        if (buffer.length < bufferSize) {
            throw "Buffer too small";
        }

        var bufferIndex = 0;

        buffer.setInt32(bufferIndex, args.length);
        bufferIndex += NUM_PARAM_VALUE_SIZE;
        bufferIndex += RETURN_VALUE_SIZE;

        for (argIndex in 0...args.length) {
            var dataType = params[argIndex];
            var arg = args[argIndex];

            buffer.set(bufferIndex, memory.sizeOf(dataType));
            bufferIndex += 1;
            bufferIndex += serializeValue(buffer, bufferIndex, dataType, arg);
        }

        return buffer;
    }

    public function deserializeArgs(params:Array<DataType>, buffer:Bytes):Array<Any> {
        var bufferIndex = 0;
        var numArgs = buffer.getInt32(bufferIndex);

        Debug.assert(params.length == numArgs);
        bufferIndex += NUM_PARAM_VALUE_SIZE;
        bufferIndex += RETURN_VALUE_SIZE;

        var args = [];

        for (argIndex in 0...params.length) {
            var dataType = params[argIndex];
            var dataSize = memory.sizeOf(dataType);

            var bufferDataSize = buffer.get(bufferIndex);

            Debug.assert(bufferDataSize == dataSize);
            bufferIndex += 1;

            var arg = deserializeValue(buffer, bufferIndex, dataType);
            args.push(arg);

            bufferIndex += dataSize;
        }

        return args;
    }

    public function getReturnValue(buffer:Bytes, returnType:DataType):Any {
        return deserializeValue(buffer, 4, returnType);
    }

    public function setReturnValue(buffer:Bytes, returnType:DataType, value:Any) {
        serializeValue(buffer, 4, returnType, value);
    }
}
