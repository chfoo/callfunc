package callfunc.test;

import utest.Assert;
import utest.Test;

class TestCairoSurface extends Test {
    public function testSimpleDraw() {
        var ffi = Callfunc.instance();
        var library = ffi.openLibrary(TestCairoMatrix.getLibName());

        library.define(
            "cairo_image_surface_create",
            [DataType.SInt32, DataType.SInt, DataType.SInt],
            DataType.Pointer
        );

        library.define(
            "cairo_surface_status",
            [DataType.Pointer],
            DataType.SInt
        );

        library.define(
            "cairo_image_surface_get_data",
            [DataType.Pointer],
            DataType.Pointer
        );

        library.define(
            "cairo_surface_flush",
            [DataType.Pointer]
        );

        library.define(
            "cairo_surface_destroy",
            [DataType.Pointer]
        );

        library.define(
            "cairo_create",
            [DataType.Pointer],
            DataType.Pointer
        );

        library.define(
            "cairo_destroy",
            [DataType.Pointer]
        );

        library.define(
            "cairo_rectangle",
            [DataType.Pointer, DataType.Double, DataType.Double,
            DataType.Double, DataType.Double]
        );

        library.define(
            "cairo_fill",
            [DataType.Pointer]
        );

        var surface = library.s.cairo_image_surface_create.call(0, 100, 100);
        var status = library.s.cairo_surface_status.call(surface);

        Assert.equals(0, status);

        var context = library.s.cairo_create.call(surface);

        library.s.cairo_rectangle.call(context, 1, 0, 20, 20);
        library.s.cairo_fill.call(context);
        library.s.cairo_surface_flush.call(surface);

        var data:Pointer = library.s.cairo_image_surface_get_data.call(surface);

        Assert.equals(0, data.get(DataType.UInt32));
        Assert.equals(0xff000000,
            data.get(DataType.UInt32,
                1 * ffi.sizeOf(DataType.UInt32)));

        library.s.cairo_destroy.call(context);
        library.s.cairo_surface_destroy.call(surface);
        library.dispose();
    }
}
