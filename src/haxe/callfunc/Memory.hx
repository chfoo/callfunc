package callfunc;

import haxe.io.Bytes;
import haxe.Int64;

/**
 * Memory access functions.
 */
interface Memory {
    /**
     * Allocates memory on the heap.
     *
     * @param size Number of bytes.
     * @param initZero Whether to initialize the array to 0.
     */
    public function alloc(size:Int, initZero:Bool = false):Pointer;

    /**
     * Releases previously allocated memory.
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
     * Wraps pointer of a C array to Haxe `Bytes`.
     *
     * Care must be ensured that the pointer is not freed and the lifecycle
     * of the pointer is transferred to the `Bytes` instance.
     *
     * @param pointer
     * @param count Array length in bytes
     */
    public function pointerToBytes(pointer:Pointer, count:Int):Bytes;
}
