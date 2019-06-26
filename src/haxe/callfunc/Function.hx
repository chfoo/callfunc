package callfunc;

/**
 * A handle to a function in a dynamic library.
 */
interface Function extends Disposable {
    /**
     * Library of which this function belongs to.
     */
    public var library(get, never):Library;

    /**
     * Symbol name of the function.
     */
    public var name(get, never):String;

    /**
     * Data types of the function parameters.
     */
    public var params(get, never):Array<DataType>;

    /**
     * Data type of the return value.
     *
     * If the function has no return value, `DataType.Void` is used.
     */
    public var returnType(get, never):DataType;

    /**
     * Execute the function.
     *
     * @param args Arguments that correspond the parameter data types.
     *     Arguments can be `Int`, `haxe.io.Int64`, `Float`, or `Pointer`.
     *     Numeric types will be promoted and casted
     *     (with possible truncation or loss of precision) appropriately.
     * @return If `returnType` is not `DataType.Void`, the return value
     *     will be converted to either `Int`, `haxe.io.Int64`, `Float`, or
     *     `Pointer`.
     *
     *     Integer data types that fit within 32 bits will be
     *     promoted to `Int` while wider integers will be promoted
     *     to `haxe.io.Int64`.
     *
     * @throws String An error message if the argument list is invalid (such
     *     as wrong size or wrong type.
     */
    public function call(?args:Array<Any>):Any;
}
