package callfunc.impl;

import haxe.io.Bytes;
import callfunc.impl.ExternDef;

class LibraryImpl implements Library {
    public final nativePointer:ExternLibrary;
    public final memory:Memory;
    public final argSerializer:ArgSerializer;

    public function new(name:String, memory:Memory) {
        nativePointer = ExternDef.newLibrary();
        this.memory = memory;

        argSerializer = new ArgSerializer(memory);

        if (nativePointer == null) {
            throw "Failed to allocate library struct.";
        }

        var error = ExternDef.libraryOpen(
            nativePointer,
            NativeUtil.toNativeString(name)
            );

        if (error != 0) {
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }
    }

    public function getSymbol(name:String):Pointer {
        @:nullSafety(Off) var targetPointer:ExternVoidStar = null;

        #if cpp
        var targetRef = cpp.RawPointer.addressOf(targetPointer);
        #elseif hl
        var targetRef = hl.Ref.make(targetPointer);
        #else
        #error
        #end

        var error = ExternDef.libraryGetAddress(
            nativePointer,
            NativeUtil.toNativeString(name),
            targetRef);

        if (error != 0) {
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }

        #if cpp
        return new PointerImpl(cpp.Pointer.fromRaw(targetPointer), memory);
        #else
        return new PointerImpl(targetPointer, memory);
        #end
    }


    public function newFunction(name:String, ?params:Array<DataType>,
            ?returnType:DataType):Function {
        return new FunctionImpl(this, name, params, returnType);
    }

    public function dispose() {
        ExternDef.libraryClose(nativePointer);
        ExternDef.delLibrary(nativePointer);
    }
}
