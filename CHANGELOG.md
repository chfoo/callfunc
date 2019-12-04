# Changelog

## Unreleased

* Changed: The API was overhauled.
  * A new high level API was written and the low level API was moved to the `core` package.
  * Defined library functions are now stored in the library object so you don't need to keep a reference to each one to dispose them later.
  * Functions are now accessed by array access or field access syntax on the `library.s` field.
  * Most static extensions are now part of the high level API so that syntax is more natural. That is, `call()` is used instead of `callVA()` or `getCallable()`.
  * The high level API is more object-oriented, for example, `pointer.free()`, `pointer.getString()`, etc.
  * Class `Callfunc` no longer implements `Context`; `Callfunc` wraps `Context` now. For unsupported targets, `Callfunc` wraps `DummyContext`.
    * Emscripten users still need to make `Callfunc` wrap `EmContext` and set that as the singleton.
  * Please review the readme to update your code to the new API.

## 0.4.0 (2019-08-27)

* Changed: [Backwards incompatible] `Pointer`: The parameters in `arrayGet()` and `arraySet()` were reordered to be closer with standard array or map methods.
* Added: `dataType` field to `Pointer` for default data type.

## 0.3.0 (2019-08-23)

* Fixed: Emscripten pointer get() for unsigned int data types returning signed values.
* Added: StructAccess
* Added: Support for pass by value structs

## 0.2.1 (2019-07-03)

* Fixed: Support for HL/C
* Fixed: Double free when closing library and memory leak when error thrown opening library/function.

## 0.2.0 (2019-06-26)

* Fixed: Signed int8 and int16 conversion from int32 or unsigned int8.
* Changed `Memory.pointerToBytes()` to never free the pointer.
* Added: `Pointer.arrayGet()` and `Pointer.arraySet()`.
* Added: `Callfunc.newCallback()`.
* Added: JS+Emscripten interface support.
* Added: `DataView` and `Memory.pointerToDataView()`.
* Added: More data types.
* Added: `Library.newVariadicFunction()`.
* Added: `FunctionTools` and `PointerTools`.

## 0.1.0 (2019-06-19)

* First release
