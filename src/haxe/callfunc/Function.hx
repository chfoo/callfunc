package callfunc;

interface Function extends Disposable {
    public var name(get, never):String;
    public var params(get, never):Array<DataType>;
    public var returnType(get, never):Null<DataType>;
    public function call(?args:Array<Any>):Any;
}
