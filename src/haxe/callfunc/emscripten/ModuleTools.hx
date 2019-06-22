package callfunc.emscripten;

import haxe.Int64;

class ModuleTools {
    public static function getSymbol(module:EmscriptenModule, name:String):Dynamic {
        var result = Reflect.field(module, '_$name');

        if (result == null) {
            throw 'Cannot get symbol _$name. Is it in EXPORTED_FUNCTIONS?';
        }

        return result;
    }

    public static function toFloat(int64:Int64):Float {
        return (int64.low:Float) + int64.high * 4294967296;
    }
}
