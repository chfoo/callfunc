package callfunc;

/**
 * Allows C code to call Haxe functions.
 */
interface Callback extends Disposable {
    /**
     * Returns a function pointer which can be called by C code.
     */
    public function getPointer():Pointer;
}
