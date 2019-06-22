package callfunc.emscripten;

import haxe.Int64;

using callfunc.emscripten.ModuleTools;

class EmPointer implements Pointer {
    public var address(get, never):Int64;

    final _address:Int64;
    public final nativePointer:Int;
    final module:EmscriptenModule;

    public function new(module:EmscriptenModule, nativePointer:Int) {
        this.module = module;
        this.nativePointer = nativePointer;
        _address = Int64.fromFloat(nativePointer);
    }

    function get_address():Int64 {
        return _address;
    }

    public function isNull():Bool {
        return nativePointer == 0;
    }

    public function get(dataType:DataType, offset:Int = 0):Any {
        switch dataType {
            case DataType.SInt64 | DataType.UInt64 |
                    DataType.SLong | DataType.ULong:
                return Int64.make(
                    module.getValue(
                        nativePointer + offset + 4,
                        EmDataType.toLLVMType(DataType.SInt32)
                    ),
                    module.getValue(
                        nativePointer + offset,
                        EmDataType.toLLVMType(DataType.SInt32)
                    )
                );
            default:
                return module.getValue(
                    nativePointer + offset,
                    EmDataType.toLLVMType(dataType)
                );
        }
    }

    public function set(value:Any, dataType:DataType, offset:Int = 0) {
        if (Int64.is(value)) {
            var int64:Int64 = value;
            module.setValue(
                nativePointer + offset,
                int64.low,
                EmDataType.toLLVMType(DataType.SInt32)
            );
            module.setValue(
                nativePointer + offset + 4,
                int64.high,
                EmDataType.toLLVMType(DataType.SInt32)
            );
        } else {
            module.setValue(
                nativePointer + offset,
                value,
                EmDataType.toLLVMType(dataType)
            );
        }
    }

    public function arrayGet(dataType:DataType, index:Int):Any {
        return get(dataType, index * EmDataType.getSize(dataType));
    }

    public function arraySet(value:Any, dataType:DataType, index:Int) {
        set(value, dataType, index * EmDataType.getSize(dataType));
    }
}
