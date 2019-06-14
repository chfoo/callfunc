package callfunc.impl;

import haxe.io.Bytes;
import callfunc.impl.ExternDef;

class FunctionImpl implements Function {
    final MAX_RETURN_SIZE = 8;

    public var name(get, never):String;
    public var params(get, never):Array<DataType>;
    public var returnType(get, never):Null<DataType>;

    final _name:String;
    final _params:Array<DataType>;
    final _returnType:DataType;
    final nativePointer:ExternFunction;
    final library:LibraryImpl;
    var buffer:Null<Bytes>;

    public function new(library:LibraryImpl, name:String,
            ?params:Array<DataType>, ?returnType:DataType) {
        nativePointer = ExternDef.newFunction(library.nativePointer);
        this.library = library;
        _name = name;
        params = params != null ? params : [];
        _params = params;
        returnType = returnType != null ? returnType : DataType.Void;
        _returnType = returnType;

        if (nativePointer == null) {
            throw "Failed to allocate function struct.";
        }

        @:nullSafety(Off) var targetPointer:ExternVoidStar = null;

        #if cpp
        var targetRef = cpp.RawPointer.addressOf(targetPointer);
        #elseif hl
        var targetRef = hl.Ref.make(targetPointer);
        #else
        #error
        #end

        var error = ExternDef.libraryGetAddress(
            library.nativePointer,
            #if hl
            Bytes.ofString(name)
            #else
            name
            #end,
            targetRef);

        if (error != 0) {
            throw ExternDef.getErrorMessage();
        }

        var buffer = library.argSerializer.serializeParams(params, returnType);

        error = ExternDef.functionDefine(nativePointer,
            targetPointer, MemoryImpl.bytesToBytesData(buffer));
    }

    function get_name():String {
        return _name;
    }

    function get_params():Array<DataType> {
        return _params;
    }

    function get_returnType():Null<DataType> {
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
