package callfunc.core.impl;

import haxe.io.BytesData;
import haxe.Int64;

#if cpp
@:include("callfunc.h")
@:native("CallfuncLibrary")
private extern class CPPExternLibrary {
}

@:include("callfunc.h")
@:native("CallfuncFunction")
private extern class CPPExternFunction {
}

@:include("callfunc.h")
@:native("CallfuncStructType")
private extern class CPPExternStructType {
}

@:include("callfunc.h")
@:native("CallfuncCallback")
private extern class CPPExternCallback {
}

typedef ExternVoidStar = cpp.RawPointer<cpp.Void>;
typedef ExternPointer<T> = cpp.RawPointer<T>;
typedef ExternLibrary = cpp.RawPointer<CPPExternLibrary>;
typedef ExternFunction = cpp.RawPointer<CPPExternFunction>;
typedef ExternStructType = cpp.RawPointer<CPPExternStructType>;
typedef ExternCallback = cpp.RawPointer<CPPExternCallback>;
typedef ExternBytesData = cpp.Pointer<cpp.UInt8>;
typedef ExternString = cpp.ConstCharStar;
typedef ExternInt8 = cpp.Int8;

#elseif hl

typedef ExternVoidStar = hl.Abstract<"_hl_CallfuncVoidStar">;
typedef ExternPointer<T> = hl.Ref<T>;
typedef ExternLibrary = hl.Abstract<"_hl_CallfuncLibrary">;
typedef ExternFunction = hl.Abstract<"_hl_CallfuncFunction">;
typedef ExternStructType = hl.Abstract<"_hl_CallfuncStructType">;
typedef ExternCallback = hl.Abstract<"_hl_CallfuncCallback">;
typedef ExternBytesData = hl.Bytes;
typedef ExternString = hl.Bytes;
typedef ExternInt8 = hl.UI8;

#else

typedef ExternVoidStar = Dynamic;
typedef ExternPointer<T> = Dynamic;
typedef ExternLibrary = Dynamic;
typedef ExternFunction = Dynamic;
typedef ExternStructType = Dynamic;
typedef ExternCallback = Dynamic;
typedef ExternBytesData = BytesData;
typedef ExternString = String;
typedef ExternInt8 = Int;

#end


#if cpp
    @:include("callfunc.h")

    #if callfunc
        // "callfunc" is defined by haxelib
        @:buildXml("<include name=\"${haxelib:callfunc}/hxcpp_build.xml\" />")
    #else
        // `this_dir` is out/cpp/
        @:buildXml("<include name=\"${this_dir}/../../hxcpp_build.xml\" />")
    #end
