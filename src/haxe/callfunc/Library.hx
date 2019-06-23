package callfunc;

/**
 * Handle to a loaded dynamic library.
 */
interface Library extends Disposable {
    /**
     * Returns a pointer to a symbol.
     *
     * @throws String An error message if the symbol was not found or any
     *     other error.
     */
    public function getSymbol(name:String):Pointer;

    /**
     * Create a handle to a function.
     *
     * This method does not support variadic functions.
     *
     * @param name Symbol name.
     * @param params Data types corresponding to the function parameters.
     *     If the function does not accept arguments, specify `null` or empty
     *     array.
     * @param abi If supported by the platform and target, an ABI calling
     *     method matching `enum ffi_abi` defined in `ffitarget.h`.
     * @param returnType Data type of the return value. If the function does
     *     not return a value. Specify `null` or `DataType.Void`.
     *
     * @throws String An error message if the function was not found, a
     *     data type or ABI is invalid, or any other error.
     */
    public function newFunction(name:String, ?params:Array<DataType>,
        ?returnType:DataType, ?abi:Int):Function;
}
