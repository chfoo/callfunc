package callfunc.impl;

import haxe.io.Bytes;
import haxe.Int64;

using callfunc.BytesTools;

class DataValueSerializer {
    final memory:Memory;

    public function new(memory:Memory) {
        this.memory = memory;
    }

    public static function deserializeSizeOfTable(buffer:Bytes):Map<DataType,Int> {
        return [
            DataType.UInt8 => buffer.get(0),
            DataType.SInt8 => buffer.get(1),
            DataType.UInt16 => buffer.get(2),
            DataType.SInt16 => buffer.get(3),
            DataType.UInt32 => buffer.get(4),
            DataType.SInt32 => buffer.get(5),
            DataType.UInt64 => buffer.get(6),
            DataType.SInt64 => buffer.get(7),
            DataType.Float => buffer.get(8),
            DataType.Double => buffer.get(9),
            DataType.UChar => buffer.get(10),
            DataType.SChar => buffer.get(11),
            DataType.UShort => buffer.get(12),
            DataType.SShort => buffer.get(13),
            DataType.SInt => buffer.get(14),
            DataType.UInt => buffer.get(15),
            DataType.SLong => buffer.get(16),
            DataType.ULong => buffer.get(17),
            DataType.Pointer => buffer.get(18)
        ];
    }

    public function serializeDataType(buffer:Bytes, bufferIndex:Int, dataType:DataType) {
        buffer.set(bufferIndex, dataType.toInt());
    }

    public function serializeValue(buffer:Bytes, bufferIndex:Int, dataType:DataType, value:Any):Int {
        var valueSize = memory.sizeOf(dataType);

        switch DataTypeAlias.normalize(memory, dataType) {
            case DataType.SInt8 | DataType.UInt8:
                buffer.set(bufferIndex, toInt(value));
            case DataType.SInt16 | DataType.UInt16:
                buffer.setUInt16(bufferIndex, toInt(value));
            case DataType.SInt32 | DataType.UInt32:
                buffer.setInt32(bufferIndex, toInt(value));
            case DataType.SInt64 | DataType.UInt64:
                buffer.setInt64(bufferIndex, toInt64(value));
            case DataType.Float:
                buffer.setFloat(bufferIndex, value);
            case DataType.Double:
                buffer.setDouble(bufferIndex, value);
            case DataType.Pointer:
                serializePointer(buffer, bufferIndex, value);
            default:
                throw "Shouldn't reach here";
        }

        return valueSize;
    }

    function serializePointer(buffer:Bytes, bufferIndex:Int, pointer:Pointer) {
        var valueSize = memory.sizeOf(DataType.Pointer);

        switch valueSize {
            case 8:
                buffer.setInt64(bufferIndex, pointer.address);
            case 4:
                buffer.setInt32(bufferIndex, pointer.address.low);
            default:
                throw 'Unsupported pointer width $valueSize';
        }
    }

    function toInt(value:Any):Int {
        if (Std.is(value, Int)) {
            return value;
        } else if (Int64.is(value)) {
            return (value:Int64).low;
        } else if (Std.is(value, Float)) {
            return Std.int(value);
        } else {
            throw "Cannot convert value to Int";
        }
    }

    function toInt64(value:Any):Int64 {
        if (Int64.is(value)) {
            return value;
        } else if (Std.is(value, Int)) {
            return Int64.make(0, value);
        } else if (Std.is(value, Float)) {
            return Int64.fromFloat(value);
        } else {
            throw "Cannot convert value to Int64";
        }
    }

    public function deserializeValue(buffer:Bytes, bufferIndex:Int, dataType:DataType):Any {
        switch DataTypeAlias.normalize(memory, dataType) {
            case DataType.UInt8:
                return buffer.get(bufferIndex);
            case DataType.SInt8:
                return buffer.getSInt8(bufferIndex);
            case DataType.UInt16:
                return buffer.getUInt16(bufferIndex);
            case DataType.SInt16:
                return buffer.getSInt16(bufferIndex);
            case DataType.SInt32:
                return buffer.getInt32(bufferIndex);
            case DataType.UInt32:
                return (buffer.getInt32(bufferIndex):UInt);
            case DataType.SInt64 | DataType.UInt64:
                return buffer.getInt64(bufferIndex);
            case DataType.Double:
                return buffer.getDouble(bufferIndex);
            case DataType.Float:
                return buffer.getFloat(bufferIndex);
            case DataType.Pointer:
                return deserializePointer(buffer, bufferIndex);
            case DataType.Void:
                return "Void type";
            default:
                throw "Shouldn't reach here";
        }
    }

    function deserializePointer(buffer:Bytes, bufferIndex:Int):Pointer {
        var valueSize = memory.sizeOf(DataType.Pointer);

        switch valueSize {
            case 8:
                return memory.getPointer(buffer.getInt64(bufferIndex));
            case 4:
                return memory.getPointer(
                    Int64.make(0, buffer.getInt32(bufferIndex)));
            default:
                throw 'Unsupported pointer width $valueSize';
        }
    }
}
