package callfunc;

import haxe.Int64;

interface Pointer {
    public var address(get, never):Int64;

    public function isNull():Bool;
    public function get(dataType:DataType, offset:Int = 0):Any;
    public function set(value:Any, dataType:DataType, offset:Int = 0):Void;
}
