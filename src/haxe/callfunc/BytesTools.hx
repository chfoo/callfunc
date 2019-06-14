package callfunc;

import haxe.io.Bytes;

class BytesTools {
    public static function getSInt8(bytes:Bytes, position:Int):Int {
        var value = bytes.get(position);

        if (value & 0x40 == 0) {
            return value;
        } else {
            return -((~value & 0xff) + 1);
        }
    }

    public static function getSInt16(bytes:Bytes, position:Int):Int {
        var value = bytes.get(position) | (bytes.get(position + 1) << 8);

        if (value & 0x4000 == 0) {
            return value;
        } else {
            return -((~value & 0xffff) + 1);
        }
    }
}