#end
extern class ExternDef {
    #if cpp @:native("callfunc_api_version") #end
    #if hl @:hlNative("callfunc", "api_version") #end
    public static function apiVersion():Int;

    #if cpp @:native("callfunc_get_error_message") #end
    #if hl @:hlNative("callfunc", "get_error_message") #end
    public static function getErrorMessage():ExternString;

    #if cpp @:native("callfunc_get_sizeof_table") #end
    #if hl @:hlNative("callfunc", "get_sizeof_table") #end
    public static function getSizeOfTable(buffer:ExternBytesData):Void;

    #if cpp @:native("callfunc_alloc") #end
    #if hl @:hlNative("callfunc", "alloc") #end
    public static function alloc(size:Int, zero:Bool):ExternVoidStar;

    #if cpp @:native("callfunc_free") #end
    #if hl @:hlNative("callfunc", "free") #end
    public static function free(pointer:ExternVoidStar):Void;

    #if cpp @:native("callfunc_new_library") #end
    #if hl @:hlNative("callfunc", "new_library") #end
    public static function newLibrary():ExternLibrary;

    #if cpp @:native("callfunc_del_library") #end
    #if hl @:hlNative("callfunc", "del_library") #end
    public static function delLibrary(library:ExternLibrary):Void;

    #if cpp @:native("callfunc_library_open") #end
    #if hl @:hlNative("callfunc", "library_open") #end
    public static function libraryOpen(library:ExternLibrary,
        name:ExternString):Int;

    #if cpp @:native("callfunc_library_close") #end
    #if hl @:hlNative("callfunc", "library_close") #end
    public static function libraryClose(library:ExternLibrary):Void;

    #if cpp @:native("callfunc_library_get_address") #end
    #if hl @:hlNative("callfunc", "library_get_address") #end
    public static function libraryGetAddress(
        library:ExternLibrary,
        name:ExternString,
        destPointer:ExternPointer<ExternVoidStar>):Int;

    #if cpp @:native("callfunc_new_function") #end
    #if hl @:hlNative("callfunc", "new_function") #end
    public static function newFunction(library:ExternLibrary):ExternFunction;

    #if cpp @:native("callfunc_del_function") #end
    #if hl @:hlNative("callfunc", "del_function") #end
    public static function delFunction(func:ExternFunction):Void;

    #if cpp @:native("callfunc_function_define") #end
    #if hl @:hlNative("callfunc", "function_define") #end
    public static function functionDefine(
        func:ExternFunction,
        targetFunc:ExternVoidStar,
        abi:Int,
        definition:ExternBytesData):Int;

    #if cpp @:native("callfunc_function_call") #end
    #if hl @:hlNative("callfunc", "function_call") #end
    public static function functionCall(func:ExternFunction,
        buffer:ExternBytesData):Void;

    #if cpp @:native("callfunc_new_struct_type") #end
    #if hl @:hlNative("callfunc", "new_struct_type") #end
    public static function newStructType():ExternStructType;

    #if cpp @:native("callfunc_del_struct_type") #end
    #if hl @:hlNative("callfunc", "del_struct_type") #end
    public static function delStructType(structType:ExternStructType):Void;

    #if cpp @:native("callfunc_struct_type_define") #end
    #if hl @:hlNative("callfunc", "struct_type_define") #end
    public static function structTypeDefine(
        structType:ExternStructType,
        definition:ExternBytesData,
        result:ExternBytesData):Int;

    #if cpp @:native("callfunc_new_callback") #end
    #if hl @:hlNative("callfunc", "new_callback") #end
    public static function newCallback():ExternCallback;

    #if cpp @:native("callfunc_del_callback") #end
    #if hl @:hlNative("callfunc", "del_callback") #end
    public static function delCallback(callback:ExternCallback):Void;

    #if cpp @:native("callfunc_callback_define") #end
    #if hl @:hlNative("callfunc", "callback_define") #end
    public static function callbackDefine(
        callback:ExternCallback,
        definition:ExternBytesData):Int;

    #if cpp @:native("callfunc_callback_bind") #end
    #if hl @:hlNative("callfunc", "callback_bind") #end
    public static function callbackBind(
        callback:ExternCallback,
        argBuffer:ExternBytesData,
        handler:Void->Void):Int;

    #if cpp @:native("callfunc_callback_get_pointer") #end
    #if hl @:hlNative("callfunc", "callback_get_pointer") #end
    public static function callbackGetPointer(
        callback:ExternCallback):ExternVoidStar;

    #if cpp @:native("callfunc_pointer_to_int64") #end
    #if hl @:hlNative("callfunc", "pointer_to_int64_hl") #end
    public static function pointerToInt64(pointer:ExternVoidStar):Int64;

    #if cpp @:native("callfunc_int64_to_pointer") #end
    #if hl @:hlNative("callfunc", "int64_to_pointer_hl") #end
    public static function int64ToPointer(address:Int64):ExternVoidStar;

    #if cpp @:native("callfunc_pointer_get") #end
    #if hl @:hlNative("callfunc", "pointer_get") #end
    public static function pointerGet(
        pointer:ExternVoidStar, dataType:ExternInt8,
        buffer:ExternBytesData, offset:Int):Void;

    #if cpp @:native("callfunc_pointer_set") #end
    #if hl @:hlNative("callfunc", "pointer_set") #end
    public static function pointerSet(
        pointer:ExternVoidStar, dataType:ExternInt8,
        buffer:ExternBytesData, offset:Int):Void;

    #if cpp @:native("callfunc_pointer_array_get") #end
    #if hl @:hlNative("callfunc", "pointer_array_get") #end
    public static function pointerArrayGet(
        pointer:ExternVoidStar, dataType:ExternInt8,
        buffer:ExternBytesData, index:Int):Void;

    #if cpp @:native("callfunc_pointer_array_set") #end
    #if hl @:hlNative("callfunc", "pointer_array_set") #end
    public static function pointerArraySet(
        pointer:ExternVoidStar, dataType:ExternInt8,
        buffer:ExternBytesData, index:Int):Void;
}
