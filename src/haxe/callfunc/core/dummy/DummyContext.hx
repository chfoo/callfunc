package callfunc.core.dummy;

import haxe.Int64;
import haxe.io.Bytes;

class DummyContext implements Context {
    public function new() {
    }

    public function alloc(size:Int, initZero:Bool = false):BasicPointer {
        throw "Not implemented";
    }

    public function free(pointer:BasicPointer):Void {
        throw "Not implemented";
    }

    public function sizeOf(type:DataType):Int {
        throw "Not implemented";
    }

    public function getPointer(address:Int64):BasicPointer {
        throw "Not implemented";
    }

    #if sys
    public function bytesToPointer(bytes:Bytes):BasicPointer {
        throw "Not implemented";
    }

    public function pointerToBytes(pointer:BasicPointer, count:Int):Bytes {
        throw "Not implemented";
    }
    #end

    public function pointerToDataView(pointer:BasicPointer, count:Int):DataView {
        throw "Not implemented";
    }

    public function newLibrary(name:String):LibraryHandle {
        throw "Not implemented";
    }

    public function newStructType(dataTypes:Array<DataType>):StructTypeHandle {
        throw "Not implemented";
    }

    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):CallbackHandle {
        throw "Not implemented";
    }
}
