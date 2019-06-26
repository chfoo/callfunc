package callfunc;

import haxe.Int64;

/**
 * `Int64` abstract with automatic promotion of `Int`.
 */
@:forward
@:forwardStatics
abstract AutoInt64(Int64) from Int64 to Int64 {
    inline public function new(value:Int64) {
        this = value;
    }

    @:from
    inline public static function fromInt(value:Int):AutoInt64 {
        return new AutoInt64(Int64.make(0, value));
    }
}
