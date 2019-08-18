package callfunc.impl;

import haxe.io.Bytes;
import haxe.Int64;

using callfunc.BytesTools;
using callfunc.MemoryTools;

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
            DataType.Pointer => buffer.get(18),

            DataType.LongDouble => buffer.get(19),
            DataType.ComplexFloat => buffer.get(20),
            DataType.ComplexDouble => buffer.get(21),
            DataType.ComplexLongDouble => buffer.get(22),
            DataType.Size => buffer.get(23),
            DataType.PtrDiff => buffer.get(24),
            DataType.WChar => buffer.get(25)
        ];
    }

    public function serializeDataType(buffer:Bytes, bufferIndex:Int, dataType:DataType) {
        buffer.set(bufferIndex, memory.toCoreDataType(dataType).toInt());
    }

    public function serializeValue(buffer:Bytes, bufferIndex:Int, dataType:DataType, value:Any):Int {
        var valueSize = memory.sizeOf(dataType);

        switch memory.toCoreDataType(dataType, true) {
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
            case Pointer:
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

    public function deserializeValue(buffer:Bytes, bufferIndex:Int, dataType:DataType):Any {
        switch memory.toCoreDataType(dataType, true) {
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
            case Pointer:
                return deserializePointer(buffer, bufferIndex);
            case Void:
                throw "Void type";
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
