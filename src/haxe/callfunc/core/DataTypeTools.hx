package callfunc.core;

class DataTypeTools {
    /**
     * Converts data type to a appropriate core data type.
     *
     * @param dataType
     * @param fixedWidth Whether integer data types are substituted to their
     *     fixed-width data types. If the data type is not an integer, it is left unchanged.
     * @throws String If the data type is not a supported core data type.
     */
    public static function toCoreDataType(context:Context, dataType:DataType,
            fixedWidth:Bool = false):CoreDataType {
        if (fixedWidth) {
            dataType = toFixedWidth(context, dataType);
        }

        try {
            return CoreDataType.fromDataType(dataType);
        } catch (exception:String) {
            // continue
        }

        dataType = toFixedWidth(context, dataType);

        return CoreDataType.fromDataType(dataType);
    }

    static function toFixedWidth(context:Context, dataType:DataType):DataType {
        var size:Int;
        var signed:Bool;

        switch dataType {
            case UChar | UShort | UInt | ULong | Size | WChar:
                size = context.sizeOf(dataType);
                signed = false;
            case SChar | SShort | SInt | SLong | PtrDiff:
                size = context.sizeOf(dataType);
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
