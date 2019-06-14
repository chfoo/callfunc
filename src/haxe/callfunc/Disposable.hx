package callfunc;

/**
 * Classes that hold resources which can't be garbage collected automatically.
 */
interface Disposable {
    /**
     * Release any resources held by the instance.
     *
     * Calling any methods or properties, including `dispose()`, after this
     * method is undefined behavior.
     */
    public function dispose():Void;
}
