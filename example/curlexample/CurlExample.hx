package curlexample;

import callfunc.AnyInt;
import callfunc.Callfunc;
import callfunc.Pointer;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

using haxe.Int64;

// This example shows how to interact with libcurl to download a web page.
// We have a Curl class that helps define types for some type safety.
class CurlExample {
    public static function main() {
        var callfunc = Callfunc.instance();
        var curl = new Curl();

        curl.globalInit(Curl.GLOBAL_ALL);

        var handle = curl.easyInit();
        curl.easySetOptLong(handle, Curl.OPT_VERBOSE, 1);

        // Allocate a ASCII/UTF8 string on the heap, pass the pointer,
        // libcurl will copy the string, then we free it.
        var url = callfunc.allocString("https://haxe.org/");
        curl.easySetOptPointer(handle, Curl.OPT_URL, url);
        url.free();

        // This section below demonstrates how to use callback functions.
        //
        // Since size_t is dependent on the CPU, Callfunc will use either
        // Int or Int64. But we don't want to write two functions, so we
        // accept Int64 but return Int. Callfunc provides AnyInt
        // which is an abstract over the Dynamic type. It provides methods
        // for checking the type at runtime and converting as needed.

        var receiveBuffer = new BytesBuffer();

        function writeCallback(buffer:Pointer, size:AnyInt,
                count:AnyInt):Int {

            // size is guaranteed to be 1 byte from libcurl.
            // We choose an AND value that is guaranteed to not be negative
            // and won't lose data in 32/64-bit truncation and promotion.
            // 16 MB is more than enough as kernel receive sizes are near 4 KB.
            var processedCount = (size.toInt64() * (count.toInt64() & 0xffffff)).toInt();
            var view = buffer.getDataView(processedCount);

            receiveBuffer.addBytes(view.buffer, view.byteOffset, view.byteLength);

            return processedCount;
        }

        var writeCallbackInfo = curl.newWriteFunction(writeCallback);
        curl.easySetOptPointer(handle, Curl.OPT_WRITE_FUNCTION,
            writeCallbackInfo.pointer);

        // Make libcurl do things
        var error = curl.easyPerform(handle);
        var receivedBytes = receiveBuffer.getBytes();

        writeCallbackInfo.dispose();

        // Print out some info
        trace('Perform error: $error');
        trace('Got ${receivedBytes.length} byte(s)');
        trace('   ${receivedBytes.sub(0, 100)}');

        // Delete the library and function handles.
        // Normally this isn't necessary in an application as you want to
        // keep functions around and use them repeatedly.
        curl.globalCleanup();
        curl.dispose();
    }
}
