package callfunc.impl;

import haxe.io.Bytes;
import callfunc.impl.ExternDef;

class FunctionImpl implements Function {
    final MAX_RETURN_SIZE = 8;
    final DEFAULT_ABI = -999;

    public var name(get, never):String;
    public var params(get, never):Array<DataType>;
    public var returnType(get, never):DataType;

    final _name:String;
    final _params:Array<DataType>;
    final _returnType:DataType;
    final _abi:Int;
    final nativePointer:ExternFunction;
    final library:LibraryImpl;
    var buffer:Null<Bytes>;

    public function new(library:LibraryImpl, name:String,
            ?params:Array<DataType>, fixedParamCount:Int = -1,
            ?returnType:DataType, ?abi:Int) {
        params = params != null ? params : [];
        returnType = returnType != null ? returnType : DataType.Void;
        abi = abi != null ? abi : DEFAULT_ABI;

        this.library = library;
        _name = name;
        _params = params;
        _returnType = returnType;
        _abi = abi;

        nativePointer = ExternDef.newFunction(library.nativePointer);

        if (nativePointer == null) {
            throw "Failed to allocate function struct.";
        }

        var buffer = library.argSerializer.serializeParams(
            params, fixedParamCount, returnType);
        var pointer = cast(library.getSymbol(name), PointerImpl);

        var error = ExternDef.functionDefine(nativePointer,
            pointer.nativePointer, abi, MemoryImpl.bytesToBytesData(buffer));

        if (error != 0) {
            throw NativeUtil.fromNativeString(ExternDef.getErrorMessage());
        }
    }

    function get_name():String {
        return _name;
    }

    function get_params():Array<DataType> {
        return _params;
    }

    function get_returnType():DataType {
        return _returnType;
    }

    public function dispose() {
        ExternDef.delFunction(nativePointer);
    }

    public function call(?args:Array<Any>):Null<Any> {
        args = args != null ? args : [];

        if (args.length != _params.length) {
            throw "Function argument count mismatch";
        }

        buffer = library.argSerializer.serializeArgs(_params, args, buffer);

        ExternDef.functionCall(nativePointer, MemoryImpl.bytesToBytesData(buffer));

        if (_returnType != DataType.Void) {
            return library.argSerializer.getReturnValue(buffer, _returnType);
        } else {
            return null;
        }
    }
}
