package callfunc;

import haxe.io.Bytes;
import haxe.Int64;

interface Memory {
    public function alloc(size:Int, initZero:Bool = false):Pointer;
    public function free(pointer:Pointer):Void;
    public function sizeOf(type:DataType):Int;
    public function getPointer(address:Int64):Pointer;
    public function bytesToPointer(bytes:Bytes):Pointer;
    public function pointerToBytes(pointer:Pointer, count:Int):Bytes;
}
