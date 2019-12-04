package callfunc;

import callfunc.core.Context;
import callfunc.core.CallbackHandle;

/**
 * Allows C code to call Haxe functions.
 */
class Callback implements Disposable {
    final callbackHandle:CallbackHandle;

    /**
     * A function pointer which can be called by C code.
     */
    public final pointer:Pointer;

    public function new(context:Context, callbackHandle:CallbackHandle) {
        this.callbackHandle = callbackHandle;
        pointer = new Pointer(context, callbackHandle.getPointer());
    }

    public function dispose() {
        callbackHandle.dispose();
    }
}
