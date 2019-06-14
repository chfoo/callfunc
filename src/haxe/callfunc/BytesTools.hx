package callfunc;

import haxe.io.Bytes;

/**
 * Static method extensions to `haxe.io.Bytes`.
 */
class BytesTools {
    /**
     * Interpret and return a signed, little-endian 8-bit integer
     */
    public static function getSInt8(bytes:Bytes, position:Int):Int {
        var value = bytes.get(position);

        if (value & 0x40 == 0) {
            return value;
        } else {
            return -((~value & 0xff) + 1);
        }
    }

    /**
     * Interpret and return a signed, little-endian 16-bit integer.
     */
    public static function getSInt16(bytes:Bytes, position:Int):Int {
        var value = bytes.get(position) | (bytes.get(position + 1) << 8);

        if (value & 0x4000 == 0) {
            return value;
        } else {
            return -((~value & 0xffff) + 1);
        }
    }
}
