package callfunc.test;

import utest.Assert;
import utest.Test;

using callfunc.FunctionTools;
using callfunc.PointerTools;

class TestExamplelib extends Test {
    function getLibName() {
        #if js
        return "";
        #else
        switch Sys.systemName() {
            case "Windows":
                return "examplelib.dll";
            case "Mac":
                return "examplelib.dylib";
            default:
                return "examplelib.so";
        }
        #end
    }

    public function testNonexistentLibrary() {
        var callfunc = Callfunc.instance();
        Assert.raises(callfunc.newLibrary.bind("nonexistent-library-1234"));
    }

    public function testNonexistentFunction() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(getLibName());

        Assert.raises(library.newFunction.bind("nonexistent_function"));
        Assert.raises(library.newVariadicFunction.bind("nonexistent_function", [DataType.SInt], 1));

        library.dispose();
    }

    public function testInts() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(getLibName());

        var f1 = library.newFunction(
            "examplelib_ints",
            [DataType.SInt32, DataType.SInt32, DataType.Pointer],
            DataType.SInt32
        );

        var outputPointer = callfunc.memory.alloc(4);

        var result = f1.callVA(123, 456, outputPointer);

        Assert.equals(0xcafe, result);
        Assert.equals(579, outputPointer.get(DataType.SInt32));

        outputPointer.free();
        f1.dispose();
        library.dispose();
    }

    public function testString() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(getLibName());

        var f = library.newFunction(
            "examplelib_string",
            [DataType.Pointer],
            DataType.Pointer
        );

        var inputStringPointer = callfunc.memory.allocString("Hello world!");
        var result:Pointer = f.callVA(inputStringPointer);
        var resultString = result.getString();

        Assert.equals("HELLO WORLD!", resultString);

        result.free();
        inputStringPointer.free();
        f.dispose();
        library.dispose();
    }

    #if js
    @Ignored("emscripten-core/emscripten #5563 #5684")
    #end
    public function testVariadic() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(getLibName());

        var f = library.newVariadicFunction(
            "examplelib_variadic",
            [DataType.UInt, DataType.SInt32, DataType.SInt32],
            1,
            DataType.SInt32
        );

        var result = f.callVA(2, 123, 456);

        Assert.equals(579, result);
        f.dispose();
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

        function callback(a:Int, b:Int):Int {
            return a + b;
        }

        var callbackHandle = callfunc.newCallbackVA(
            callback,
            [DataType.SInt32, DataType.SInt32],
            DataType.SInt32);
        var callbackPointer = callbackHandle.getPointer();

        var result = f.callVA(callbackPointer);

        Assert.equals(123 + 456, result);

        f.dispose();
        library.dispose();
        callbackHandle.dispose();
    }

    public function testStructType() {
        var callfunc = Callfunc.instance();

        if (callfunc.memory.sizeOf(DataType.SInt) != 4) {
            Assert.warn("Skipping test because it doesn't seem to be x86");
            return;
        }

        var structType = callfunc.newStructType(
            [DataType.SChar, DataType.SInt]
        );

        Assert.equals(8, structType.size);
        Assert.same([0, 4], structType.offsets);

        structType.dispose();
    }

    #if js
    @Ignored("not supported")
    #end
    public function testStructPassByValue() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(getLibName());
        var structDataTypes = [DataType.UChar, DataType.SInt32, DataType.Double];
        var structType = callfunc.newStructType(structDataTypes);

        var f = library.newFunction(
            "examplelib_struct_value",
            [DataType.Struct(structDataTypes)],
            DataType.Struct(structDataTypes)
        );

        var inputStructPointer = callfunc.memory.alloc(structType.size);
        inputStructPointer.set(0x65, DataType.UChar, structType.offsets[0]);
        inputStructPointer.set(0x65, DataType.SInt32, structType.offsets[1]);
        inputStructPointer.set(123.456, DataType.Double, structType.offsets[2]);

        var result:Pointer = f.call([inputStructPointer]);

        Assert.equals(0x45, result.get(DataType.UChar, structType.offsets[0]));
        Assert.equals(0x45, result.get(DataType.SInt32, structType.offsets[1]));
        Assert.equals(246.912, result.get(DataType.Double, structType.offsets[2]));

        structType.dispose();
        f.dispose();
        library.dispose();
        inputStructPointer.free();
        result.free();
    }
}
