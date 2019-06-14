package callfunc;

class Callfunc {
    static var _instance:Null<Callfunc>;

    public final memory:Memory;

    public function new() {
        memory = newMemory();
    }

    public static function instance():Callfunc {
        if (_instance == null) {
            _instance = new Callfunc();
        }

        return _instance;
    }

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

    public function newLibrary(name:String):Library {
        #if (cpp || hl)
        return new callfunc.impl.LibraryImpl(name, memory);
        #else
        throw "Not supported";
        #end
    }

    public function newStructType(dataTypes:Array<DataType>):StructType {
        #if (cpp || hl)
        return new callfunc.impl.StructTypeImpl(dataTypes, memory);
        #else
        throw "Not supported";
        #end
    }
}
