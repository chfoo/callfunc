package callfunc.core.emscripten;

using callfunc.core.emscripten.ModuleTools;

class EmFunction implements FunctionHandle {
    final context:EmContext;
    final _params:Array<DataType>;
    final _returnType:DataType;
    final jsFunc:haxe.Constraints.Function;

    public function new(context:EmContext, name:String,
            ?params:Array<DataType>, ?returnType:DataType) {
        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;

        this.context = context;
        _params = params;
        _returnType = returnType;

        // Check for existence
        context.module.getSymbol(name);

        var ccallParams = _params.map(EmDataType.toCCallType);
        var ccallReturnType = EmDataType.toCCallReturnType(_returnType);

        jsFunc = context.module.cwrap(name, ccallReturnType, ccallParams);
    }

    public function dispose() {
        // nothing
    }

    public function call(?args:Array<Any>):Any {
        args = args != null ? args : [];

        for (index in 0...args.length) {
            if (_params[index] == DataType.Pointer) {
                args[index] = cast(args[index], EmPointer).nativePointer;
            }
        }

        var result = @:nullSafety(Off) Reflect.callMethod(null, jsFunc, args);

        switch _returnType {
            case Pointer:
                return new EmPointer(context, result);
            default:
                // pass
        }

        return result;
    }
}
