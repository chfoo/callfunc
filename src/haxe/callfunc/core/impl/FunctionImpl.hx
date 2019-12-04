package callfunc.core.impl;

import haxe.io.Bytes;
import callfunc.core.impl.ExternDef;

class FunctionImpl implements FunctionHandle {
    final MAX_RETURN_SIZE = 8;
    final DEFAULT_ABI = -999;

    final _name:String;
    final _params:Array<DataType>;
    final _returnType:DataType;
    final _abi:Int;
    final nativePointer:ExternFunction;
    final _library:LibraryImpl;
    var buffer:Null<Bytes>;

    public function new(library:LibraryImpl, name:String,
            ?params:Array<DataType>, fixedParamCount:Int = -1,
            ?returnType:DataType, ?abi:Int) {
        _library = library;
        _name = name;
        _params = params = params != null ? params : [];
        _returnType = returnType = returnType != null ? returnType : DataType.Void;
        _abi = abi = abi != null ? abi : DEFAULT_ABI;

        nativePointer = ExternDef.newFunction(library.nativePointer);

        if (nativePointer == null) {
            throw "Failed to allocate function struct.";
        }

        var buffer = library.argSerializer.serializeParams(
            params, fixedParamCount, returnType);
        var pointer = cast(library.getPointer(name), PointerImpl);

        var error = ExternDef.functionDefine(nativePointer,
            pointer.nativePointer, abi, ContextImpl.bytesToBytesData(buffer));

        if (error != 0) {
            dispose();
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }
    }

    public function dispose() {
        ExternDef.delFunction(nativePointer);
    }

    public function call(?args:Array<Any>):Null<Any> {
        args = args != null ? args : [];

        if (args.length != _params.length) {
            throw "Function argument count mismatch";
        }

        buffer = _library.argSerializer.serializeArgs(_params, args, buffer);

        ExternDef.functionCall(nativePointer, ContextImpl.bytesToBytesData(buffer));

        if (_returnType != DataType.Void) {
            return _library.argSerializer.getReturnValue(buffer, _returnType);
        } else {
            return null;
        }
    }
}
