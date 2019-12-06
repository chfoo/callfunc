package callfunc.test;

import utest.Assert;
import utest.Test;

class TestExamplelib extends Test {
    public static function getLibName() {
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
        Assert.raises(callfunc.openLibrary.bind("nonexistent-library-1234"));
    }

    public function testNonexistentFunction() {
        var callfunc = Callfunc.instance();
        var library = callfunc.openLibrary(getLibName());

        Assert.raises(library.define.bind("nonexistent_function"));
        Assert.raises(library.defineVariadic.bind("nonexistent_function", [DataType.SInt], 1));

        library.dispose();
    }

    public function testInts() {
        var callfunc = Callfunc.instance();
        var library = callfunc.openLibrary(getLibName());

        library.define(
            "examplelib_ints",
            [DataType.SInt32, DataType.SInt32, DataType.Pointer],
            DataType.SInt32
        );

        var outputPointer = callfunc.alloc(4);
        outputPointer.dataType = DataType.SInt32;

        var result = library.s.examplelib_ints.call(123, 456, outputPointer);

        Assert.equals(0xcafe, result);
        Assert.equals(579, outputPointer.get());

        result = library.s["examplelib_ints"].call(10, 20, outputPointer);
        Assert.equals(30, outputPointer.get());

        outputPointer.free();
        library.dispose();
    }

    public function testString() {
        var callfunc = Callfunc.instance();
        var library = callfunc.openLibrary(getLibName());

        library.define(
            "examplelib_string",
            [DataType.Pointer],
            DataType.Pointer
        );

        var inputStringPointer = callfunc.allocString("Hello world!");
        var result:Pointer = library.s.examplelib_string.call(inputStringPointer);
        var resultString = result.getString();

        Assert.equals("HELLO WORLD!", resultString);

        result.free();
        inputStringPointer.free();
        library.dispose();
    }

    public function testVariadic() {
        var callfunc = Callfunc.instance();
        var library = callfunc.openLibrary(getLibName());

        library.defineVariadic(
            "examplelib_variadic",
            [DataType.UInt, DataType.SInt32, DataType.SInt32],
            1,
            DataType.SInt32
        );
        library.defineVariadic(
            "examplelib_variadic",
            [DataType.UInt, DataType.SInt32, DataType.SInt32, DataType.SInt32],
            1,
            DataType.SInt32,
            "examplelib_variadic__2"
        );

        var result = library.s.examplelib_variadic.call(2, 123, 456);

        Assert.equals(579, result);

        result = library.s.examplelib_variadic__2.call(3, 123, 456, 789);

        Assert.equals(1368, result);

        library.dispose();
    }

    public function testCallback() {
        var callfunc = Callfunc.instance();
        var library = callfunc.openLibrary(getLibName());

        library.define(
            "examplelib_callback",
            [DataType.Pointer],
            DataType.SInt32
        );

        function callback(a:Int, b:Int):Int {
            return a + b;
        }

        var callbackHandle = callfunc.wrapCallback(
            callback,
            [DataType.SInt32, DataType.SInt32],
            DataType.SInt32);

        var result = library.s.examplelib_callback.call(callbackHandle.pointer);

        Assert.equals(123 + 456, result);

        library.dispose();
        callbackHandle.dispose();
    }

    public function testStructType() {
        var callfunc = Callfunc.instance();

        if (callfunc.sizeOf(DataType.SInt) != 4) {
            Assert.warn("Skipping test because it doesn't seem to be x86");
            return;
        }

        var structDef = callfunc.defineStruct(
            [DataType.SChar, DataType.SInt],
            ["a", "b"]
        );

        Assert.equals(8, structDef.size);
        Assert.same([0, 4], structDef.offsets);

        structDef.dispose();
    }

    #if js
    @Ignored("not supported")
    #end
    public function testStructPassByValue() {
        var callfunc = Callfunc.instance();
        var library = callfunc.openLibrary(getLibName());
        var structDataTypes = [DataType.UChar, DataType.SInt32, DataType.Double];
        var structDef = callfunc.defineStruct(structDataTypes, ["a", "b", "c"]);

        library.define(
            "examplelib_struct_value",
            [DataType.Struct(structDataTypes)],
            DataType.Struct(structDataTypes)
        );

        var inputStructPointer = callfunc.alloc(structDef.size);
        var inputStruct = structDef.access(inputStructPointer);
        inputStruct.a = 0x65;
        inputStruct.b = 0x65;
        inputStruct.c = 123.456;

        var result:Pointer = library.s.examplelib_struct_value.call(inputStructPointer);
        var resultStruct = structDef.access(result);

        Assert.equals(0x45, resultStruct.a);
        Assert.equals(0x45, resultStruct.b);
        Assert.equals(246.912, resultStruct.c);

        structDef.dispose();
        library.dispose();
        inputStructPointer.free();
        result.free();
    }
}
