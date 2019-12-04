package callfunc.core.serialization;

import haxe.Int64;

class NumberUtil {
    public static function toInt(value:Any):Int {
        if (Std.is(value, Int)) {
            return value;
        } else if (Int64.is(value)) {
            return (value:Int64).low;
        } else if (Std.is(value, Float)) {
            return Std.int(value);
        } else {
            throw "Cannot convert value to Int";
        }
    }

    public static function toInt64(value:Any):Int64 {
        if (Int64.is(value)) {
            return value;
        } else if (Std.is(value, Int)) {
            return Int64.make(0, value);
        } else if (Std.is(value, Float)) {
            return Int64.fromFloat(value);
        } else {
            throw "Cannot convert value to Int64";
        }
    }

    public static function intToUInt8(value:Int):Int {
        if (value >= 0) {
            return value;
        } else {
            return (~(-value) & 0xff) + 1;
        }
    }

    public static function intToUInt16(value:Int):Int {
        if (value >= 0) {
            return value;
        } else {
            return (~(-value) & 0xffff) + 1;
        }
    }

    public static function intToUInt(value:Int):UInt {
        if (value >= 0) {
            return value;
        } else {
            return (~(-value) & 0xffffffff) + 1;
        }
    }
}
