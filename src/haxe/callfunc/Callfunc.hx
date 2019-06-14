package callfunc;

/**
 * Main context class for interfacing with foreign functions.
 */
class Callfunc {
    static var _instance:Null<Callfunc>;

    /**
     * An instance of `Memory`.
     */
    public final memory:Memory;

    public function new() {
        memory = newMemory();
    }

    /**
     * Returns a singleton instance.
     */
    public static function instance():Callfunc {
        if (_instance == null) {
            _instance = new Callfunc();
        }

        return _instance;
    }

    /**
     * Replace the singleton instance with the given instance.
     * @param instance
     */
    public static function setInstance(instance:Callfunc) {
        _instance = instance;
    }

    function newMemory():Memory {
        #if (cpp || hl)
        return new callfunc.impl.MemoryImpl();
        #else
        throw "Not supported";
        #end
    }

    /**
     * Returns a library handle to a dynamic library.
     * @param name A filename to the dynamic library as accepted by `dlopen()`
     *     or `LoadLibrary()` on Windows.
     */
    public function newLibrary(name:String):Library {
        #if (cpp || hl)
        return new callfunc.impl.LibraryImpl(name, memory);
        #else
        throw "Not supported";
        #end
    }

    /**
     * Returns a C struct type information.
     * @param dataTypes Data types for each field of the struct.
     */
    public function newStructType(dataTypes:Array<DataType>):StructType {
        #if (cpp || hl)
        return new callfunc.impl.StructTypeImpl(dataTypes, memory);
        #else
        throw "Not supported";
        #end
    }
}
