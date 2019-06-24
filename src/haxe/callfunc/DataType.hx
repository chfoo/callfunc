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
}
