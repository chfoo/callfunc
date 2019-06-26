package callfunc;

import callfunc.string.Encoder;
import callfunc.string.Encoding;
import haxe.io.Bytes;

/**
 * Static extension for pointer methods.
 */
class PointerTools {
    /**
     * Free the pointer's allocated memory.
     *
     * @see `Memory.free`
     */
    public static function free(pointer:Pointer) {
        pointer.memory.free(pointer);
    }

    /**
     * Converts a Haxe string to a new C string and returns its pointer.
     *
     * The C string will be encoded with the given encoding with a null
     * terminator.
     *
     * The caller is responsible for freeing the string.
     */
    public static function allocString(memory:Memory, text:String,
            encoding:Encoding = UTF8, ?lengthCallback:Int->Void):Pointer {
        var bytes = Encoder.encode(text, encoding);
        // To simplify logic, assume 4 null bytes is enough
        var pointer = memory.alloc(bytes.length + 4);
        var view = memory.pointerToDataView(pointer, bytes.length + 4);

        view.blitBytes(0, bytes);
        view.setInt32(bytes.length, 0); // null terminator

        if (lengthCallback != null) {
            lengthCallback(bytes.length);
        }

        return pointer;
    }

    /**
     * Converts a C string from a pointer and returns a Haxe string.
     *
     * @param length Number in bytes (not code units and not code points) of the
     *     string. If not given, the length of the string is determined by
     *     searching for a null terminator.
     */
    public static function getString(pointer:Pointer, ?length:Int,
            encoding:Encoding = Encoding.UTF8):String {
        length = length != null ? length : Encoder.stringLength(pointer, encoding);
        var view = pointer.memory.pointerToDataView(pointer, length);

        return Encoder.decode(view, encoding);
    }

    #if sys
    /**
     * Return a Haxe Bytes representing a C array.
     *
     * @see `Memory.pointerToBytes`
     */
    public static function getBytes(pointer:Pointer, count:Int):Bytes {
        return pointer.memory.pointerToBytes(pointer, count);
    }
    #end

    /**
     * Return a data view representing a C array.
     *
     * @see `Memory.pointerToDataView`
     */
    public static function getDataView(pointer:Pointer, count:Int):DataView {
        return pointer.memory.pointerToDataView(pointer, count);
    }
}
