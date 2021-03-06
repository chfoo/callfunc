package callfunc;

import haxe.ds.Option;

/**
 * Represents primitive C data types supported by libffi.
 *
 * Note that `Struct` is not true primitive data type; it is an indicator
 * for composite data types in the serialization process.
 *
 * @see `DataType`
 */
@:enum
abstract CoreDataType(Int) {
    var Void = 0;
    var UInt8 = 1;
    var SInt8 = 2;
    var UInt16 = 3;
    var SInt16 = 4;
    var UInt32 = 5;
    var SInt32 = 6;
    var UInt64 = 7;
    var SInt64 = 8;
    var Float = 9;
    var Double = 10;
    var UChar = 11;
    var SChar = 12;
    var UShort = 13;
    var SShort = 14;
    var SInt = 15;
    var UInt = 16;
    var SLong = 17;
    var ULong = 18;
    var Pointer = 19;
    var Struct = 20;

    inline public function toInt():Int {
        return this;
    }

    public static function fromDataType(dataType:DataType):CoreDataType {
        switch dataType {
            case DataType.UChar: return UChar;
            case DataType.UShort: return UShort;
            case DataType.UInt: return UInt;
            case DataType.ULong: return ULong;
            case DataType.SChar: return SChar;
            case DataType.SShort: return SShort;
            case DataType.SInt: return SInt;
            case DataType.SLong: return SLong;
            case DataType.UInt8: return UInt8;
            case DataType.SInt8: return SInt8;
            case DataType.UInt16: return UInt16;
            case DataType.SInt16: return SInt16;
            case DataType.UInt32: return UInt32;
            case DataType.SInt32: return SInt32;
            case DataType.UInt64: return UInt64;
            case DataType.SInt64: return SInt64;
            case DataType.Float: return Float;
            case DataType.Double: return Double;
            case DataType.Pointer: return Pointer;
            case DataType.Void: return Void;
            case DataType.Struct(_): return Struct;
            default: throw 'Invalid type $dataType';
        }
    }

    public static function getName(value:CoreDataType):String {
        switch value {
            case Void: return "Void";
            case UInt8: return "UInt8";
            case SInt8: return "SInt8";
            case UInt16: return "UInt16";
            case SInt16: return "SInt16";
            case UInt32: return "UInt32";
            case SInt32: return "SInt32";
            case UInt64: return "UInt64";
            case SInt64: return "SInt64";
            case Float: return "Float";
            case Double: return "Double";
            case UChar: return "UChar";
            case SChar: return "SChar";
            case UShort: return "UShort";
            case SShort: return "SShort";
            case SInt: return "SInt";
            case UInt: return "UInt";
            case SLong: return "SLong";
            case ULong: return "ULong";
            case Pointer: return "Pointer";
            case Struct: return "Struct";
        }
    }
}
