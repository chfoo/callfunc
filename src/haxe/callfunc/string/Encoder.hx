package callfunc.string;

import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import unifill.Utf16;

class Encoder {
    public static function stringLength(pointer:Pointer, encoding:Encoding):Int {
        switch encoding {
            case UTF8:
                return stringLengthUnicode(pointer, DataType.UInt8);
            case UTF16LE:
                return stringLengthUnicode(pointer, DataType.UInt16);
        }
    }

    static function stringLengthUnicode(pointer:Pointer, dataType:DataType):Int {
        var length = 0;

        while (true) {
            if (pointer.arrayGet(dataType, length) == 0) {
                break;
            }

            length += 1;
            if (length < 0) {
                throw "string length overflow";
            }
        }

        return length;
    }

    public static function decode(dataView:DataView, encoding:Encoding):String {
        switch encoding {
            case UTF8:
                return dataView.getString(0, dataView.byteLength, haxe.io.Encoding.UTF8);
            case UTF16LE:
                return decodeUTF16LE(dataView);
        }
    }

    static function decodeUTF16LE(dataView:DataView):String {
        var codeUnits = [];

        for (index in 0...Std.int(dataView.byteLength / 2)) {
            codeUnits.push(dataView.getUInt16(index));
        }

        return Utf16.fromArray(codeUnits).toString();
    }

    public static function encode(text:String, encoding:Encoding):Bytes {
        switch encoding {
            case UTF8:
                return Bytes.ofString(text, haxe.io.Encoding.UTF8);
            case UTF16LE:
                return encodeUTF16LE(text);
        }
    }

    static function encodeUTF16LE(text:String):Bytes {
        var buffer = new BytesBuffer();

        var uString = Utf16.fromString(text);

        function encodeCallback(codeUnit:Int) {
            buffer.addByte(codeUnit & 0xff);
            buffer.addByte((codeUnit >> 8) & 0xff);
        }

        for (codePoint in uString.toArray()) {
            Utf16.encodeWith(encodeCallback, codePoint);
        }

        return buffer.getBytes();
    }
}
