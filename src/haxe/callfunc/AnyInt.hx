package callfunc;

import haxe.Int64;

/**
 * Abstract over Dynamic for integer types not known at compile time.
 *
 * This abstract contains convenient methods to convert
 * dynamic objects to `Int` and `Int64` at runtime with optional data loss
 * checking. It encapsulates the if-else type checking.
 *
 * It is used in places where you need to check the type of the value at
 * runtime or as a substitute for an "either" type in functions that accept
 * either `Int` or `Int64`.
 */
abstract AnyInt(Dynamic) from Dynamic to Dynamic {
    static final WRONG_TYPE_ERROR = "Not an Int or Int64";

    /**
     * Converts value to `Int`.
     *
     * If the value is `Int`, it is returned unchanged. If it is `Int64`, the
     * value will be converted or truncated with data loss.
     *
     * @param checkTruncation If `true`, an exception will be thrown if the
     *     value cannot be converted with data loss.
     * @throws String If the value is not `Int` or `Int64`, or value cannot
     *     be converted from `Int64` without data loss.
     */
    public function toInt(checkTruncation:Bool = false):Int {
        final value:Dynamic = this;

        if (Std.is(value, Int)) {
            return value;
        } else if (Int64.is(value)) {
            if (!checkTruncation) {
                return (value:Int64).low;
            } else {
                return Int64.toInt((value:Int64));
            }
        } else {
            throw WRONG_TYPE_ERROR;
        }
    }

    /**
     * Converts value to `Int64`.
     *
     * If the value is `Int` it is promoted to `Int64`. If the value is
     * `Int64`, it is returned unchanged.
     *
     * @throws String If the value is neither `Int` or `Int64`.
     */
    public function toInt64():Int64 {
        final value:Dynamic = this;

        if (Int64.is(value)) {
            return value;
        } else if (Std.is(value, Int)) {
            return Int64.make(0, value);
        } else {
            throw WRONG_TYPE_ERROR;
        }
    }
}
