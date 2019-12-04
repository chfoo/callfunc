package callfunc.core.emscripten;

class EmCallback implements CallbackHandle {
    final context:EmContext;
    final pointer:BasicPointer;

    public function new(context:EmContext,
            haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>, ?returnType:DataType) {
        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;

        this.context = context;

        var signatureBuffer = new StringBuf();

        signatureBuffer.add(EmDataType.toWasmSignature(returnType));

        for (param in params) {
            signatureBuffer.add(EmDataType.toWasmSignature(param));
        }

        var nativePointer = context.module.addFunction(
            Reflect.makeVarArgs(cast haxeFunction), signatureBuffer.toString());
        pointer = new EmPointer(context, nativePointer);
    }

    public function getPointer():BasicPointer {
        return pointer;
    }

    public function dispose() {
        // nothing
    }
}
