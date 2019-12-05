package callfunc;

import callfunc.core.Context;
import callfunc.core.FunctionHandle;
import callfunc.core.LibraryHandle;
import haxe.ds.Option;

/**
 * Represents a symbol in an opened dynamic library.
 */
class Function {
    /**
     * Library of which this function belongs to.
     */
    public final library:Library;

    final libraryHandle:LibraryHandle;
    final context:Context;
    var functionHandle:Null<FunctionHandle>;

    /**
     * Symbol name of the function.
     */
    public final name:String;

    /**
     * Data types of the function parameters.
     *
     * If the function accepts no parameters, it is an empty array.
     */
    public var params(get, set):Array<DataType>;
    var _params:Array<DataType>;

    /**
     * Data type of the return value.
     *
     * If the function has no return value, `DataType.Void` is used.
     */
    public var returnType(get, set):DataType;
    var _returnType:DataType;

    /**
     * If a variadic C function, the number of fixed parameters.
     */
    public var fixedParamCount(get, set):Option<Int>;
    var _fixedParamCount:Option<Int>;

    /**
     * If supported, the libffi ABI function type.
     */
    public var abi(get, set):Option<Int>;
    var _abi:Option<Int>;

    /**
     * Executes function in the library.
     *
     * This method is a variadic version of `arrayCall`. This method is
     * provided as convenience and should be used in most cases.
     *
     * Example: `myLibrary.s.myFunction.call(a, b, c);`
     *
     * @see `Function.arrayCall` for description of function behavior.
     */
    public final call:Dynamic;

    public function new(name:String, context:Context, library:Library, libraryHandle:LibraryHandle) {
        this.name = name;
        this.context = context;
        this.library = library;
        this.libraryHandle = libraryHandle;
        _params = [];
        _returnType = DataType.Void;
        _fixedParamCount = Option.None;
        _abi = Option.None;
        call = Reflect.makeVarArgs(cast arrayCall);
    }

    function get_params():Array<DataType> {
        return _params;
    }

    function set_params(value:Array<DataType>):Array<DataType> {
        if (value != _params) {
            reset();
        }

        return _params = value;
    }

    function get_returnType():DataType {
        return _returnType;
    }

    function set_returnType(value:DataType):DataType {
        if (value != _returnType) {
            reset();
        }

        return _returnType = value;
    }

    function get_fixedParamCount():Option<Int> {
        return _fixedParamCount;
    }

    function set_fixedParamCount(value:Option<Int>):Option<Int> {
        if (!value.equals(_fixedParamCount)) {
            reset();
        }

        return _fixedParamCount = value;
    }

    function get_abi():Option<Int> {
        return _abi;
    }

    function set_abi(value:Option<Int>):Option<Int> {
        if (!value.equals(_abi)) {
            reset();
        }

        return _abi = value;
    }

    /**
     * Returns a pointer to the symbol in the library.
     *
     * If the symbol is not a function, do not define any function parameters
     * or return type. Simply use this method.
     *
     * @throws String An error message if the symbol was not found or any
     *     other error.
     */
    public function pointer():Pointer {
        return new Pointer(context, libraryHandle.getPointer(name));
    }

    /**
     * Executes the function with the given array of arguments.
     *
     * (Internally, this is the implementation method. `call` is the
     * convenience method.)
     *
     * @param args Arguments that correspond the parameter data types.
     *     Arguments can be `Int`, `haxe.io.Int64`, `Float`, or `Pointer`.
     *     Numeric types will be promoted and casted
     *     (with possible truncation or loss of precision) appropriately.
     * @return If `returnType` is not `DataType.Void`, the return value
     *     will be converted to either `Int`, `haxe.io.Int64`, `Float`, or
     *     `Pointer`.
     *
     *     Integer data types that fit within 32 bits will be
     *     promoted to `Int` while wider integers will be promoted
     *     to `haxe.io.Int64`.
     *
     *     If `returnType` is `DataType.Struct`, the return value will be
     *     a `Pointer` which the caller should free.
     *
     * @throws String An error message if the argument list is invalid (such
     *     as wrong size or wrong type.
     *
     * @see `Function.call` for easier function call.
     */
    public function arrayCall(?args:Array<Any>):Any {
        if (functionHandle == null) {
            var abi:Null<Int>;

            switch _abi {
                case Some(abi_):
                    abi = abi_;
                case None:
                    abi = null;
            }


            switch _fixedParamCount {
                case None:
                    functionHandle = libraryHandle.newFunction(name, _params, _returnType, abi);
                case Some(fixedParamCount):
                    functionHandle = libraryHandle.newVariadicFunction(name, _params, fixedParamCount, _returnType, abi);
            }
        }

        if (args != null) {
            final numArgs = args.length;
            for (index in 0...numArgs) {
                args[index] = Pointer.unwrap(args[index]);
            }
        }

        final returnValue = functionHandle.call(args);

        return Pointer.wrap(returnValue, context);
    }

    function reset() {
        if (functionHandle != null) {
            functionHandle.dispose();
            functionHandle = null;
        }
    }

    @:allow(callfunc.Library)
    function dispose() {
        if (functionHandle != null) {
            functionHandle.dispose();
        }
    }
}
