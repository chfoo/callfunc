package callfunc;

import callfunc.test.TestExamplelib;

class PerformanceTest {
    public static function main() {
        var ffi = Callfunc.instance();
        var library = ffi.openLibrary(TestExamplelib.getLibName());

        library.define(
            "examplelib_ints",
            [DataType.SInt32, DataType.SInt32, DataType.Pointer],
            DataType.SInt32
        );
        library.define(
            "examplelib_callback",
            [DataType.Pointer],
            DataType.SInt32
        );

        var outputPointer = ffi.alloc(4);
        outputPointer.dataType = DataType.SInt32;

        for (x in 0...1000) {
            for (y in 0...100) {
                library.s.examplelib_ints.call(x, y, outputPointer);
                outputPointer.get();
                outputPointer.arrayGet(0);
            }
        }

        function callback(a:Int, b:Int):Int {
            return a + b;
        }

        var callbackHandle = ffi.wrapCallback(
            callback,
            [DataType.SInt32, DataType.SInt32],
            DataType.SInt32);

        for (trial in 0...10000) {
            library.s.examplelib_callback.call(callbackHandle.pointer);
        }

        outputPointer.free();
        library.dispose();
        callbackHandle.dispose();
    }
}
