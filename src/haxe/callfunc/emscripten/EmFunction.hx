package callfunc.emscripten;

class EmFunction implements Function {
    public var name(get, never):String;
    public var params(get, never):Array<DataType>;
    public var returnType(get, never):DataType;

    final module:EmscriptenModule;
    final _name:String;
    final _params:Array<DataType>;
    final _returnType:DataType;
    final jsFunc:haxe.Constraints.Function;

    public function new(module:EmscriptenModule, name:String,
            ?params:Array<DataType>, ?returnType:DataType) {
        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;

        this.module = module;
        _name = name;
        _params = params;
        _returnType = returnType;

        var ccallParams = _params.map(EmDataType.toCCallType);
        var ccallReturnType = EmDataType.toCCallReturnType(_returnType);

        jsFunc = module.cwrap(name, ccallReturnType, ccallParams);
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

        return @:nullSafety(Off) Reflect.callMethod(null, jsFunc, args);
    }
}
