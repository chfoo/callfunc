package callfunc.core.impl;

import haxe.io.Bytes;

import callfunc.core.impl.ExternDef.ExternString;

class NativeUtil {
    public static function toNativeString(text:String):ExternString {
        // Haxe to UTF-8 null-terminated C string
        #if hl
        final encoded = Bytes.ofString(text, haxe.io.Encoding.UTF8);
        final array = Bytes.alloc(encoded.length + 1);
        array.blit(0, encoded, 0, encoded.length);
        return array;
        #else
        return text;
        #end
    }

    public static function fromNativeString(native:ExternString):String {
        // UTF-8 null-terminated C string to Haxe
        #if hl
        var length = 0;

        while (true) {
            if (native[length] == 0) {
                break;
            } else {
                length += 1;
            }
        }

        return native.toBytes(length + 1).toString();

        #else
            return native.toString();
        #end
    }
}
