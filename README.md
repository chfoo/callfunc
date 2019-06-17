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

vcpkg can be used to build libffi, but it doesn't support compiling from the latest git version. You will need to edit the CONTROL file yourself to the latest git version. (More info TBD.)

If you are compiling to HashLink, note that the HashLink binary from the website is 32-bit, so you will need to build 32-bit versions of the libraries.

For the CPP target, you may optionally use MinGW-w64 if you have trouble compiling. In your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml`, under the "VARS" section, set `mingw` to `1`.

#### MacOS

You can use homebrew to install libffi, but at the time of writing, it points to an outdated fork. You will need to run `brew edit libffi` to edit the brew recipe to use the official fork and install the head version. Then run `brew install libffi` and `brew info libffi` to get the library path.

#### Linux

Typically libraries are provided your distribution's package manager, but only stable versions. In this case, the library can be built and installed following the instructions in the libffi readme file. Running the install step will install it to /usr/local/lib. On Debian-based distributions, you can replace the install step with `checkinstall` to create and install a deb package.

The paths for searching for libraries is more restricted when executing applications. The `LD_LIBRARY_PATH` environment can be provided to the executable. For example:

`LD_LIBRARY_PATH="./:/usr/local/lib/:$LD_LIBRARY_PATH"`

### callfunc.hdll (HashLink)

You will need CMake. The following commands assumes a Bash shell.

1. Create a build directory and change to it. `mkdir -p out/ && cd out/`
2. Run cmake to generate build files using a release config and specifying the include and linker paths to libffi. `cmake .. -DCMAKE_BUILD_TYPE=Release -DLIBFFI_INCLUDE_PATH:PATH=/usr/local/include/ -DLIBFFI_LIB_PATH:PATH=/usr/local/lib/`

On Linux and MacOS, this will be a makefile which you can run `make`. On Windows, this will generate a Visual Studio project file or nmake config by default. Consult documentation on CMake generators for other configs such as Mingw-w64.

The generated library will be in `out/out/callfunc/`.

### CPP target

The Callfunc binding library is statically built by hxcpp.

By default, the hxcpp build config (hxcpp_build.hxml) is configured to include libffi files only for a unit testing setup. You may need edit your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml` file to specify include and linking flags for libffi if your compiler cannot find the correct libffi.

For example:

* To add the header include path `-I` flag, add `<flag value="-I/usr/local/include"/>` to the `<compiler>` section.
* To add the dynamic library link path `-L` flag, add `<flag value="-L/usr/local/lib"/>` to the `<linker>` section.

Adjust the paths or create new sections for your platform/compiler as needed.

## Contributing

If you have a bug report, bug fix, or missing feature, please file an issue or pull request on GitHub.

## License

See [LICENSE file](LICENSE). Note that you must also comply with the license of libffi too.
