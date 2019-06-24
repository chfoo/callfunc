package callfunc.emscripten;

class EmLibrary implements Library {
    final module:EmscriptenModule;

    public function new(module:EmscriptenModule) {
        this.module = module;
    }

    public function dispose() {
        // nothing
    }

    public function getSymbol(name:String):Pointer {
        throw "Not supported";
    }

    public function newFunction(name:String, ?params:Array<DataType>,
            ?returnType:DataType, ?abi:Int):Function {
        return new EmFunction(module, name, params, returnType);
    }

    public function newVariadicFunction(name:String, params:Array<DataType>,
            fixedParamCount:Int,
            ?returnType:DataType, ?abi:Int):Function {
        throw "Not supported. emscripten-core/emscripten #5563 #5684";
    }
}
