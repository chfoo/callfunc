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
     *
     * @see `Library.newVariadicFunction` for C variadic functions.
     */
    public function newFunction(name:String, ?params:Array<DataType>,
        ?returnType:DataType, ?abi:Int):Function;

    /**
     * Create a handle to a variadic function.
     *
     * @param name Symbol name.
     * @param params Data types corresponding to the parameters.
     * @param fixedParamCount Number of parameters that are fixed at the
     *     start of the parameters.
     * @param returnType Data type of the return value.
     * @param abi ABI calling method.
     * @throws String
     * @see `Library.newFunction`
     */
    public function newVariadicFunction(name:String, params:Array<DataType>,
        fixedParamCount:Int, ?returnType:DataType, ?abi:Int):Function;
}
