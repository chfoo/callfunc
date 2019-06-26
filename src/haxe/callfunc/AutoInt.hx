package callfunc;

import haxe.Int64;

/**
 * `Int` abstract with automatic truncation of `Int64`.
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
