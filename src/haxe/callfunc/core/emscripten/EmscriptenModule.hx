package callfunc.core.emscripten;

import haxe.DynamicAccess;
import haxe.io.Float64Array;
import js.lib.Float32Array;
import js.lib.Int16Array;
import js.lib.Int32Array;
import js.lib.Int8Array;
import js.lib.Uint16Array;
import js.lib.Uint32Array;
import js.lib.Uint8Array;

extern class EmscriptenModule {
    public var HEAP8:Int8Array;
    public var HEAP16:Int16Array;
    public var HEAP32:Int32Array;
    public var HEAPU8:Uint8Array;
    public var HEAPU16:Uint16Array;
    public var HEAPU32:Uint32Array;
    public var HEAPF32:Float32Array;
    public var HEAPF64:Float64Array;

    public function ccall(ident:String, ?returnType:Null<String>,
        ?argTypes:Array<String>, ?args:Array<Any>, ?opts:Any):Any;

    public function cwrap(ident:String, ?returnType:Null<String>,
        ?argTypes:Array<String>, ?opts:Any):haxe.Constraints.Function;

    public function setValue(ptr:Float, value:Any, type:String):Void;

    public function getValue(ptr:Float, type:String):Any;

    public function addFunction(func:haxe.Constraints.Function,
        signature:String):Int;
}
