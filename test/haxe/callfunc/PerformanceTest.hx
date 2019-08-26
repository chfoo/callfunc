package callfunc;

import callfunc.test.TestExamplelib;

using callfunc.FunctionTools;
using callfunc.PointerTools;

class PerformanceTest {
    public static function run() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(TestExamplelib.getLibName());

        var libIntFunc = library.newFunction(
            "examplelib_ints",
            [DataType.SInt32, DataType.SInt32, DataType.Pointer],
            DataType.SInt32
        );
        var libCallbackFunc = library.newFunction(
            "examplelib_callback",
            [DataType.Pointer],
            DataType.SInt32
        );

        var outputPointer = callfunc.memory.alloc(4);
        outputPointer.dataType = DataType.SInt32;

        for (x in 0...1000) {
            for (y in 0...100) {
                libIntFunc.callVA(x, y, outputPointer);
                outputPointer.get();
                outputPointer.arrayGet(0);
            }
        }

        function callback(a:Int, b:Int):Int {
            return a + b;
        }

        var callbackHandle = callfunc.newCallbackVA(
            callback,
            [DataType.SInt32, DataType.SInt32],
            DataType.SInt32);
        var callbackPointer = callbackHandle.getPointer();

        for (trial in 0...10000) {
            libCallbackFunc.callVA(callbackPointer);
        }

        outputPointer.free();
        libIntFunc.dispose();
        libCallbackFunc.dispose();
        library.dispose();
    }
}
