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
     * value will be converted or truncated with data loss. This is performed
     * by taking the "low" value.
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
            final int64Value:Int64 = value;
            if (!checkTruncation) {
                return int64Value.low;
            } else {
                if (int64Value.high == 0) {
                    return int64Value.low;
                } else {
                    throw 'Data loss when truncated: ${int64Value.high}_${int64Value.low}';
                }
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
