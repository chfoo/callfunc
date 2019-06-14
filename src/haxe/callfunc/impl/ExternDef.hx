package callfunc.impl;

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

typedef ExternVoidStar = cpp.RawPointer<cpp.Void>;
typedef ExternPointer<T> = cpp.RawPointer<T>;
typedef ExternLibrary = cpp.RawPointer<CPPExternLibrary>;
typedef ExternFunction = cpp.RawPointer<CPPExternFunction>;
typedef ExternStructType = cpp.RawPointer<CPPExternStructType>;
typedef ExternBytesData = cpp.Pointer<cpp.UInt8>;
typedef ExternString = String;
typedef ExternInt8 = cpp.Int8;

#elseif hl

typedef ExternVoidStar = hl.Abstract<"void*">;
typedef ExternPointer<T> = hl.Ref<T>;
typedef ExternLibrary = hl.Abstract<"struct CallfuncLibrary">;
typedef ExternFunction = hl.Abstract<"struct CallfuncFunction">;
typedef ExternStructType = hl.Abstract<"struct CallfuncStructType">;
typedef ExternBytesData = hl.Bytes;
typedef ExternString = hl.Bytes;
typedef ExternInt8 = hl.UI8;

#else

typedef ExternVoidStar = Dynamic;
typedef ExternPointer<T> = Dynamic;
typedef ExternLibrary = Dynmaic;
typedef ExternFunction = Dynmaic;
typedef ExternStructType = Dynmaic;
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
    #if cpp @:native("callfunc_get_error_message") #end
    #if hl @:hlNative("callfunc", "callfunc_get_error_message") #end
    public static function getErrorMessage():ExternString;

    #if cpp @:native("callfunc_get_sizeof_table") #end
    #if hl @:hlNative("callfunc", "callfunc_get_sizeof_table") #end
    public static function getSizeOfTable(buffer:ExternBytesData):Void;

    #if cpp @:native("callfunc_alloc") #end
    #if hl @:hlNative("callfunc", "callfunc_alloc") #end
    public static function alloc(size:Int, zero:Bool):ExternVoidStar;

    #if cpp @:native("callfunc_free") #end
    #if hl @:hlNative("callfunc", "callfunc_free") #end
    public static function free(pointer:ExternVoidStar):Void;

    #if cpp @:native("callfunc_new_library") #end
    #if hl @:hlNative("callfunc", "callfunc_new_library") #end
    public static function newLibrary():ExternLibrary;

    #if cpp @:native("callfunc_del_library") #end
    #if hl @:hlNative("callfunc", "callfunc_del_library") #end
    public static function delLibrary(library:ExternLibrary):Void;

    #if cpp @:native("callfunc_library_open") #end
    #if hl @:hlNative("callfunc", "callfunc_library_open") #end
    public static function libraryOpen(library:ExternLibrary,
        name:ExternString):Int;

    #if cpp @:native("callfunc_library_close") #end
    #if hl @:hlNative("callfunc", "callfunc_library_close") #end
    public static function libraryClose(library:ExternLibrary):Void;

    #if cpp @:native("callfunc_library_get_address") #end
    #if hl @:hlNative("callfunc", "callfunc_library_get_address") #end
    public static function libraryGetAddress(
        library:ExternLibrary,
        name:ExternString,
        destPointer:ExternPointer<ExternVoidStar>):Int;

    #if cpp @:native("callfunc_new_function") #end
    #if hl @:hlNative("callfunc", "callfunc_new_function") #end
    public static function newFunction(library:ExternLibrary):ExternFunction;

    #if cpp @:native("callfunc_del_function") #end
    #if hl @:hlNative("callfunc", "callfunc_del_function") #end
    public static function delFunction(func:ExternFunction):Void;

    #if cpp @:native("callfunc_function_define") #end
    #if hl @:hlNative("callfunc", "callfunc_function_define") #end
    public static function functionDefine(
        func:ExternFunction,
        targetFunc:ExternVoidStar,
        definition:ExternBytesData):Int;

    #if cpp @:native("callfunc_function_call") #end
    #if hl @:hlNative("callfunc", "callfunc_function_call") #end
    public static function functionCall(func:ExternFunction,
        buffer:ExternBytesData):Void;

    #if cpp @:native("callfunc_new_struct_type") #end
    #if hl @:hlNative("callfunc", "callfunc_new_struct_type") #end
    public static function newStructType():ExternStructType;

    #if cpp @:native("callfunc_del_struct_type") #end
    #if hl @:hlNative("callfunc", "callfunc_del_struct_type") #end
    public static function delStructType(structType:ExternStructType):Void;

    #if cpp @:native("callfunc_struct_type_define") #end
    #if hl @:hlNative("callfunc", "callfunc_struct_type_define") #end
    public static function structTypeDefine(
        structType:ExternStructType,
        definition:ExternBytesData,
        result:ExternBytesData):Int;

    #if cpp @:native("callfunc_pointer_to_int64") #end
    #if hl @:hlNative("callfunc", "callfunc_pointer_to_int64") #end
    public static function pointerToInt64(pointer:ExternVoidStar):Int64;

    #if cpp @:native("callfunc_int64_to_pointer") #end
    #if hl @:hlNative("callfunc", "callfunc_int64_to_pointer") #end
    public static function int64ToPointer(address:Int64):ExternVoidStar;

    #if cpp @:native("callfunc_pointer_get") #end
    #if hl @:hlNative("callfunc", "callfunc_pointer_get") #end
    public static function pointerGet(
        pointer:ExternVoidStar, dataType:ExternInt8,
        buffer:ExternBytesData, offset:Int):Void;

    #if cpp @:native("callfunc_pointer_set") #end
    #if hl @:hlNative("callfunc", "callfunc_pointer_set") #end
    public static function pointerSet(
        pointer:ExternVoidStar, dataType:ExternInt8,
        buffer:ExternBytesData, offset:Int):Void;
}
