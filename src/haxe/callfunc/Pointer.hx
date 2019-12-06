package callfunc;

import callfunc.core.BasicPointer;
import callfunc.core.Context;
import callfunc.string.StringUtil;
import callfunc.string.Encoding;
import haxe.Int64;
import haxe.io.Bytes;

/**
 * Read and write values of a C pointer.
 */
class Pointer {
    final context:Context;
    @:allow(callfunc.Pointer)
    final basicPointer:BasicPointer;

    /**
     * The value of the pointer that represents an address in memory
     * where the targeted data is stored.
     */
    public var address(get, never):Int64;

    /**
     * Default data type if not specified in get or set methods.
     */
    public var dataType:DataType;

    public function new(context:Context, basicPointer:BasicPointer) {
        this.context = context;
        this.basicPointer = basicPointer;
        dataType = DataType.SInt;
    }

    function get_address() {
        return basicPointer.address;
    }

    /**
     * Returns whether the pointer is a null pointer.
     *
     * If the pointer is a null pointer, the address is not valid and typically
     * represented with a value of 0.
     */
    public function isNull():Bool {
        return address == 0;
    }

    inline function getDataType(dataType:Null<DataType>):DataType {
        return dataType != null ? dataType : this.dataType;
    }

    /**
     * Returns the value at the addressed memory location.
     *
     * @param dataType Data type of the value expected at the addressed memory.
     * @param offset Value in bytes used to offset the address. This is used to
     *     access fields in a struct.
     * @return A value converted to the type `Int`, `haxe.io.Int64`,
     *     `Float`, or `Pointer`.
     *
     *     Integer data types that fit within 32 bits will be
     *     promoted to `Int` while wider integers will be promoted
     *     to `haxe.io.Int64`.
     */
    public function get(?dataType:DataType, offset:Int = 0):Any {
        return wrap(basicPointer.get(getDataType(dataType), offset), context);
    }

    /**
     * Sets the value at the addressed memory location.
     *
     * @param value A value of type `Int`, `haxe.io.Int64`,
     *     `Float`, or `Pointer`. Numeric types will be promoted and casted
     *      appropriately.
     * @param dataType Data type of the value expected at the addressed memory.
     * @param offset Value in bytes used to offset the address. This is used to
     *     access fields in a struct.
     */
    public function set(value:Any, ?dataType:DataType, offset:Int = 0) {
        basicPointer.set(unwrap(value), getDataType(dataType), offset);
    }

    /**
     * Returns the element value at the addressed C array location.
     *
     * @param index Element index of the array.
     * @param dataType Data type of the array.
     * @see `Pointer.get` for return types.
     */
    public function arrayGet(index:Int, ?dataType:DataType):Any {
        return wrap(basicPointer.arrayGet(index, getDataType(dataType)), context);
    }

    /**
     * Sets the element value at the addressed C array location.
     * @param index Element index.
     * @param value Element value.
     * @param dataType Data type of the array.
     * @see `Pointer.set` for parameter types.
     */
    public function arraySet(index:Int, value:Any, ?dataType:DataType) {
        basicPointer.arraySet(index, unwrap(value), getDataType(dataType));
    }

    /**
     * Removes the memory allocated at the addressed location.
     *
     * This should only be called for pointers for which the caller has
     * ownership for previously allocated memory.
     *
     * Calling this more than once is undefined behavior.
     */
    public function free() {
        context.free(basicPointer);
    }

    /**
     * Decodes the addressed value as a char array and returns new Haxe string.
     *
     * @param length Number in bytes (not code units and not code points) of the
     *     string. If not given, the length of the string is determined by
     *     searching for a null terminator.
     * @param encoding
     */
    public function getString(?length:Int,
            encoding:Encoding = Encoding.UTF8):String {

        final length = StringUtil.getPointerNullTerminator(this, encoding);
        final view = getDataView(length);
        trace(length, encoding);

        return view.getStringFull(0, length, encoding);
    }

    /**
     * Encodes the given string and writes it as a char array.
     *
     * @param text String to be encoded,
     * @param encoding Encoding such as UTF-8.
     * @param terminator Whether to include a null-terminator.
     * @return Number of bytes written
     */
    public function setString(text:String, encoding:Encoding = Encoding.UTF8,
            terminator:Bool = false, ?lengthCallback:Int->Void):Int {
        final length = StringUtil.getEncodedLength(text, encoding, terminator);
        final view = getDataView(length);

        return view.setStringFull(0, text, encoding, terminator);
    }

    #if sys
    /**
     * Returns a Haxe Bytes using the pointer's value as the underlying data.
     *
     * @see `getDataView` for the purpose of this method.
     *
     * Compared to `getDataView` this method may be slightly faster but is not
     * portable between targets.
     *
     */
    public function getBytes(count:Int):Bytes {
        return context.pointerToBytes(basicPointer, count);
    }
    #end

    /**
     * Return a data view using the pointer's value as the underlying data.
     *
     * The pointer is interpreted as the target's native array and used as
     * the data view's underlying bytes data.
     *
     * This method is useful for easier and faster access than the
     * `arrayGet` and `arraySet` methods.
     *
     * Care must be ensured that the pointer is not freed or else the data
     * view will access invalid memory locations.
     *
     * The pointer is not automatically freed when the returned data view is
     * garbage collected.
     *
     * @param count Array length in bytes.
     */
    public function getDataView(count:Int):DataView {
        return context.pointerToDataView(basicPointer, count);
    }

    @:allow(callfunc.Function)
    static function wrap(value:Any, context:Context):Any {
        if (Std.is(value, BasicPointer)) {
            return new Pointer(context, value);
        } else {
            return value;
        }
    }

    @:allow(callfunc)
    static function unwrap(value:Any):Any {
        if (Std.is(value, Pointer)) {
            return (value:Pointer).basicPointer;
        } else {
            return value;
        }
    }
}
