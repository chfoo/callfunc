package callfunc;

/**
 * Handle to access foreign functions and data.
 */
interface Context {
    /**
     * An instance of `Memory`.
     */
    public var memory(get, never):Memory;

    /**
     * Returns a library handle to a dynamic library.
     * @param name A filename to the dynamic library as accepted by `dlopen()`
     *     or `LoadLibrary()` on Windows.
     */
    public function newLibrary(name:String):Library;

    /**
     * Returns a C struct type information.
     * @param dataTypes Data types for each field of the struct.
     */
    public function newStructType(dataTypes:Array<DataType>):StructType;

    /**
     * Returns a Callback instance for passing Haxe functions to C code.
     *
     * Availability depends on the libffi platform support for closures.
     *
     * @param haxeFunction Callback function to be wrapped.
     * @param params Data types corresponding to the function parameters
     *     exposed to the C code.
     * @param returnType Data type of the return value of the exposed function.
     */
    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):Callback;
}
