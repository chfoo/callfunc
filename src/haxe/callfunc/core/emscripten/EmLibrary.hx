package callfunc.core.emscripten;

using callfunc.core.emscripten.ModuleTools;

class EmLibrary implements LibraryHandle {
    final context:EmContext;

    public function new(context:EmContext) {
        this.context = context;
    }

    public function dispose() {
        // nothing
    }

    public function hasSymbol(name:String):Bool {
        try {
            context.module.getSymbol(name);
        } catch (error:String) {
            return false;
        }

        return true;
    }

    public function getPointer(name:String):BasicPointer {
        throw "Not supported";
    }

    public function newFunction(name:String, ?params:Array<DataType>,
            ?returnType:DataType, ?abi:Int):FunctionHandle {
        return new EmFunction(context, name, params, returnType);
    }

    public function newVariadicFunction(name:String, params:Array<DataType>,
            fixedParamCount:Int,
            ?returnType:DataType, ?abi:Int):FunctionHandle {
        throw "Not supported. emscripten-core/emscripten #5563 #5684";
    }
}
