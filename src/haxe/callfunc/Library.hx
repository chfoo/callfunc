package callfunc;

import callfunc.core.Context;
import callfunc.core.LibraryHandle;


/**
 * Loaded dynamic library symbols and functions.
 */
class Library implements Disposable {
    final context:Context;
    final libraryHandle:LibraryHandle;
    final functions:Map<String,Function>;

    /**
     * Array or field access to functions and symbols.
     *
     * This object allows accessing functions and symbols using the array
     * syntax or field access syntax.
     *
     * If the symbol name exists in the library, a `Function` will be created
     * automatically. It defaults to functions that accept no arguments and a
     * void return type. If previously defined using `define`, it will return
     * the previously defined function.
     *
     * Example accessing functions:
     *
     * - Array syntax: `myLibrary.s["myFunction"].call()`
     * - Field syntax: `myLibrary.s.myFunction.call()`
     *
     * Example getting a pointer:
     *
     * - Array syntax: `myLibrary.s["myFunction"].pointer()`
     * - Field syntax: `myLibrary.s.myFunction.pointer()`
     */
    public final s:LibrarySymbolAccess;

    public function new(context:Context, libraryHandle:LibraryHandle) {
        this.context = context;
        this.libraryHandle = libraryHandle;
        functions = [];
        s = this;
    }

    /**
     * Returns whether the given symbol name is in the library's symbol table.
     */
    public function hasSymbol(name:String):Bool {
        return libraryHandle.hasSymbol(name);
    }

    /**
     * Defines a C function's signature.
     *
     * @param name Function's symbol name.
     * @param params Data types corresponding to the function parameters.
     *     If the function does not accept arguments, specify `null` or empty
     *     array.
     * @param returnType Data type of the return value. If the function does
     *     not return a value. Specify `null` or `DataType.Void`.
     * @param alias Name used to access this function. If not provided, it
     *     defaults to the function's name.
     * @param abi If supported by the platform and target, an ABI calling
     *     method matching `enum ffi_abi` defined in `ffitarget.h`.
     *
     * @see `Library.defineVariadic` for C variadic functions.
     */
    public function define(name:String, ?params:Array<DataType>,
            ?returnType:DataType, ?alias:String, ?abi:Int):Function {
        return addNewFunction(name, params, returnType, alias, abi);
    }

    /**
     * Defines a variadic C function.
     *
     * When calling variadic functions, the number of arguments must match
     * the number of parameters in the definition. As such, a separate
     * definition must be made for the same function if the number of arguments
     * is different. Use `alias` to give each definition a different name.
     *
     * @param name Function's symbol name.
     * @param params Data types corresponding to the function parameters.
     * @param fixedParamCount Number of parameters that are fixed (not variadic)
     *     at the start of the parameters list.
     * @param returnType Data type of the return value.
     * @param alias Name used to access this function. If not provided, it
     *     defaults to the function's name.
     * @param abi ABI calling method.
     *
     * @see `Library.define` for full parameter documentation.
     */
    public function defineVariadic(name:String, params:Array<DataType>,
            fixedParamCount:Int, ?returnType:DataType,
            ?alias:String, ?abi:Int):Function {
        return addNewFunction(name, params, fixedParamCount, returnType, alias, abi);
    }

    function addNewFunction(name:String, ?params:Array<DataType>,
            ?fixedParamCount:Int, ?returnType:DataType,
            ?alias:String, ?abi:Int):Function {
        final key = alias != null ? alias : name;

        if (functions.exists(key)) {
            throw "Function is already defined";
        }

        if (!hasSymbol(name)) {
            throw "Symbol not in library";
        }

        final func = new Function(name, context, this, libraryHandle);

        if (params != null) {
            func.params = params;
        }

        if (returnType != null) {
            func.returnType = returnType;
        }

        if (fixedParamCount != null) {
            func.fixedParamCount = Some(fixedParamCount);
        }

        if (abi != null) {
            func.abi = Some(abi);
        }

        functions.set(key, func);

        return func;
    }

    /**
     * Returns a function from the given name.
     *
     * @param name Function symbol name or alias name.
     * @return If the function has been previously defined with `Library.define`,
     *      it will return the previously function. Otherwise, a new `Function`
     *      will be created.
     */
    public function get(name:String):Function {
        final func = functions.get(name);

        if (func != null) {
            return func;
        } else {
            return addNewFunction(name);
        }
    }

    /**
     * Removes a previously defined function, disposing it if necessary.
     *
     * @param name Function symbol name or alias name.
     */
    public function undefine(name:String) {
        final func = functions.get(name);

        if (func != null) {
            func.dispose();
            functions.remove(name);
        }
    }

    /**
     * Dispose all functions.
     */
    public function dispose() {
        for (func in functions) {
            func.dispose();
        }

        functions.clear();
    }
}


abstract LibrarySymbolAccess(Library) from Library {
    @:arrayAccess @:op(a.b)
    inline function get(name:String) {
        return this.get(name);
    }
}
