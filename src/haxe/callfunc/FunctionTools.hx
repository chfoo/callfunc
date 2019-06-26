package callfunc;

import haxe.macro.Expr;

/**
 * Static extension for function methods.
 */
class FunctionTools {
    /**
     * Variadic (vararg) version of `Function.call`
     *
     * Allows calling the method directly with arguments instead of
     * passing an array of arguments.
     *
     * This method is implemented as a macro which means getting a function
     * reference or using `.bind` is not possible. Use
     * `FunctionTools.getCallable()` for this purpose.
     */
    public static macro function callVA(funcExpr:ExprOf<callfunc.Function>,
            extra:Array<Expr>) {
        var args = macro $a{extra};
        return macro $funcExpr.call($args);
    }

    /**
     * Returns a variadic (vararg) function that wraps `Function.call`.
     *
     * This returns a function that can be called with matching arguments
     * to the parameter definition. It automatically gathers the arguments
     * into an array for the `call` method.
     *
     * @return `(...)->Any`
     */
    public static function getCallable(funcHandle:callfunc.Function):Dynamic {
        return Reflect.makeVarArgs(cast funcHandle.call);
    }

    /**
     * Variadic (vararg) version of `Context.newCallback`
     *
     * It automatically creates a wrapped function so that the given
     * callback function does not need to accept arguments in a single array.
     *
     * @param haxeFunction `(...)->Any` A function accepting arguments matching
     *     the parameter definition in `params`.
     * @see `Context.newCallback` parameters and return type.
     */
    public static function newCallbackVA(context:Context,
            haxeFunction:haxe.Constraints.Function,
            ?params:Array<DataType>,
            ?returnType:DataType):Callback {

        @:nullSafety(Off)
        var wrappedCallback:Array<Any>->Any =
            (args:Array<Any>) -> Reflect.callMethod(null, haxeFunction, args);

        return context.newCallback(wrappedCallback, params, returnType);
    }
}
