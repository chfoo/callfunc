package curlexample;

import callfunc.Function;
import callfunc.AutoInt64;
import callfunc.Callback;
import callfunc.Callfunc;
import callfunc.DataType;
import callfunc.Library;
import callfunc.Pointer;

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

    final callfunc:Callfunc;
    final library:Library;

    public function new() {
        callfunc = Callfunc.instance();
        library = callfunc.openLibrary(getLibraryName());

        globalInit = library.define(
            "curl_global_init",
            [DataType.SInt]
        ).call;
        globalCleanup = library.define(
            "curl_global_cleanup"
        ).call;
        easyInit = library.define(
            "curl_easy_init",
            [],
            DataType.Pointer
        ).call;
        easySetOptPointer = library.defineVariadic(
            "curl_easy_setopt",
            [DataType.Pointer, DataType.SInt, DataType.Pointer],
            2,
            DataType.SInt,
            "curl_easy_setopt:pointer"
        ).call;
        easySetOptLong = library.defineVariadic(
            "curl_easy_setopt",
            [DataType.Pointer, DataType.SInt, DataType.SLong],
            2,
            DataType.SInt,
            "curl_easy_setopt:long"
        ).call;
        easyPerform = library.define(
            "curl_easy_perform",
            [DataType.Pointer],
            DataType.SInt
        ).call;
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

    public function newWriteFunction(callback:CurlWriteFunction):Callback {
        var handle = callfunc.wrapCallback(
            callback,
            [DataType.Pointer, DataType.Size, DataType.Size, DataType.Pointer],
            DataType.Size
        );

        return handle;
    }

    public function dispose() {
        library.dispose();
    }
}
