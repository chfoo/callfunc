package callfunc.impl;

import haxe.Int64;
import haxe.io.Bytes;

using callfunc.MemoryTools;

class ArgSerializer extends DataValueSerializer {
    static final BUFFER_VALUE_SIZE = 4;
    static final NUM_PARAM_VALUE_SIZE = 4;
    static final RETURN_VALUE_SIZE = 8;

    public function serializeParams(params:Array<DataType>,
            fixedParamCount:Int = -1, ?returnType:DataType,
            ?buffer:Bytes):Bytes {
        var bufferSize = getParamBufferSize(params, returnType);

        if (buffer == null) {
            buffer = Bytes.alloc(bufferSize);
        }

        if (buffer.length < bufferSize) {
            throw "Buffer too small";
        }

        if (fixedParamCount == 0) {
            throw "fixedParamCount can't be 0";
        }

        var bufferIndex = 0;

        buffer.setInt32(bufferIndex, bufferSize);
        bufferIndex += BUFFER_VALUE_SIZE;

        buffer.setInt32(bufferIndex, params.length);
        bufferIndex += NUM_PARAM_VALUE_SIZE;

        buffer.setInt32(bufferIndex, fixedParamCount);
        bufferIndex += NUM_PARAM_VALUE_SIZE;

        if (returnType == null) {
            returnType = DataType.Void;
        }

        bufferIndex += serializeDataType(buffer, bufferIndex, returnType);

        for (param in params) {
            if (param == DataType.Void) {
                throw "Void can only be used to indicate no return type";
            }

            bufferIndex += serializeDataType(buffer, bufferIndex, param);
        }

        return buffer;
    }

    function getParamBufferSize(params:Array<DataType>, returnType:Null<DataType>):Int {
        var bufferSize = BUFFER_VALUE_SIZE + NUM_PARAM_VALUE_SIZE * 2;

        if (returnType == null) {
            returnType = DataType.Void;
        }

        bufferSize += getSerializedDataTypeSize(returnType);

        for (dataType in params) {
            bufferSize += getSerializedDataTypeSize(dataType);
        }

        return bufferSize;
    }

    public function getArgBufferLength(params:Array<DataType>):Int {
        var bufferSize = BUFFER_VALUE_SIZE + RETURN_VALUE_SIZE;

        for (dataType in params) {
            bufferSize += getSerializedValueSize(dataType);
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

        buffer.setInt32(bufferIndex, bufferSize);
        bufferIndex += BUFFER_VALUE_SIZE;

        // To be filled in after ffi call:
        bufferIndex += RETURN_VALUE_SIZE;

        for (argIndex in 0...args.length) {
            var dataType = params[argIndex];
            var arg = args[argIndex];

            bufferIndex += serializeValue(buffer, bufferIndex, dataType, arg);
        }

        return buffer;
    }

    public function deserializeArgs(params:Array<DataType>, buffer:Bytes):Array<Any> {
        var bufferIndex = 0;

        var expected_buffer_length = buffer.getInt32(bufferIndex);
        bufferIndex += BUFFER_VALUE_SIZE;

        Debug.assert(expected_buffer_length <= buffer.length);

        bufferIndex += RETURN_VALUE_SIZE;

        var args = [];

        for (argIndex in 0...params.length) {
            var dataType = params[argIndex];
            var dataSize = memory.sizeOf(dataType);

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
