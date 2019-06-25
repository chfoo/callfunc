package callfunc.impl;

import callfunc.impl.ExternDef.ExternCallback;
import haxe.io.Bytes;

class CallbackImpl implements Callback {
    final nativePointer:ExternCallback;
    final context:ContextImpl;
    final argSerializer:ArgSerializer;
    final argBuffer:Bytes;
    final haxeFunction:Array<Any>->Any;
    final params:Array<DataType>;
    final returnType:DataType;

    public function new(context:ContextImpl, haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>, ?returnType:DataType) {
        this.context = context;
        this.haxeFunction = haxeFunction;

        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;

        this.params = params;
        this.returnType = returnType;

        argSerializer = new ArgSerializer(context.memory);
        argBuffer = Bytes.alloc(argSerializer.getArgBufferLength(params));

        nativePointer = ExternDef.newCallback();

        if (nativePointer == null) {
            throw "Failed to allocate callback struct.";
        }

        var paramBuffer = argSerializer.serializeParams(params, returnType);
        var error = ExternDef.callbackDefine(nativePointer,
            MemoryImpl.bytesToBytesData(paramBuffer));

        if (error != 0) {
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }

        error = ExternDef.callbackBind(nativePointer,
            MemoryImpl.bytesToBytesData(argBuffer), handler);

        if (error != 0) {
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }
    }

    public function getPointer():Pointer {
        var nativeCallbackPointer = ExternDef.callbackGetPointer(nativePointer);

        return new PointerImpl(
            #if cpp
            cpp.Pointer.fromRaw(nativeCallbackPointer)
            #else
            nativeCallbackPointer
            #end
            , context);
    }

    public function dispose() {
        ExternDef.delCallback(nativePointer);
    }

    function handler() {
        var args = argSerializer.deserializeArgs(params, argBuffer);
        var returnValue = haxeFunction(args);

        if (returnType != DataType.Void) {
            argSerializer.setReturnValue(argBuffer, returnType, returnValue);
        }
    }
}
