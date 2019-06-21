package callfunc;

import callfunc.impl.ContextImpl;

/**
 * Main context class for interfacing with foreign functions.
 */
class Callfunc implements Context {
    static var _instance:Null<Context>;

    public var memory(get, never):Memory;
    var _context:Context;

    public function new() {
        _context = new ContextImpl();
    }

    function get_memory() {
        return _context.memory;
    }

    /**
     * Returns a singleton instance.
     */
    public static function instance():Context {
        if (_instance == null) {
            _instance = new Callfunc();
        }

        return _instance;
    }

    /**
     * Replace the singleton instance with the given instance.
     * @param instance
     */
    public static function setInstance(instance:Context) {
        _instance = instance;
    }

    public function newLibrary(name:String):Library {
        return _context.newLibrary(name);
    }

    public function newStructType(dataTypes:Array<DataType>):StructType {
        return _context.newStructType(dataTypes);
    }

    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):Callback {
        return _context.newCallback(haxeFunction, params, returnType);
    }
}
