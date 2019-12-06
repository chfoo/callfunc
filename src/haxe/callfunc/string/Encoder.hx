package callfunc.string;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import unifill.Utf8;
import unifill.Utf16;

class Encoder {

    public static function decodeFromBytes(bytes:Bytes, offset:Int,
            ?length:Int, encoding:Encoding = UTF8):String {
        if (length == null) {
            length = StringUtil.getNullTerminator(bytes, offset, encoding);
        }

        switch encoding {
            case UTF8:
                return bytes.getString(offset, length, haxe.io.Encoding.UTF8);
            default: // pass
        }

        final codeUnits = [];
        var position = offset;

        var codeUnitWidth;

        switch encoding {
            case UTF8:
                codeUnitWidth = 1;
            case UTF16LE:
                codeUnitWidth = 2;
        }

        while (position < offset + length) {
            var codeUnit;

            switch encoding {
                case UTF8:
                    codeUnit = bytes.get(position);
                case UTF16LE:
                    codeUnit = bytes.getUInt16(position);
            }

            codeUnits.push(codeUnit);
            position += codeUnitWidth;
        }

        switch encoding {
            case UTF8:
                throw "not implemented";
            case UTF16LE:
                return Utf16.fromArray(codeUnits).toString();
        }
    }

    public static function encodeToBytes(bytes:Bytes, offset:Int, text:String,
            encoding:Encoding = UTF8, terminator:Bool = false):Int {
        var position = offset;

        final uString = new UnicodeString(text);

        function utf8CodeUnitCallback(codeUnit:Int) {
            bytes.set(position, codeUnit);
            position += 1;
        }

        function utf16CodeUnitCallback(codeUnit:Int) {
            bytes.setUInt16(position, codeUnit);
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
                    bytes.set(position, 0);
                    position += 1;
                case UTF16LE:
                    bytes.setUInt16(position, 0);
                    position += 2;
            }
        }

        return position;
    }
}
