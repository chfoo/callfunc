package callfunc.test;

import utest.Assert;
import utest.Test;

class TestExamplelib extends Test {
    function getLibName() {
        switch Sys.systemName() {
            case "Windows":
                return "examplelib.dll";
            case "Mac":
                return "examplelib.dylib";
            default:
                return "examplelib.so";
        }
    }

    public function testf1() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(getLibName());

        var f1 = library.newFunction(
            "examplelib_f1",
            [DataType.SInt32, DataType.SInt32, DataType.Pointer],
            DataType.SInt32
        );

        var outputPointer = callfunc.memory.alloc(4);

        var result = f1.call([123, 456, outputPointer]);

        Assert.equals(0xcafe, result);
        Assert.equals(579, outputPointer.get(DataType.SInt32));

        callfunc.memory.free(outputPointer);
        f1.dispose();
        library.dispose();
    }

    public function testCallback() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(getLibName());

        var f = library.newFunction(
            "examplelib_callback",
            [DataType.Pointer],
            DataType.SInt32
        );

        function callback(args:Array<Any>):Any {
            var a:Int = args[0];
            var b:Int = args[1];

            return a + b;
        }

        var callbackWrapper = callfunc.newCallback(
            callback,
            [DataType.SInt32, DataType.SInt32],
            DataType.SInt32);
        var callbackPointer = callbackWrapper.getPointer();

        var result = f.call([callbackPointer]);

        Assert.equals(123 + 456, result);

        f.dispose();
        library.dispose();
        callbackWrapper.dispose();
    }
}
