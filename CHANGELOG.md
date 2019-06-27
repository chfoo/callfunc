# Changelog

## Unreleased

* Fixed: Support for HL/C

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
