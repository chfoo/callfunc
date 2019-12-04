package callfunc.core;

import haxe.Int64;
import haxe.io.Bytes;

/**
 * Handle to access foreign functions and data.
 */
interface Context {
    /**
     * Allocates memory on the heap.
     *
     * @see `Callfunc.alloc`
     */
    public function alloc(size:Int, initZero:Bool = false):BasicPointer;

    /**
     * Releases previously allocated memory.
     */
    public function free(pointer:BasicPointer):Void;

    /**
     * Returns the width of the data type.
     * @return Number of bytes.
     */
    public function sizeOf(type:DataType):Int;

    /**
     * Returns a pointer from the given address.
     *
     * @param address An address in memory.
     */
    public function getPointer(address:Int64):BasicPointer;

    #if sys
    /**
     * Exposes a pointer to the underlying C array of a Haxe `Bytes`.
     *
     * @see `Callfunc.bytesToPointer`
     */
    public function bytesToPointer(bytes:Bytes):BasicPointer;

    /**
     * Wraps a pointer of a C array to Haxe `Bytes`.
     *
     * @see `Pointer.getBytes`
     */
    public function pointerToBytes(pointer:BasicPointer, count:Int):Bytes;
    #end

    /**
     * Wraps a pointer of C array to a data view.
     *
     * @see `Pointer.getDataView`
     */
    public function pointerToDataView(pointer:BasicPointer, count:Int):DataView;

    /**
     * Returns a library handle to a dynamic library.
     *
     * @see `Callfunc.openLibrary`
     */
    public function newLibrary(name:String):LibraryHandle;

    /**
     * Returns a C struct type information.
     * @param dataTypes Data types for each field of the struct.
     * @throws String An error message if the data type is invalid.
     */
    public function newStructType(dataTypes:Array<DataType>):StructTypeHandle;

    /**
     * Returns a callback handle for passing Haxe functions to C code.
     *
     * @see `Callfunc.wrapCallback`
     */
    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):CallbackHandle;
}
