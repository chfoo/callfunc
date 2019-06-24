package callfunc;

class MemoryTools {
    /**
     * Converts data type to a appropriate core data type.
     *
     * @param dataType
     * @param fixedWidth Whether integer data types are substituted to their
     *     fixed-width data types. If the data type is not an integer, it is left unchanged.
     * @throws String If the data type is not a supported core data type.
     */
    public static function toCoreDataType(memory:Memory, dataType:DataType,
            fixedWidth:Bool = false):CoreDataType {
        if (fixedWidth) {
            dataType = toFixedWidth(memory, dataType);
        }

        var coreDataType = CoreDataType.fromDataType(dataType);

        if (coreDataType != null) {
            return coreDataType;
        }

        dataType = toFixedWidth(memory, dataType);
        coreDataType = CoreDataType.fromDataType(dataType);

        if (coreDataType != null) {
            return coreDataType;
        }

        throw 'Unsupported type $dataType';
    }

    static function toFixedWidth(memory:Memory, dataType:DataType):DataType {
        var size:Int;
        var signed:Bool;

        switch dataType {
            case UChar | UShort | UInt | ULong | Size | WChar:
                size = memory.sizeOf(dataType);
                signed = false;
            case SChar | SShort | SInt | SLong | PtrDiff:
                size = memory.sizeOf(dataType);
                signed = true;
            default:
                return dataType;
        }

        switch size {
            case 1: return signed ? SInt8 : UInt8;
            case 2: return signed ? SInt16 : UInt16;
            case 4: return signed ? SInt32 : UInt32;
            case 8: return signed ? SInt64 : UInt64;
            default: throw 'Unsupported size $size for type $dataType';
        }
    }
}
