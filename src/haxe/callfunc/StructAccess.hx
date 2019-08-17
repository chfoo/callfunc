package callfunc;

class StructAccessImpl {
    final pointer:Pointer;
    final structType:StructType;
    final nameMap:Map<String,Int>;

    public function new(pointer:Pointer, structType:StructType, names:Iterable<String>) {
        this.pointer = pointer;
        this.structType = structType;
        this.nameMap = new Map();

        var index = 0;
        for (name in names) {
            nameMap.set(name, index);
            index += 1;
        }
    }

    function getIndex(name:String):Int {
        var index = nameMap.get(name);

        if (index == null) {
            throw 'Field $name not defined';
        }

        return index;
    }

    public function get(name:String):Any {
        var index = getIndex(name);

        return pointer.get(structType.dataTypes[index],
            structType.offsets[index]);
    }

    public function set<T>(name:String, value:T):T {
        var index = getIndex(name);

        pointer.set(value, structType.dataTypes[index],
            structType.offsets[index]);

        return value;
    }
}

/**
 * Provides access to a struct pointer by names.
 */
@:forward
abstract StructAccess(StructAccessImpl) {
    /**
     * @param pointer Pointer to an existing struct.
     * @param structType Structure definition.
     * @param names Names of the fields in the struct.
     */
    public inline function new(pointer:Pointer, structType:StructType,
            names:Iterable<String>) {
        this = new StructAccessImpl(pointer, structType, names);
    }

    @:arrayAccess
    public inline function get(name:String):Any {
        return this.get(name);
    }

    @:arrayAccess
    public inline function set<T>(name:String, value:T):T {
        return this.set(name, value);
    }
}
