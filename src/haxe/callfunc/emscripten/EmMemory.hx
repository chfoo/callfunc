package callfunc.emscripten;

import haxe.io.Bytes;
import haxe.Int64;

using callfunc.emscripten.ModuleTools;

class EmMemory implements Memory {
    final module:EmscriptenModule;

    public function new(module:EmscriptenModule) {
        this.module = module;
    }

    public function alloc(size:Int, initZero:Bool = false):Pointer {
        if (initZero) {
            return new EmPointer(module, module.getSymbol("calloc")(size, 1));
        } else {
            return new EmPointer(module, module.getSymbol("malloc")(size));
        }
    }

    public function free(pointer:Pointer) {
        module.getSymbol("free")(cast(pointer, EmPointer).nativePointer);
    }

    public function sizeOf(type:DataType):Int {
        return EmDataType.getSize(type);
    }

    public function getPointer(address:Int64):Pointer {
        return new EmPointer(module, address.low);
    }

    public function bytesToPointer(bytes:Bytes):Pointer {
        throw "Not implemented";
    }

    public function pointerToBytes(pointer:Pointer, count:Int):Bytes {
        throw "Not implemented";
    }
}
