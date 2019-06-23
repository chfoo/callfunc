package callfunc;

import haxe.Int64;

/**
 * Represents a C pointer.
 */
interface Pointer {
    /**
     * The value of the pointer that represents an address in memory
     * where the targeted data is stored.
     */
    public var address(get, never):Int64;

    /**
     * Returns whether the address does not point to anywhere.
     */
    public function isNull():Bool;

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
    public function get(dataType:DataType, offset:Int = 0):Any;

    /**
     * Sets the value at the address memory location.
     *
     * @param value A value of type `Int`, `haxe.io.Int64`,
     *     `Float`, or `Pointer`. Numeric types will be promoted and casted
     *      appropriately.
     * @param dataType Data type of the value expected at the addressed memory.
     * @param offset Value in bytes used to offset the address. This is used to
     *     access fields in a struct.
     */
    public function set(value:Any, dataType:DataType, offset:Int = 0):Void;

    /**
     * Returns the element value at the addressed C array location.
     *
     * @param dataType Data type of the array.
     * @param index Element index of the array.
     * @see `Pointer.get` for return types.
     */
    public function arrayGet(dataType:DataType, index:Int):Any;

    /**
     * Sets the element value at the address C array location.
     * @param value Element value.
     * @param dataType Data type of the array.
     * @param index Element index.
     * @see `Pointer.set` for parameter types.
     */
    public function arraySet(value:Any, dataType:DataType, index:Int):Void;
}
