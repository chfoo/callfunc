# Changelog

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
