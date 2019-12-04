package callfunc.core;

/**
 * Handle to a libffi callback definition
 */
interface CallbackHandle extends Disposable {
    /**
     * Returns a function pointer which can be called by C code.
     */
    public function getPointer():BasicPointer;
}
