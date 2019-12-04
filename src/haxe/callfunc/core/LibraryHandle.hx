package callfunc.core;

/**
 * Handle to a loaded dynamic library.
 */
interface LibraryHandle extends Disposable {
    public function hasSymbol(name:String):Bool;

    /**
     * Returns a pointer to a symbol.
     *
     * @throws String An error message if the symbol was not found or any
     *     other error.
     */
    public function getPointer(name:String):BasicPointer;

    /**
     * Create a handle to a function.
     *
     * @see `Library`
     */
    public function newFunction(name:String, ?params:Array<DataType>,
        ?returnType:DataType, ?abi:Int):FunctionHandle;

    /**
     * Create a handle to a variadic function.
     *
     * @see `Library`
     */
    public function newVariadicFunction(name:String, params:Array<DataType>,
        fixedParamCount:Int, ?returnType:DataType, ?abi:Int):FunctionHandle;
}
