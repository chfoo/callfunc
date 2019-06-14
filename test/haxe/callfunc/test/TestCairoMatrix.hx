package callfunc.test;

import utest.Assert;

class TestCairoMatrix extends utest.Test {
    public function testMatrixScale() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary("libcairo.so");

        var initIdentityFunc = library.newFunction(
            "cairo_matrix_init_identity",
            [DataType.Pointer]
        );

        var scaleFunc = library.newFunction(
            "cairo_matrix_scale",
            [DataType.Pointer, DataType.Double, DataType.Double]
        );

        var transformPointFunc = library.newFunction(
            "cairo_matrix_transform_point",
            [DataType.Pointer, DataType.Pointer, DataType.Pointer]
        );

        var matrixStructType = callfunc.newStructType(
            [DataType.Double, DataType.Double, DataType.Double,
            DataType.Double, DataType.Double, DataType.Double]
        );

        Assert.isTrue(matrixStructType.size >= 8 * 6);

        var matrixPointer = callfunc.memory.alloc(matrixStructType.size);

        var i = matrixPointer.address;

        initIdentityFunc.call([matrixPointer]);

        Assert.equals(1.0, matrixPointer.get(DataType.Double, matrixStructType.offsets[0]));
        Assert.equals(0.0, matrixPointer.get(DataType.Double, matrixStructType.offsets[1]));
        Assert.equals(0.0, matrixPointer.get(DataType.Double, matrixStructType.offsets[2]));
        Assert.equals(1.0, matrixPointer.get(DataType.Double, matrixStructType.offsets[3]));
        Assert.equals(0.0, matrixPointer.get(DataType.Double, matrixStructType.offsets[4]));
        Assert.equals(0.0, matrixPointer.get(DataType.Double, matrixStructType.offsets[5]));

        scaleFunc.call([matrixPointer, 2.0, 1.0]);

        var xPointer = callfunc.memory.alloc(
            callfunc.memory.sizeOf(DataType.Double));
        var yPointer = callfunc.memory.alloc(
            callfunc.memory.sizeOf(DataType.Double));

        xPointer.set(10.0, DataType.Double);
        yPointer.set(10.0, DataType.Double);

        transformPointFunc.call([matrixPointer, xPointer, yPointer]);

        Assert.equals(20.0, xPointer.get(DataType.Double));
        Assert.equals(10.0, yPointer.get(DataType.Double));

        callfunc.memory.free(matrixPointer);
        callfunc.memory.free(xPointer);
        callfunc.memory.free(yPointer);
        initIdentityFunc.dispose();
        scaleFunc.dispose();
        transformPointFunc.dispose();
        library.dispose();
    }
}
