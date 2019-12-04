package callfunc.core.emscripten;

import haxe.Int64;
import haxe.io.Bytes;

using callfunc.core.emscripten.ModuleTools;

class EmContext implements Context {
    @:allow(callfunc.core.emscripten)
    final module:EmscriptenModule;

    public function new(module:EmscriptenModule) {
        this.module = module;
    }

    public function alloc(size:Int, initZero:Bool = false):BasicPointer {
        var rawPointer;

        if (initZero) {
            rawPointer = module.getSymbol("calloc")(size, 1);

        } else {
            rawPointer = module.getSymbol("malloc")(size);
        }

        if (rawPointer == 0) {
            throw "Alloc failed";
        }

        return new EmPointer(this, rawPointer);
    }

    public function free(pointer:BasicPointer) {
        module.getSymbol("free")(cast(pointer, EmPointer).nativePointer);
    }

    public function sizeOf(type:DataType):Int {
        return EmDataType.getSize(type);
    }

    public function getPointer(address:Int64):BasicPointer {
        return new EmPointer(this, address.low);
    }

    public function pointerToDataView(pointer:BasicPointer, count:Int):DataView {
        var nativePointer = cast(pointer, EmPointer).nativePointer;
        var bytes = Bytes.ofData(module.HEAPU8.buffer);
        return new BytesDataView(bytes, nativePointer, count);
    }

    public function newLibrary(name:String):LibraryHandle {
        if (name != "") {
            throw "Library name cannot be specified. Only empty string \"\" is supported.";
        }

        return new EmLibrary(this);
    }

    public function newStructType(dataTypes:Array<DataType>):StructTypeHandle {
        return new EmStructType(dataTypes);
    }

    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):CallbackHandle {
        return new EmCallback(this, haxeFunction, params, returnType);
    }
}
