package callfunc.emscripten;

class EmFunction implements Function {
    public var library(get, never):Library;
    public var name(get, never):String;
    public var params(get, never):Array<DataType>;
    public var returnType(get, never):DataType;

    final context:EmContext;
    final _library:Library;
    final _name:String;
    final _params:Array<DataType>;
    final _returnType:DataType;
    final jsFunc:haxe.Constraints.Function;

    public function new(context:EmContext, library:Library, name:String,
            ?params:Array<DataType>, ?returnType:DataType) {
        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;

        this.context = context;
        _library = library;
        _name = name;
        _params = params;
        _returnType = returnType;

        var ccallParams = _params.map(EmDataType.toCCallType);
        var ccallReturnType = EmDataType.toCCallReturnType(_returnType);

        jsFunc = context.module.cwrap(name, ccallReturnType, ccallParams);
    }

    function get_library():Library {
        return _library;
    }

    function get_name():String {
        return _name;
    }

    function get_params():Array<DataType> {
        return _params;
    }

    function get_returnType():DataType {
        return _returnType;
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
