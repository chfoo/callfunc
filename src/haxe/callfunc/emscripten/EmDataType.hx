package callfunc.emscripten;

class EmDataType {
    public static function toLLVMType(dataType:DataType):String {
        switch dataType {
            case Pointer:
                return "*";
            case UInt8 | SInt8 | UChar | SChar | WChar:
                return "i8";
            case UInt16 | SInt16 | UShort | SShort:
                return "i16";
            case UInt32 | SInt32 | SInt | UInt | Size | PtrDiff:
                return "i32";
            case UInt64 | SInt64 | SLong | ULong:
                return "i64";
            case Float:
                return "float";
            case Double:
                return "double";
            case Void:
                throw "Void is not a real type";
            case LongDouble | ComplexFloat | ComplexDouble | ComplexLongDouble | Struct(_):
                throw 'Not supported data type $dataType';
        }
    }

    public static function toLLVMReturnType(dataType:DataType):Null<String> {
        if (dataType == DataType.Void) {
            return null;
        } else {
            return toLLVMType(dataType);
        }
    }

    public static function getSize(dataType:DataType):Int {
        switch dataType {
            case Pointer:
                return 4;
            case UInt8 | SInt8 | UChar | SChar | WChar:
                return 1;
            case UInt16 | SInt16 | UShort | SShort:
                return 2;
            case UInt32 | SInt32 | SInt | UInt | Size | PtrDiff:
                return 4;
            case UInt64 | SInt64 | SLong | ULong:
                return 8;
            case Float:
                return 4;
            case Double:
                return 8;
            case Void:
                throw "Void is not a real type";
            case LongDouble | ComplexFloat | ComplexDouble | ComplexLongDouble | Struct(_):
                return 0;
        }
    }

    public static function toCCallType(dataType:DataType):String {
        return "number";
    }

    public static function toCCallReturnType(dataType:DataType):Null<String> {
        return dataType != DataType.Void ? toCCallType(dataType) : null;
    }

    public static function toWasmSignature(dataType:DataType):String {
        switch dataType {
            case Pointer:
                return "i";
            case UInt8 | SInt8 | UChar | SChar |
                    UInt16 | SInt16 | UShort | SShort |
                    UInt32 | SInt32 | SInt | UInt |
                    WChar | Size | PtrDiff:
                return "i";
            case UInt64 | SInt64 | SLong | ULong:
                return "j";
            case Float:
                return "f";
            case Double:
                return "d";
            case Void:
                return "v";
            case LongDouble | ComplexFloat | ComplexDouble | ComplexLongDouble | Struct(_):
                throw 'Not supported data type $dataType';
        }
    }
}
