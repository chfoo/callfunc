package callfunc;

import callfunc.core.StructTypeHandle;

/**
 * Definition of C structure (composite data type) packing information
 * and field names.
 */
class StructDef implements Disposable {
    final structTypeHandle:StructTypeHandle;

    /**
     * Names of each field in order.
     */
    public final names:Array<String>;

    /**
     * Size in bytes of the struct.
     */
    public var size(get, never):Int;

    /**
     * Data types of each field.
     */
    public var dataTypes(get, never):Array<DataType>;

    /**
     * Location of each field in the struct in bytes.
     */
    public var offsets(get, never):Array<Int>;

    public function new(structType:StructTypeHandle, names:Array<String>) {
        this.structTypeHandle = structType;
        this.names = names;
    }

    function get_size() {
        return structTypeHandle.size;
    }

    function get_dataTypes() {
        return structTypeHandle.dataTypes;
    }

    function get_offsets() {
        return structTypeHandle.offsets;
    }

    /**
     * Return a StructAccess object from a given pointer.
     *
     * @param pointer Pointer to a C struct with a matching definition.
     */
    public function access(pointer:Pointer):StructAccess {
        return new StructAccess(pointer, structTypeHandle, names);
    }

    public function dispose() {
        structTypeHandle.dispose();
    }
}
