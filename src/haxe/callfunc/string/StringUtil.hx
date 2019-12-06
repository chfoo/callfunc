package callfunc.string;

import haxe.io.Bytes;
import unifill.Utf16;
import unifill.Utf8;

class StringUtil {
    public static function getEncodedLength(text:String, encoding:Encoding,
            terminator:Bool):Int {
        final uString = new UnicodeString(text);
        var position = 0;

        function utf8CodeUnitCallback(codeUnit:Int) {
            position += 1;
        }

        function utf16CodeUnitCallback(codeUnit:Int) {
            position += 2;
        }

        var encodeCodePoint:Int->Void;

        switch encoding {
            case UTF8:
                encodeCodePoint = (codePoint:Int) -> {
                    Utf8.encodeWith(utf8CodeUnitCallback, codePoint);
                }
            case UTF16LE:
                encodeCodePoint = (codePoint:Int) -> {
                    Utf16.encodeWith(utf16CodeUnitCallback, codePoint);
                }
        }

        for (codePoint in uString) {
            encodeCodePoint(codePoint);
        }

        if (terminator) {
            switch encoding {
                case UTF8:
                    position += 1;
                case UTF16LE:
                    position += 2;
            }
        }

        return position;
    }

    public static function getPointerNullTerminator(pointer:Pointer, encoding:Encoding):Int {
        switch encoding {
            case UTF8:
                return findPointerNullTerminatorByCodeUnit(pointer, DataType.UInt8);
            case UTF16LE:
                return findPointerNullTerminatorByCodeUnit(pointer, DataType.UInt16) * 2;
        }
    }

    static function findPointerNullTerminatorByCodeUnit(pointer:Pointer, dataType:DataType):Int {
        var length = 0;

        while (true) {
            if (pointer.arrayGet(length, dataType) == 0) {
                break;
            }

            length += 1;
            if (length < 0) {
                throw "string length overflow";
            }
        }

        return length;
    }

    public static function getNullTerminator(bytes:Bytes, offset:Int, encoding:Encoding):Int {
        switch encoding {
            case UTF8:
                return findNullTerminatorByCodeUnit(bytes, offset, 1);
            case UTF16LE:
                return findNullTerminatorByCodeUnit(bytes, offset, 2) * 2;
        }
    }

    static function findNullTerminatorByCodeUnit(bytes:Bytes, offset:Int, codeUnitWidth:Int):Int {
        var position = offset;

        while (true) {
            switch codeUnitWidth {
                case 1:
                    if (bytes.get(position) == 0) break;
                case 2:
                    if (bytes.getUInt16(position) == 0) break;
                default:
                    throw "Code unit width not implemented";
            }

            position += 1;
            if (position < 0) {
                throw "string length overflow";
            }
        }

        return position;
    }
}
