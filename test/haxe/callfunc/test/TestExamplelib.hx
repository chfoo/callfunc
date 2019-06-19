package callfunc.test;

import utest.Assert;
import utest.Test;

class TestExamplelib extends Test {
    public function testf1() {
        var callfunc = Callfunc.instance();

        var libName;

        switch Sys.systemName() {
            case "Windows":
                libName = "examplelib.dll";
            case "Mac":
                libName = "examplelib.dylib";
            default:
                libName = "examplelib.so";
        }

        var library = callfunc.newLibrary(libName);

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
}
