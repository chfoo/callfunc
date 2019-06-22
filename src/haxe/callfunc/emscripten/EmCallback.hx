package callfunc.emscripten;

class EmCallback implements Callback {
    final module:EmscriptenModule;
    final pointer:Pointer;

    public function new(module:EmscriptenModule,
            haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>, ?returnType:DataType) {
        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;

        this.module = module;


        var signatureBuffer = new StringBuf();

        signatureBuffer.add(EmDataType.toWasmSignature(returnType));

        for (param in params) {
            signatureBuffer.add(EmDataType.toWasmSignature(param));
        }

        var nativePointer = module.addFunction(
            Reflect.makeVarArgs(cast haxeFunction), signatureBuffer.toString());
        pointer = new EmPointer(module, nativePointer);
    }

    public function getPointer():Pointer {
        return pointer;
    }

    public function dispose() {
        // nothing
    }
}
