package curlexample;

import haxe.io.BytesBuffer;
import callfunc.AutoInt64;
import callfunc.Callfunc;
import callfunc.Pointer;
import haxe.io.Bytes;

using callfunc.FunctionTools;
using callfunc.PointerTools;

using haxe.Int64;

// This example shows how to interact with libcurl to download a web page.
// We have a Curl class that helps define types for some type safety.
class CurlExample {
    public static function main() {
        var context = Callfunc.instance();
        var curl = new Curl();

        curl.globalInit(Curl.GLOBAL_ALL);

        var handle = curl.easyInit();
        curl.easySetOptLong(handle, Curl.OPT_VERBOSE, 1);

        // Allocate a ASCII/UTF8 string on the heap, pass the pointer,
        // libcurl will copy the string, then we free it.
        var url = context.memory.allocString("https://haxe.org/");
        curl.easySetOptPointer(handle, Curl.OPT_URL, url);
        url.free();

        // This section below demonstrates how to use callback functions.
        //
        // Since size_t is dependent on the CPU, Callfunc will use either
        // Int or Int64. But we don't want to write two functions, so we
        // accept the largest size which is Int64. Callfunc provides AutoInt64
        // which automatically promotes an Int to Int64.
        //
        // We could use AutoInt to work on 32-bit integers, but it's legal
        // (but probably impossible) on 64-bit platform that libcurl can give
        // us a data chunk larger 2 GB. So instead truncating "count",
        // we AND the Int64 to properly compute how much we want to process.

        var receiveBuffer = new BytesBuffer();

        function writeCallback(buffer:Pointer, size:AutoInt64,
                count:AutoInt64):AutoInt64 {

            // size is guaranteed to be 1 byte from libcurl.
            // We choose an AND value that is guaranteed to not be negative
            // and won't lose data in 32/64-bit truncation and promotion.
            // 16 MB is more than enough as kernel receive sizes are near 4 KB.
            var processedCount = (size.toInt() * ((count:Int64) & 0xffffff)).toInt();
            var view = buffer.getDataView(processedCount);

            receiveBuffer.addBytes(view.buffer, view.byteOffset, view.byteLength);

            return processedCount;
        }

        var writeCallbackInfo = curl.newWriteFunction(writeCallback);
        curl.easySetOptPointer(handle, Curl.OPT_WRITE_FUNCTION,
            writeCallbackInfo.getPointer());

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
