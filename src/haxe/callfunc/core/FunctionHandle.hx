package callfunc.core;

/**
 * A handle to a function in a dynamic library.
 */
interface FunctionHandle extends Disposable {
    /**
     * Execute the function.
     *
     * @see `Function.arrayCall`
     */
    public function call(?args:Array<Any>):Any;
}
