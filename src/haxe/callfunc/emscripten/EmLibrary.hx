package callfunc.emscripten;

class EmLibrary implements Library {
    final context:EmContext;

    public function new(context:EmContext) {
        this.context = context;
    }

    public function dispose() {
        // nothing
    }

    public function getSymbol(name:String):Pointer {
        throw "Not supported";
    }

    public function newFunction(name:String, ?params:Array<DataType>,
            ?returnType:DataType, ?abi:Int):Function {
        return new EmFunction(context, this, name, params, returnType);
    }

    public function newVariadicFunction(name:String, params:Array<DataType>,
            fixedParamCount:Int,
            ?returnType:DataType, ?abi:Int):Function {
        throw "Not supported. emscripten-core/emscripten #5563 #5684";
    }
}
