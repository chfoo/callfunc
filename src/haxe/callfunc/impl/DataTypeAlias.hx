package callfunc.impl;

class DataTypeAlias {
    public static function normalize(memory:Memory, dataType:DataType):DataType {
        var size:Int;
        var signed:Bool;

        switch dataType {
            case DataType.UChar | DataType.UShort |
                    DataType.UInt | DataType.ULong:
                size = memory.sizeOf(dataType);
                signed = false;
            case DataType.SChar | DataType.SShort |
                    DataType.SInt | DataType.SLong:
                size = memory.sizeOf(dataType);
                signed = true;
            default:
                return dataType;
        }

        switch size {
            case 1: return signed ? DataType.SInt8 : DataType.UInt8;
            case 2: return signed ? DataType.SInt16 : DataType.UInt16;
            case 4: return signed ? DataType.SInt32 : DataType.UInt32;
            case 8: return signed ? DataType.SInt64 : DataType.UInt64;
            default: throw 'Unsupported size $size for type alias';
        }
    }
}
