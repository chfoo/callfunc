package curlexample;

import callfunc.Function;
import callfunc.AutoInt64;
import callfunc.Callback;
import callfunc.Callfunc;
import callfunc.Context;
import callfunc.DataType;
import callfunc.Library;
import callfunc.Pointer;

using callfunc.FunctionTools;
using callfunc.PointerTools;

// This class provides a few methods to the libcurl C functions.
// It demonstrates how to convert Dynamic functions into typed functions.
// In a real libcurl binding, you would wrap most of libcurl functionality
// into object oriented manner.

typedef CurlWriteFunction = (buffer:Pointer, size:AutoInt64, count:AutoInt64)->AutoInt64;

class Curl {
    // Constants from libcurl header file
    public static final GLOBAL_SSL = 1 << 0;
    public static final GLOBAL_WIN32 = 1 << 1;
    public static final GLOBAL_ALL = GLOBAL_SSL | GLOBAL_WIN32;
    public static final OPT_URL = 10000 + 2;
    public static final OPT_VERBOSE = 0 + 41;
    public static final OPT_WRITE_FUNCTION = 20000 + 11;

    // Functions available for calling
    public final globalInit:Int->Void;
    public final globalCleanup:Void->Void;
    public final easyInit:Void->Pointer;
    public final easySetOptPointer:(Pointer, Int, Pointer)->Int;
    public final easySetOptLong:(Pointer, Int, Int)->Int;
    public final easyPerform:Pointer->Int;

    final context:Context;
    final library:Library;
    final functionHandles:Array<Function>;

    public function new() {
        context = Callfunc.instance();
        library = context.newLibrary(getLibraryName());
        functionHandles = [];

        globalInit = newFunction(
            "curl_global_init",
            [DataType.SInt]
        );
        globalCleanup = newFunction(
            "curl_global_cleanup"
        );
        easyInit = newFunction(
            "curl_easy_init",
            [],
            DataType.Pointer
        );
        easySetOptPointer = newFunction(
            "curl_easy_setopt",
            [DataType.Pointer, DataType.SInt, DataType.Pointer],
            DataType.SInt
        );
        easySetOptLong = newFunction(
            "curl_easy_setopt",
            [DataType.Pointer, DataType.SInt, DataType.SLong],
            DataType.SInt
        );
        easyPerform = newFunction(
            "curl_easy_perform",
            [DataType.Pointer],
            DataType.SInt
        );
    }

    function getLibraryName():String {
        switch Sys.systemName() {
            case "Windows":
                return "libcurl.dll";
            case "Mac":
                return "libcurl.dylib";
            default:
                return "libcurl.so";
        }
    }

    // A convenience function for reducing clutter above
    function newFunction(name, ?params, ?returnType):Dynamic {
        var functionHandle = library.newFunction(name, params, returnType);
        functionHandles.push(functionHandle);

        return functionHandle.getCallable();
    }

    public function newWriteFunction(callback:CurlWriteFunction):Callback {
        var handle = context.newCallbackVA(
            callback,
            [DataType.Pointer, DataType.Size, DataType.Size, DataType.Pointer],
            DataType.Size
        );

        return handle;
    }

    public function dispose() {
        for (handle in functionHandles) {
            handle.dispose();
        }
        library.dispose();
    }
}
