package callfunc;

/**
 * Represents C data types.
 */
@:enum
abstract DataType(Int) {
    var Void = 0;
    var UInt8 = 1;
    var SInt8 = 2;
    var UInt16 = 3;
    var SInt16 = 4;
    var UInt32 = 5;
    var SInt32 = 6;
    var UInt64 = 7;
    var SInt64 = 8;
    var Float = 9;
    var Double = 10;
    var UChar = 11;
    var SChar = 12;
    var UShort = 13;
    var SShort = 14;
    var SInt = 15;
    var UInt = 16;
    var SLong = 17;
    var ULong = 18;
    var Pointer = 19;

    inline public function toInt():Int {
        return this;
    }
}
