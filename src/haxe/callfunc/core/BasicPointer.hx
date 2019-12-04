package callfunc.core;

import haxe.Int64;

/**
 * C pointer methods
 */
interface BasicPointer {
    public var address(get, never):Int64;

    /**
     * Returns the value at the addressed memory location.
     *
     * @see `Pointer.get`
     */
    public function get(dataType:DataType, offset:Int = 0):Any;

    /**
     * Sets the value at the addressed memory location.
     *
     * @see `Pointer.set`
     */
    public function set(value:Any, dataType:DataType, offset:Int = 0):Void;

    /**
     * Returns the element value at the addressed C array location.
     *
     * @see `Pointer.arrayGet`
     */
    public function arrayGet(index:Int, dataType:DataType):Any;

    /**
     * Sets the element value at the address C array location.
     *
     * @see `Pointer.arraySet`
     */
    public function arraySet(index:Int, value:Any, dataType:DataType):Void;
}
