package callfunc.emscripten;

import haxe.io.ArrayBufferView;
import haxe.io.Bytes;
import haxe.Int64;

using callfunc.emscripten.ModuleTools;

class EmMemory implements Memory {
    final context:EmContext;

    public function new(context:EmContext) {
        this.context = context;
    }

    public function alloc(size:Int, initZero:Bool = false):Pointer {
        if (initZero) {
            return new EmPointer(context, context.module.getSymbol("calloc")(size, 1));
        } else {
            return new EmPointer(context, context.module.getSymbol("malloc")(size));
        }
    }

    public function free(pointer:Pointer) {
        context.module.getSymbol("free")(cast(pointer, EmPointer).nativePointer);
    }

    public function sizeOf(type:DataType):Int {
        return EmDataType.getSize(type);
    }

    public function getPointer(address:Int64):Pointer {
        return new EmPointer(context, address.low);
    }

    public function pointerToDataView(pointer:Pointer,count:Int):DataView {
        var nativePointer = cast(pointer, EmPointer).nativePointer;
        var bytes = Bytes.ofData(context.module.HEAPU8.buffer);
        return new BytesDataView(bytes, nativePointer, count);
    }
}
