package callfunc;

import haxe.io.ArrayBufferView;
import haxe.io.Bytes;
import haxe.Int64;

/**
 * Memory access functions.
 */
interface Memory {
    /**
     * Allocates memory on the heap.
     *
     * This calls standard C `malloc()` or `calloc()`.
     *
     * If the allocation fails, the pointer will have an address of 0 (a
     * null pointer).
     *
     * @param size Number of bytes.
     * @param initZero Whether to initialize the array to 0.
     */
    public function alloc(size:Int, initZero:Bool = false):Pointer;

    /**
     * Releases previously allocated memory.
     *
     * This should only be called for pointers that the caller has previously
     * allocated or have lifecycle control. As well, it should not be called
     * more than once for a pointer.
     */
    public function free(pointer:Pointer):Void;

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
    public function getPointer(address:Int64):Pointer;

    #if sys
    /**
     * Exposes a pointer to the underlying C array of a Haxe `Bytes`.
     *
     * Care must be ensured that the `Bytes` instance has not been garbage
     * collected when using the pointer.
     *
     * @param bytes
     */
    public function bytesToPointer(bytes:Bytes):Pointer;

    /**
     * Wraps a pointer of a C array to Haxe `Bytes`.
     *
     * Care must be ensured that the pointer is not freed. The pointer is
     * not automatically freed when the bytes instance is garbage collected.
     *
     * @param pointer
     * @param count Array length in bytes
     */
    public function pointerToBytes(pointer:Pointer, count:Int):Bytes;
    #end

    /**
     * Wraps a pointer of C array to a data view.
     *
     * Care must be ensured that the pointer is not freed. The pointer is
     * not automatically freed when the buffer's data is garbage collected.
     *
     * @param pointer
     * @param count Array length in bytes
     */
    public function pointerToDataView(pointer:Pointer, count:Int):DataView;
}
