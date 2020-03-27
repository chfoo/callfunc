package callfunc.core.serialization;

import haxe.io.Bytes;
import haxe.Int64;

using callfunc.BytesTools;
using callfunc.core.DataTypeTools;

class DataValueSerializer {
    final context:Context;
    final coreDataTypeTable:CoreDataTypeTable;

    public function new(context:Context) {
        this.context = context;
        this.coreDataTypeTable = new CoreDataTypeTable(context);
    }

    public function serializeDataType(buffer:Bytes, bufferIndex:Int, dataType:DataType):Int {
        buffer.set(bufferIndex, coreDataTypeTable.toCoreDataType(dataType).toInt());

        switch dataType {
            case Struct(fields):
                var size = 1;

                buffer.setInt32(bufferIndex + size, fields.length);
                size += 4;

                for (field in fields) {
                    size += serializeDataType(buffer, bufferIndex + size, field);
                }

                return size;
            default:
                return 1;
        }
    }

    public function getSerializedDataTypeSize(dataType:DataType):Int {
        switch dataType {
            case Struct(fields):
                var size = 1 + 4;

                for (field in fields) {
                    size += getSerializedDataTypeSize(field);
                }

                return size;
            default:
                return 1;
        }
    }

    public function getSerializedValueSize(dataType:DataType):Int {
        if (dataType.match(DataType.Struct(_))) {
            dataType = DataType.Pointer;
        }

        return context.sizeOf(dataType);
    }

    public function serializeValue(buffer:Bytes, bufferIndex:Int, dataType:DataType, value:Any):Int {
        switch coreDataTypeTable.toCoreDataType(dataType, true) {
            case SInt8 | UInt8:
                buffer.set(bufferIndex, NumberUtil.toInt(value));
            case SInt16 | UInt16:
                buffer.setUInt16(bufferIndex, NumberUtil.toInt(value));
            case SInt32 | UInt32:
                buffer.setInt32(bufferIndex, NumberUtil.toInt(value));
            case SInt64 | UInt64:
                buffer.setInt64(bufferIndex, NumberUtil.toInt64(value));
            case Float:
                buffer.setFloat(bufferIndex, value);
            case Double:
                buffer.setDouble(bufferIndex, value);
            case Pointer | Struct:
                serializePointer(buffer, bufferIndex, value);
                dataType = DataType.Pointer;
            default:
                throw "Shouldn't reach here";
        }

        var valueSize = context.sizeOf(dataType);
        return valueSize;
    }

    function serializePointer(buffer:Bytes, bufferIndex:Int, pointer:BasicPointer) {
        var valueSize = context.sizeOf(DataType.Pointer);

        switch valueSize {
            case 8:
                buffer.setInt64(bufferIndex, pointer.address);
            case 4:
                buffer.setInt32(bufferIndex, pointer.address.low);
            default:
                throw 'Unsupported pointer width $valueSize';
        }
    }

    public function deserializeValue(buffer:Bytes, bufferIndex:Int, dataType:DataType):Any {
        switch coreDataTypeTable.toCoreDataType(dataType, true) {
            case UInt8:
                return buffer.get(bufferIndex);
            case SInt8:
                return buffer.getSInt8(bufferIndex);
            case UInt16:
                return buffer.getUInt16(bufferIndex);
            case SInt16:
                return buffer.getSInt16(bufferIndex);
            case SInt32:
                return buffer.getInt32(bufferIndex);
            case UInt32:
                return (buffer.getInt32(bufferIndex):UInt);
            case SInt64 | UInt64:
                return buffer.getInt64(bufferIndex);
            case Double:
                return buffer.getDouble(bufferIndex);
            case Float:
                return buffer.getFloat(bufferIndex);
            case Pointer | Struct:
                return deserializePointer(buffer, bufferIndex);
            case Void:
                throw "Void type";
            default:
                throw "Shouldn't reach here";
        }
    }

    function deserializePointer(buffer:Bytes, bufferIndex:Int):BasicPointer {
        var valueSize = context.sizeOf(DataType.Pointer);

        switch valueSize {
            case 8:
                return context.getPointer(buffer.getInt64(bufferIndex));
            case 4:
                return context.getPointer(
                    Int64.make(0, buffer.getInt32(bufferIndex)));
            default:
                throw 'Unsupported pointer width $valueSize';
        }
    }
}
