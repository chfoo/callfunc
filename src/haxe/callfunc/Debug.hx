package callfunc;

import haxe.macro.Expr;

using haxe.macro.ExprTools;

class Debug {
    macro static public function assert(condition:Expr, ?message:Expr) {
        if (!haxe.macro.Context.defined("debug")) {
            return macro {};
        }

        var error = 'Assertion error: ${condition.pos}: ${condition.toString()}, ';

        return macro {
            if (!($condition)) {
                throw $v{error} + $message;
            };
        }
    }
}
