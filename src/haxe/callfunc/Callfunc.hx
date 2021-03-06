package callfunc;

import callfunc.string.StringUtil;
import callfunc.string.Encoding;
import callfunc.core.Context;
import haxe.Int64;
import haxe.io.Bytes;

/**
 * Main class for interfacing with foreign functions.
 */
class Callfunc {
    static var _instance:Null<Callfunc>;
    public final context:Context;

    public function new(context:Context) {
        this.context = context;
    }

    /**
     * Returns a singleton instance.
     */
    public static function instance():Callfunc {
        if (_instance == null) {
            _instance = new Callfunc(
                #if (cpp || hl)
                new callfunc.core.impl.ContextImpl()
                #else
                new callfunc.core.dummy.DummyContext()
                #end
            );
        }

        return _instance;
    }

    /**
     * Replace the singleton instance with the given instance.
     * @param instance
     */
    public static function setInstance(instance:Callfunc) {
        _instance = instance;
    }

    /**
     * Allocates memory on the heap.
     *
     * This calls standard C `malloc()` or `calloc()`.
     *
     * @param size Number of bytes.
     * @param initZero Whether to initialize the array to 0.
     * @throws String Allocation failed.
     */
    public function alloc(size:Int, initZero:Bool = false):Pointer {
        return new Pointer(context, context.alloc(size, initZero));
    }

    /**
     * Returns the width of the data type.
     *
     * @return Number of bytes.
     */
    public function sizeOf(type:DataType):Int {
        return context.sizeOf(type);
    }

    /**
     * Returns a pointer from the given address.
     *
     * @param address An address in memory.
     */
    public function getPointer(address:Int64):Pointer {
        return new Pointer(context, context.getPointer(address));
    }

    /**
     * Returns C struct information from the given definition.
     *
     * The returned information then can be used to access pointers in an
     * easier manner.
     *
     * @param dataTypes Data types for each field of the struct.
     * @param names Name of each field.
     * @throws String An error message if the data type is invalid.
     */
    public function defineStruct(dataTypes:Array<DataType>, names:Array<String>):StructDef {
        return new StructDef(context.newStructType(dataTypes), names);
    }

    /**
     * Returns a library object to access a dynamic library's symbols.
     *
     * @param name A filename to the dynamic library as accepted by `dlopen()`
     *     or `LoadLibrary()` on Windows.
     * @throws String An error message if the library could not be found or
     *     any other error.
     */
    public function openLibrary(name:String):Library {
        return new Library(context, context.newLibrary(name));
    }

    /**
     * Returns a Callback instance for passing Haxe functions to C code.
     *
     * Availability depends on the libffi platform support for closures.
     *
     * @param haxeFunction Callback function to be wrapped which accepts the
     *      same number of arguments and returns the same data type as defined.
     * @param params Data types corresponding to the function parameters
     *     exposed to the C code.
     * @param returnType Data type of the return value of the exposed function.
     * @throws String An error message if the data type is invalid or any
     *     other error.
     */
    public function wrapCallback(
            haxeFunction:Dynamic,
            ?params:Array<DataType>,
            ?returnType:DataType):Callback {

        @:nullSafety(Off)
        var arrayArgCallback:Array<Any>->Any =
            (args:Array<Any>) -> Reflect.callMethod(null, haxeFunction, args);

        return wrapArrayCallback(arrayArgCallback, params, returnType);
    }

    /**
     * Returns a Callback instance for passing Haxe functions to C code.
     *
     * This is the implementation method which uses arrays for arguments.
     * `warpCallback` is the convenience method that accepts any function.
     *
     * @see `Callback.wrapCallback`
     */
    public function wrapArrayCallback(
            haxeFunction:Array<Any>->Any,
            ?params:Array<DataType>,
            ?returnType:DataType) {

        function argPointerWrapper(args:Array<Any>):Any {
            if (params != null) {
                for (index in 0...args.length) {
                    if (params[index] == DataType.Pointer) {
                        args[index] = new Pointer(context, args[index]);
                    }
                }
            }

            final result = haxeFunction(args);

            if (returnType == DataType.Pointer) {
                return Pointer.unwrap(returnType);
            } else {
                return result;
            }
        }

        final handle = context.newCallback(argPointerWrapper, params, returnType);
        return new Callback(context, handle);
    }

    #if sys
    /**
     * Exposes a pointer to the underlying C array of a Haxe `Bytes`.
     *
     * This method is used to share from a Haxe array to a C library.
     *
     * Care must be ensured that the `Bytes` instance has not been garbage
     * collected when using the pointer.
     *
     * This method is not portable across targets.
     *
     * @param bytes
     */
    public function bytesToPointer(bytes:Bytes):Pointer {
        return new Pointer(context, context.bytesToPointer(bytes));
    }
    #end

     /**
     * Converts a Haxe string to a new C string and returns its pointer.
     *
     * The C string will be encoded with the given encoding with a null
     * terminator.
     *
     * This is equivalent of determining the number of bytes in the encoded
     * string, allocating memory, and writing the encoded string with the
     * pointer.
     *
     * The caller is responsible for freeing the string.
     *
     * @param text String to be encoded,
     * @param encoding Encoding such as UTF-8.
     * @param terminator Whether to include a null-terminator.
     * @param lengthCallback A callback that accepts the number of bytes
     *     allocated
     */
    public function allocString(text:String,
            encoding:Encoding = UTF8,
            terminator:Bool = true,
            ?lengthCallback:Int->Void):Pointer {
        final length = StringUtil.getEncodedLength(text, encoding, terminator);
        final pointer = alloc(length, true);
        pointer.setString(text, encoding, terminator);

        if (lengthCallback != null) {
            lengthCallback(length);
        }

        return pointer;
    }
}
