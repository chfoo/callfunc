# Callfunc

Callfunc is a foreign function interface library for Haxe. It uses [libffi](https://github.com/libffi/libffi) for the actual native function execution. The use of libffi allows loading and calling arbitrary functions from dynamic libraries at runtime. If you have used Python, this is the same concept of the ctypes module.

As described in the libffi readme, there will be some costs to performance. As well, Callfunc can only operate on the [ABI](https://en.wikipedia.org/wiki/Application_binary_interface) of a library. There will be a loss of safety such as C enums and typedefs. Regardless, Callfunc can be useful for easily calling native libraries or creating a library binding without having to maintain various wrappers for different targets.

Supported targets:

* CPP
* HashLink

## Quick start

Callfunc requires:

* Haxe 4 rc2 or newer
* libffi 3.3-rc0 or newer

Install Callfunc from Haxelib:

    haxelib install callfunc

Or install the latest from GitHub:

    haxelib git callfunc https://github.com/chfoo/callfunc

Obtain libffi.{so,dynlib,dll} (and callfunc.hdll for Hashlink) from the zip releases or see "Compiling libraries" to build them yourself.

## Types

The `DataType` enum contains the same data types as described in libffi.

* Integer C data types that fit within 32 bits, such as `int16_t`, are converted to Haxe `Int`. C integers that are 64 bits wide are converted to Haxe `Int64`. As a consequence, `long int` can be either `Int` or `Int64` depending on the ABI.
* `float` and `double` are converted to Haxe `Float`.
* `void *` and alike are represented by the `Pointer` class.

## Loading a library

To load a library, obtain a `Callfunc` instance and call the `newLibrary` method:

```haxe
var callfunc = Callfunc.instance();
var library = callfunc.newLibrary("libexample.so");
```

The name of the library is passed to `dlopen()` or `LoadLibrary()` on Windows.

## Calling functions

Before you can call a function, you need to define the parameters. Then use the handle to the function to call the function as many times as you want.

### No parameters

C:

```c
void do_something();
```

Haxe:

```haxe
var f = library.newFunction("do_something");
f.call();
```

### Numeric parameters

C:

```c
void do_something(int32_t a, int64_t b, double c);
```

Haxe:

```haxe
var f = library.newFunction(
    "do_something",
    [DataType.SInt32, DataType.SInt64, DataType.Double]
);
f.call([123, Int64.make(123, 456), 123.456]);
```

### Numeric return

C:

```c
int do_something();
```

```haxe
var f = library.newFunction("do_something", [], DataType.SInt);
var result = f.call();
trace(result); // Int on x86/x86-64
```

## Pointers

C pointers are represented by the `Pointer` class. They have two main methods which are `get()` and `set()` that accept `DataType` and an optional offset.

C:

```c
void do_something(int32_t * a);
```

Haxe:

```haxe
var f = library.newFunction("do_something", [DataType.Pointer]);
var size = callfunc.memory.sizeOf(DataType.SInt32);
var p = callfunc.memory.alloc(size);

p.set(123, DataType.SInt32);
f.call([p]);
var result = p.get(DataType.SInt32);
```

### Arrays

To access array elements, simply pass the offset to the pointer:

```haxe
var index = 10;
p.set(456, DataType.SInt32, size * index);
var value = p.set(DataType.SInt32, size * index); // => 456
```

### Interpreting pointers as Bytes

Callfunc has methods for converting between `Bytes` and `Pointer`. The `Bytes` instance can be operated on directly which bypasses the `Pointer` class wrapper. Allocating `Bytes` to use a `Pointer` can also take advantage of the Haxe garbage collection.

To convert to `Bytes`:

```haxe
var bytes = callfunc.memory.pointerToBytes(pointer);
```

To convert from `Bytes`:
```haxe
var pointer = callfunc.memory.bytesToPointer(bytes);
```

## Structures

Unlike C arrays, the fields in C structures aren't necessaily next to each other. The way structs are packed depends on the ABI. To obtain the size and field offsets, build a `StructType`.

To build this C struct:

```c
struct {
    int a;
    char * b;
};
```

Call `callfunc.newStructType()`:

```haxe
var structType = callfunc.newStructType([DataType.SInt, DataType.Pointer]);
```

Structs can be accessed using the struct information:

```haxe
var structPointer = callfunc.memory.alloc(structType.size);

var a = structPointer.get(DataType.SInt, structType.offsets[0]);
var b = structPointer.get(DataType.Pointer, structType.offsets[1]);
```

## Documentation

API docs: https://chfoo.github.io/callfunc/api/

## Compiling the libraries

### libffi

#### Windows

I would recommend vcpkg, but it doesn't support compiling from the latest git version. You will need to edit the CONTROL file. (More info to be determined later.)

#### MacOS

I would recommend homebrew, but the brew file head points to an outdated fork for some reason. (More info to be determined later.)

#### Linux

The library can be built and installed following the instructions in the libffi readme file. Running the install step will install it to /usr/local/lib. On Debian-based distributions, you can replace the install step with `checkinstall` to create and install a deb package.

### CPP target

You may need edit your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml` file to specify include and linking flags for libffi.

* To add the header include path `-I` flag, add `<flag value="-I/usr/local/include">` to the `<compiler>` section.
* To add the dynamic library link path `-L` flag, add `<flag value="-L/usr/local/lib">` to the `<linker>` section.

On Windows, you may optionally use MinGW-w64 if you have trouble compiling. Under the "VARS" section, set `mingw` to `1`.

### callfunc.hdll (HashLink target)

A makefile is provided in `src/c/`. You can run it:

    cd src/c
    make hdll

It will be generated to `out/hl/callfunc.hdll`.

On Windows for Mingw-w64, use:

    mingw32-make.exe hdll GCC=i686-w64-mingw32-gcc.exe INCLUDEPATH=/c/path/to/includes/ LIBPATH=/c/path/to/dlls/

Adjust the paths as needed.

### Library paths

On Linux, the paths for searching for libraries is more restricted. The `LD_LIBRARY_PATH` environment can be provided to the executable. For example:

`LD_LIBRARY_PATH="./:/usr/local/lib/:$LD_LIBRARY_PATH"`

## Contributing

If you have a bug report, bug fix, or missing feature, please file an issue or pull request on GitHub.

## License

See [LICENSE file](LICENSE). Note that you must also comply with the license of libffi too.
