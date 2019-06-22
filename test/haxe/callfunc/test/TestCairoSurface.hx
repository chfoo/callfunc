package callfunc.test;

import utest.Assert;
import utest.Test;

class TestCairoSurface extends Test {
    public function testSimpleDraw() {
        var callfunc = Callfunc.instance();
        var library = callfunc.newLibrary(TestCairoMatrix.getLibName());

        var imageSurfaceCreateFunc = library.newFunction(
            "cairo_image_surface_create",
            [DataType.SInt32, DataType.SInt, DataType.SInt],
            DataType.Pointer
        );

        var surfaceStatusFunc = library.newFunction(
            "cairo_surface_status",
            [DataType.Pointer],
            DataType.SInt
        );

        var imageSurfaceGetDataFunc = library.newFunction(
            "cairo_image_surface_get_data",
            [DataType.Pointer],
            DataType.Pointer
        );

        var surfaceFlushFunc = library.newFunction(
            "cairo_surface_flush",
            [DataType.Pointer]
        );

        var surfaceDestroyFunc = library.newFunction(
            "cairo_surface_destroy",
            [DataType.Pointer]
        );

        var createFunc = library.newFunction(
            "cairo_create",
            [DataType.Pointer],
            DataType.Pointer
        );

        var destroyFunc = library.newFunction(
            "cairo_destroy",
            [DataType.Pointer]
        );

        var rectangleFunc = library.newFunction(
            "cairo_rectangle",
            [DataType.Pointer, DataType.Double, DataType.Double,
            DataType.Double, DataType.Double]
        );

        var fillFunc = library.newFunction(
            "cairo_fill",
            [DataType.Pointer]
        );

        var surface = imageSurfaceCreateFunc.call([0, 100, 100]);
        var status = surfaceStatusFunc.call([surface]);

        Assert.equals(0, status);

        var context = createFunc.call([surface]);

        rectangleFunc.call([context, 1, 0, 20, 20]);
        fillFunc.call([context]);
        surfaceFlushFunc.call([surface]);

        var data:Pointer = imageSurfaceGetDataFunc.call([surface]);

        Assert.equals(0, data.get(DataType.UInt32));
        Assert.equals(0xff000000,
            data.get(DataType.UInt32,
                1 * callfunc.memory.sizeOf(DataType.UInt32)));

        destroyFunc.call([context]);
        surfaceDestroyFunc.call([surface]);
        imageSurfaceCreateFunc.dispose();
        imageSurfaceCreateFunc = library.newFunction(
            "cairo_image_surface_create",
            [DataType.SInt32, DataType.SInt, DataType.SInt],
            DataType.Pointer
        );

        imageSurfaceGetDataFunc.dispose();
        surfaceStatusFunc.dispose();
        surfaceFlushFunc.dispose();
        surfaceDestroyFunc.dispose();
        createFunc.dispose();
        destroyFunc.dispose();
        rectangleFunc.dispose();
        fillFunc.dispose();
        library.dispose();
    }
}
