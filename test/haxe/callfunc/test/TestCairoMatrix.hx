package callfunc.test;

import utest.Assert;

class TestCairoMatrix extends utest.Test {
    public static function getLibName() {
        #if js
        return "";
        #else
        switch Sys.systemName() {
            case "Windows":
                return "cairo.dll";
            case "Mac":
                return "libcairo.dylib";
            default:
                return "libcairo.so";
        }
        #end
    }

    public function testMatrixScale() {
        var ffi = Callfunc.instance();
        var library = ffi.openLibrary(getLibName());

        library.define(
            "cairo_matrix_init_identity",
            [DataType.Pointer]
        );

        library.define(
            "cairo_matrix_scale",
            [DataType.Pointer, DataType.Double, DataType.Double]
        );

        library.define(
            "cairo_matrix_transform_point",
            [DataType.Pointer, DataType.Pointer, DataType.Pointer]
        );

        var matrixStructDef = ffi.defineStruct(
            [DataType.Double, DataType.Double, DataType.Double,
            DataType.Double, DataType.Double, DataType.Double],
            ["xx", "yx", "xy", "yy", "x0", "y0"]
        );

        Assert.isTrue(matrixStructDef.size >= 8 * 6);

        var matrixPointer = ffi.alloc(matrixStructDef.size);
        var matrix = matrixStructDef.access(matrixPointer);

        var i = matrixPointer.address;

        library.s.cairo_matrix_init_identity.call(matrixPointer);

        Assert.equals(1.0, matrix.xx);
        Assert.equals(0.0, matrix.yx);
        Assert.equals(0.0, matrix.xy);
        Assert.equals(1.0, matrix.yy);
        Assert.equals(0.0, matrix.x0);
        Assert.equals(0.0, matrix.y0);

        library.s.cairo_matrix_scale.call(matrixPointer, 2.0, 1.0);

        var xPointer = ffi.alloc(ffi.sizeOf(DataType.Double));
        var yPointer = ffi.alloc(ffi.sizeOf(DataType.Double));
        xPointer.dataType = yPointer.dataType = DataType.Double;

        xPointer.set(10.0);
        yPointer.set(10.0);

        library.s.cairo_matrix_transform_point.call(matrixPointer, xPointer, yPointer);

        Assert.equals(20.0, xPointer.get());
        Assert.equals(10.0, yPointer.get());

        matrixPointer.free();
        matrixStructDef.dispose();
        library.dispose();
        xPointer.free();
        yPointer.free();
    }
}
