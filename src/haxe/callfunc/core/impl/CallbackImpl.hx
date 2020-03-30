package callfunc.core.impl;

import callfunc.core.impl.ExternDef.ExternCallback;
import callfunc.core.serialization.ArgSerializer;
import haxe.io.Bytes;

class CallbackImpl implements CallbackHandle {
    final nativePointer:ExternCallback;
    final context:ContextImpl;
    final argSerializer:ArgSerializer;
    final argBuffer:Bytes;
    final haxeFunction:Array<Any>->Any;
    final params:Array<DataType>;
    final returnType:DataType;
    final handlerRef:Void->Void;

    public function new(context:ContextImpl, haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>, ?returnType:DataType) {
        this.context = context;
        this.haxeFunction = haxeFunction;

        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;

        this.params = params;
        this.returnType = returnType;

        argSerializer = new ArgSerializer(context);
        argBuffer = Bytes.alloc(argSerializer.getArgBufferLength(params));
        argBuffer.setInt32(0, argBuffer.length);

        nativePointer = ExternDef.newCallback();

        if (nativePointer == null) {
            throw "Failed to allocate callback struct.";
        }

        var paramBuffer = argSerializer.serializeParams(params, returnType);
        var error = ExternDef.callbackDefine(nativePointer,
            ContextImpl.bytesToBytesData(paramBuffer));

        if (error != 0) {
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }

        // Create a dynamic and keep it from being garbage collected:
        handlerRef = handler;

        error = ExternDef.callbackBind(nativePointer,
            ContextImpl.bytesToBytesData(argBuffer), handlerRef);

        if (error != 0) {
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }
    }

    public function getPointer():BasicPointer {
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
