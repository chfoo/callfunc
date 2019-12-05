package callfunc;

import haxe.Int64;

/**
 * `Int` abstract with automatic truncation of `Int64`.
 *
 * `Int64` will be converted to `Int` with possible data loss.
 *
 * This abstract can be used for implicit casing between `Int64`
 * as "syntactic sugar".
 *
 * @see `AnyInt` for a runtime version.
 */
@:forward
@:forwardStatics
abstract AutoInt(Int) from Int to Int {
    inline public function new(value:Int) {
        this = value;
    }

    @:from
    inline public static function fromInt64(value:Int64):AutoInt {
        return new AutoInt(value.low);
    }
}
