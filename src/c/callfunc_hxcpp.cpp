#include <hxcpp.h>
#include <callfunc.c>

void _callfunc_closure_impl(struct CallfuncCallback * callback) {
    callback->haxe_function();
}
