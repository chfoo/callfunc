# Callfunc

Callfunc is a foreign function interface library for Haxe. It uses [libffi](https://github.com/libffi/libffi) for the actual native function execution. The use of libffi allows loading and calling arbitrary functions from dynamic libraries at runtime. If you have used Python, this is the same concept of the ctypes module.

As described in the libffi readme, there will be some costs to performance. As well, Callfunc can only operate on the [ABI](https://en.wikipedia.org/wiki/Application_binary_interface) of a library. There will be a loss of safety such as C enums and typedefs. Regardless, Callfunc can be useful for easily calling native libraries or creating a library binding without having to maintain various wrappers for different targets.

Supported targets:

* CPP (little-endian only)
* HashLink and HL/C (little-endian only)

Callfunc can also be used as a interface for calling foreign functions in other targets:

* JS + Emscripten (32-bit WASM, little-endian only)

## Quick start

Callfunc requires:

* Haxe 4 rc2 or newer
* libffi 3.3-rc0 or newer

Install Callfunc from Haxelib:

    haxelib install callfunc

Or install the latest from GitHub:

    haxelib git callfunc https://github.com/chfoo/callfunc

Obtain libffi.{so,dylib,dll} (and callfunc.hdll for Hashlink) from the zip releases or see "Compiling libraries" to build them yourself.

## Types

The `CoreDataType` enum contains the same data types as described in libffi. The `DataType` enum contains additional data types that are automatically aliased to core data types.

Integer C data types that fit within 32 bits, such as `int16_t`, are converted to Haxe `Int`. C integers that are 64 bits wide are converted to Haxe `Int64`. As a consequence, `long int` can be either `Int` or `Int64` depending on the ABI.

Likewise, **when converting to C data types, Haxe `Int` and `Int64` will be truncated (possible loss of data) when the data type is too small**. Otherwise, it there is no loss of data (either it fits or promoted).

`float` and `double` are converted to Haxe `Float`.

`void *` and alike are represented by the `Pointer` class.

## Loading a library

To load a library, obtain a `Callfunc` instance and call the `newLibrary` method:

```haxe
var callfunc = Callfunc.instance();
var library = callfunc.openLibrary("libexample.so");
```

The name of the library is passed to `dlopen()` or `LoadLibrary()` on Windows.

## Calling functions

The library object has a `s` field which lets you access functions using array access or field access syntax.

### No parameters

C:

```c
void do_something();
```

Haxe:

```haxe
library.s["do_something"].call();
// or
library.s.do_something.call();
```

### Numeric parameters

By default, functions are automatically defined to accept no parameters and return no value. To pass arguments, you need to define the parameters. Once you definea function, you can call it as many times as you want.

C:

```c
void do_something(int32_t a, int64_t b, double c);
```

Haxe:

```haxe
library.define(
    "do_something",
    [DataType.SInt32, DataType.SInt64, DataType.Double]
);
library.s.do_something(123, Int64.make(123, 456), 123.456);
```

### Numeric return

C:

```c
int do_something();
```

Haxe:

```haxe
library.define("do_something", [], DataType.SInt);
var result = library.s.do_something.call();
trace(result); // Int on x86/x86-64
```

## Pointers

C pointers are represented by the `Pointer` class. They have two main methods which are `get()` and `set()`. By default, they have a data type of `SInt32` but you can change it as needed.

C:

```c
void do_something(int32_t * a);
```

Haxe:

```haxe
library.s.define("do_something", [DataType.Pointer]);

var size = callfunc.sizeOf(DataType.SInt32);
var p = callfunc.alloc(size);

p.dataType = DataType.SInt32;

p.set(123);
library.s.do_something.call(p);
var result = p.get();
trace(result);
```

If you need to free the allocated memory, use:

```haxe
pointer.free();
```

### Arrays

To access array elements, use the array version of get/set:

```haxe
var index = 10;
p.arraySet(index, 456);
var value = p.arrayGet(index); // => 456
```

### Interpreting pointers as Bytes

Callfunc has methods for converting between `Bytes` and `Pointer` for targets that support it. The `Bytes` instance can be operated on directly which bypasses the `Pointer` class wrapper. Allocating `Bytes` to use a `Pointer` can also take advantage of the Haxe garbage collection.

To convert to `Bytes` assuming an array of 10 bytes:

```haxe
var bytes = pointer.getBytes(10);
```

To convert from `Bytes`:
```haxe
var pointer = callfunc.bytesToPointer(bytes);
```

However, for better portability between targets, the `DataView` interface (and `BytesDataView` implementation) is provided:

```haxe
var view = pointer.getDataView(10);

view.setUInt32(0, 123);
trace(view.getUInt32(0))
```

## Structures

Unlike C arrays, the fields in C structures aren't necessarily next to each other. The way structs are packed depends on the ABI. To obtain the size and field offsets, build a `StructDef`.

To build this C struct:

```c
struct {
    int a;
    char * b;
};
```

Call `callfunc.defineStruct()`:

```haxe
var structDef = callfunc.defineStruct(
    [DataType.SInt, DataType.Pointer],
    ["a", "b"]
);
```

Structs can be accessed using the struct information:

```haxe
var structPointer = callfunc.alloc(structType.size);

var a = structPointer.get(DataType.SInt, structType.offsets[0]);
var b = structPointer.get(DataType.Pointer, structType.offsets[1]);
```

But in most cases, you will access structs using the helper class `StructAccess`:

```haxe
var struct = structDef.access(structPointer);

struct["a"] = 123;
trace(struct["a"]);
// or
struct.a = 123;
trace(struct.a);
```

### Passing structs by value

Structs are usually passed by reference using pointers, but passing structs by value is also supported. This is done by specifying the `Struct` data type to the function definition and pass `Pointer` arguments to populated structs. Copies of the structs will be made from the pointers during the function call.

For functions that return structs by value, a `Pointer` to a copied struct will be returned. This pointer should be freed by the caller.

## Callback functions

C code calling Haxe code is supported.

The following C function accepts a function pointer. The function pointer accepts two integers and returns an integer.

```c
void do_something(int32_t (*callback)(int32_t a, int32_t b));
```

In Haxe, define the function parameters and return type and obtain a pointer to be passed to the C function.

```haxe
function myHaxeCallback(a:Int, b:Int):Int {
    return b - a;
}

var callfunc = Callfunc.instance();
var callbackDef = callfunc.wrawCallback(
    myHaxeCallback,
    [DataType.SInt32, DataType.SInt32],
    DataType.SInt32
);

library.define("do_something", [DataType.Pointer]);
library.s.do_something.call(callbackDef.pointer);
```

## Strings

To quickly allocate a string:

```haxe
var pointer = callfunc.allocString("Hello world!");

// By default, UTF-8 is used.
// To use UTF-16 use:

var pointer = callfunc.allocString("Hello world!", Encoding.UTF16);
```

Likewise, to decode a string:

```haxe
var string = pointer.getString();

// or

var string = pointer.getString(Encoding.UTF16);
```

## 32/64-bit integers

Callfunc provides `AutoInt64` that is an abstract of `Int64` which automatically promotes `Int` to `Int64`. Likewise, `AutoInt` is an abstract of `Int` which truncates `Int64` to `Int`.

`AutoInt64` can be useful with working on C data types such as `size_t` which don't have a fixed width.

## Emscripten

To use Callfunc's interface to Emscripten, you must create a context with the module object:

```haxe
var context = new EmContext(Reflect.field(js.Browser.window, "Module"));
Callfunc.setInstance(new Callfunc(context));
```

To use exported functions, simply use the empty string `""` as the library name. Opening other libraries is not supported at this time.

## Garbage collection

Any object with a `dispose()` method contains resources that cannot be automatically garbage collected. It is up to the user to call this method at the appropriate times.

Likewise, `Pointer` objects hold C pointers which must be treated with care as usual in C.

## Safety

Callfunc does not provide any automatic protection against memory-unsafe conditions such as dangling pointers, out-of-bounds read/writes, type confusion, or integer overflows/underflows.

For targets that use libffi, the creation of `Function` or `StructType` instances is not thread safe.

## Documentation

A libcurl example is in the "example" directory.

API docs: https://chfoo.github.io/callfunc/api/

## Compiling the libraries

Pre-compiled libraries are included in the releases, but if you need to compile them yourself, see below.

### libffi

#### Windows

vcpkg can be used to build libffi.

At the time of writing, a [patched port](https://github.com/microsoft/vcpkg/pull/6119) of libffi for 3.3-rc0 is not in the main repository yet. The instructions below describe how to include it.

If you are compiling to HashLink, note that the HashLink binary from the website is 32-bit, so you will need to build and use 32-bit versions of the libraries.

1. Download and set up vcpkg
2. Install the Visual Studio C++ workload SDK in Tools, Get Tool and Features.
3. Add the fork: `git add remote driver1998 https://github.com/driver1998/vcpkg/`
4. Update: `git fetch driver1998 libffi`
5. Switch to a temporary branch: `git checkout driver1998/libffi`
6. Run `./vcpkg install libffi:x64-windows libffi:x86-windows`
7. Run `./vcpkg export --zip libffi:x64-windows libffi:x86-windows`

The header and library will be in `include` and `bin` directories of the `x64-windows` (64-bit) and `x86-windows` (32-bit).

For the CPP target, you may optionally use MinGW-w64 if you have trouble compiling with the Haxe HXCPP and VS toolchain. In your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml`, under the "VARS" section, set `mingw` to `1`.

#### MacOS

You can use homebrew to install libffi, but at the time of writing, it points to an outdated fork. You will need to run `brew edit libffi` to edit the brew recipe to use the official fork and install the head version.

On line 18, change:

    head do
        url "https://github.com/atgreen/libffi.git"

To:

    head do
        url "https://github.com/libffi/libffi.git"

Then run `brew install libffi --HEAD` and `brew info libffi` to get the library path.

#### Linux

Typically libraries are provided your distribution's package manager, but only stable versions. In this case, the library can be built and installed following the instructions in the libffi readme file. Running the install step will install it to /usr/local/lib. On Debian-based distributions, you can replace the install step with `checkinstall` to create and install a deb package.

The paths for searching for libraries is more restricted when executing applications. The `LD_LIBRARY_PATH` environment can be provided to the executable. For example:

`LD_LIBRARY_PATH="./:/usr/local/lib/:$LD_LIBRARY_PATH"`

### callfunc.hdll (HashLink)

You will need CMake. The following commands assumes a Bash shell.

1. Create a build directory and change to it.

        mkdir -p out/ && cd out/

2. Run cmake to generate build files using a release config.

        cmake .. -DCMAKE_BUILD_TYPE=Release

To specify the include and linker paths add (adjust paths as needed):

* For libffi: `-DLIBFFI_INCLUDE_PATH:PATH=/usr/local/include/ -DLIBFFI_LIB_PATH:PATH=/usr/local/lib/`. For vcpkg, please add the toolchain define as reported at the end of libffi install.
* For HashLink: `-DHLINCLUDE_PATH:PATH=/usr/local/include/ -DHL_LIB_PATH:PATH=/usr/local/lib/`.

On Linux and MacOS, this will be a makefile which you can run `make`.

On Windows, add `-A win32` for 32-bit. CMake will generate a Visual Studio project file or nmake config by default. Consult documentation on CMake generators for other configs such as Mingw-w64.

The generated library will be in `out/out/callfunc/`.

### CPP target

The Callfunc binding library is statically built by hxcpp.

By default, the hxcpp build config (hxcpp_build.hxml) is configured to include libffi files only for a unit testing setup. You may need edit your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml` file to specify include and linking flags for libffi if your compiler cannot find the correct libffi.

For example:

* To add the header include path `-I` flag, add `<flag value="-I/usr/local/include"/>` to the `<compiler>` section.
* To add the dynamic library link path `-L` flag, add `<flag value="-L/usr/local/lib"/>` to the `<linker>` section.

Adjust the paths or create new sections for your platform/compiler as needed.

## Javascript

There are no C libraries needed to be compiled for the Javascript target.

## Tests

To run the unit tests, please look at the .travis.yml file.

## Contributing

If you have a bug report, bug fix, or missing feature, please file an issue or pull request on GitHub.

## License

See [LICENSE file](LICENSE). Note that you must also comply with the license of libffi too.
