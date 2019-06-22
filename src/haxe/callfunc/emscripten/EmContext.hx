package callfunc.emscripten;

class EmContext implements Context {

    public var memory(get, never):Memory;

    final _memory:Memory;
    final module:EmscriptenModule;

    public function new(module:EmscriptenModule) {
        this.module = module;
        _memory = new EmMemory(module);
    }

    function get_memory():Memory {
        return _memory;
    }

    public function newLibrary(name:String):Library {
        if (name != "") {
            throw "Library name cannot be specified. Only empty string \"\" is supported.";
        }

        return new EmLibrary(module);
    }

    public function newStructType(dataTypes:Array<DataType>):StructType {
        return new EmStructType(dataTypes);
    }

    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):Callback {
        return new EmCallback(module, haxeFunction, params, returnType);
    }
}
