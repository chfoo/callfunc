package callfunc.emscripten;

class EmContext implements Context {

    public var memory(get, never):Memory;

    final _memory:Memory;

    @:allow(callfunc.emscripten)
    final module:EmscriptenModule;

    public function new(module:EmscriptenModule) {
        this.module = module;
        _memory = new EmMemory(this);
    }

    function get_memory():Memory {
        return _memory;
    }

    public function newLibrary(name:String):Library {
        if (name != "") {
            throw "Library name cannot be specified. Only empty string \"\" is supported.";
        }

        return new EmLibrary(this);
    }

    public function newStructType(dataTypes:Array<DataType>):StructType {
        return new EmStructType(dataTypes);
    }

    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):Callback {
        return new EmCallback(this, haxeFunction, params, returnType);
    }
}
