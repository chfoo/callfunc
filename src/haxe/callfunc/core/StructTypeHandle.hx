package callfunc.core;

/**
 * Handle to C structure (composite data type) packing information.
 */
interface StructTypeHandle extends Disposable {
    /**
     * Size in bytes of the struct.
     */
    public var size(get, never):Int;

    /**
     * Data types of each field.
     */
    public var dataTypes(get, never):Array<DataType>;

    /**
     * Location of each field in the struct.
     */
    public var offsets(get, never):Array<Int>;
}
