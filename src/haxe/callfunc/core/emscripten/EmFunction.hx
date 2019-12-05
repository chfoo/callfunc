package callfunc.core.emscripten;

using callfunc.core.emscripten.ModuleTools;

class EmFunction implements FunctionHandle {
    final context:EmContext;
    final params:Array<DataType>;
    final returnType:DataType;
    final jsFunc:haxe.Constraints.Function;
    final fixedParamCount:Int;
    var varargBuffer:Float = 0;

    public function new(context:EmContext, name:String,
            ?params:Array<DataType>, ?returnType:DataType,
            ?fixedParamCount:Int) {
        this.context = context;
        this.params = params != null ? params : [];
        this.returnType = returnType != null ? returnType : DataType.Void;
        this.fixedParamCount = fixedParamCount != null ? fixedParamCount : -1;

        jsFunc = context.module.getSymbol(name);
    }

    public function dispose() {
        if (varargBuffer != 0) {
            context.module.getSymbol("free")(varargBuffer);
            varargBuffer = 0;
        }
    }

    public function call(?args:Array<Any>):Any {
        args = args != null ? args : [];
        args = unwrapArgs(args);

        if (fixedParamCount < 0) {
            final result = @:nullSafety(Off)
                Reflect.callMethod(null, jsFunc, args);

            return wrapReturnValue(result);
        } else {
            // WASM ABI convention is fixed arguments are passed as normal
            // but variadic arguments are stored in the stack and a pointer
            // to them is passed to the function.
            if (varargBuffer == 0) {
                allocateVarargBuffer();
            }

            populateVarargBuffer(args);

            final wasmABIArgs = args.slice(0, fixedParamCount);
            wasmABIArgs.push(varargBuffer);

            final result = @:nullSafety(Off)
                Reflect.callMethod(null, jsFunc, wasmABIArgs);

            return wrapReturnValue(result);
        }
    }

    function unwrapArgs(args:Array<Any>):Array<Any> {
        for (index in 0...args.length) {
            if (params[index] == DataType.Pointer) {
                args[index] = cast(args[index], EmPointer).nativePointer;
            }
        }

        return args;
    }

    function wrapReturnValue(value:Any):Any {
        switch returnType {
            case Pointer:
                return new EmPointer(context, value);
            default:
                return value;
        }
    }

    function getVarargBufferSize():Int {
        var size = 0;

        if (fixedParamCount > 0) {
            for (dataType in params.slice(fixedParamCount)) {
                size += EmDataType.getSize(dataType);
            }
        }

        return size;
    }

    function allocateVarargBuffer() {
        varargBuffer = context.module.getSymbol("malloc")(getVarargBufferSize());

        if (varargBuffer == 0) {
            throw "Memory allocation failed";
        }
    }

    function populateVarargBuffer(args:Array<Any>) {
        Debug.assert(fixedParamCount >= 0);
        var offset = 0;

        for (index in fixedParamCount...params.length) {
            final dataType = params[index];
            final arg = args[index];

            context.module.setValue(
                varargBuffer + offset,
                arg,
                EmDataType.toLLVMType(dataType)
            );

            offset += EmDataType.getSize(dataType);
        }
    }
}
