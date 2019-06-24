package callfunc.impl;

class ContextImpl implements  Context {
    static final API_VERSION = 2;
    public var memory(get, never):Memory;

    final _memory:Memory;

    public function new() {
        var version = ExternDef.apiVersion();

        if (version != API_VERSION) {
            throw 'API version mismatch. Haxe: $API_VERSION, Native: $version';
        }

        _memory = newMemory();
    }

    function get_memory():Memory {
        return _memory;
    }

    function newMemory():Memory {
        #if (cpp || hl)
        return new callfunc.impl.MemoryImpl();
        #else
        throw "Not supported";
        #end
    }

    public function newLibrary(name:String):Library {
        #if (cpp || hl)
        return new callfunc.impl.LibraryImpl(name, memory);
        #else
        throw "Not supported";
        #end
    }

    public function newStructType(dataTypes:Array<DataType>):StructType {
        #if (cpp || hl)
        return new callfunc.impl.StructTypeImpl(dataTypes, memory);
        #else
        throw "Not supported";
        #end
    }

    public function newCallback(haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType):Callback {
        #if (cpp || hl)
        return new callfunc.impl.CallbackImpl(memory, haxeFunction, params,
            returnType);
        #else
        throw "Not supported";
        #end
    }
}
