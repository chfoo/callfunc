package callfunc;

/**
 * Represents common C data types.
 *
 * The following types are not supported:
 *
 * - LongDouble
 * - ComplexFloat
 * - ComplexDouble
 * - ComplexLongDouble
 *
 * The `Pointer` data type is a pointer to a data type (object pointer) or
 * a function (function pointer). libffi and Callfunc assumes that the
 * architecture treats object pointers and function pointers as the
 * same thing. It is up to the user to dereference the pointer to the correct
 * data type or function.
 *
 * Note that `Struct` is a composite of data types. It is intended to define
 * pass-by-value struct C function signatures and nested struct definitions.
 * Not to be confused with a `Pointer` which can point to a struct.
 *
 * @see `CoreDataType`
 */
enum DataType {
    Void;
    UInt8;
    SInt8;
    UInt16;
    SInt16;
    UInt32;
    SInt32;
    UInt64;
    SInt64;
    Float;
    Double;
    UChar;
    SChar;
    UShort;
    SShort;
    SInt;
    UInt;
    SLong;
    ULong;
    Pointer;
    LongDouble;
    ComplexFloat;
    ComplexDouble;
    ComplexLongDouble;
    Size;
    PtrDiff;
    WChar;
    Struct(fields:Array<DataType>);
}
