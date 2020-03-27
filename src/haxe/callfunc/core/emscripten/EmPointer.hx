package callfunc.core.emscripten;

import callfunc.core.serialization.NumberUtil;
import haxe.Int64;

using callfunc.core.emscripten.ModuleTools;
using callfunc.core.DataTypeTools;

class EmPointer implements BasicPointer {
    public var address(get, never):Int64;

    final _address:Int64;
    public final nativePointer:Int;
    final context:EmContext;

    public function new(context:EmContext, nativePointer:Int) {
        this.context = context;
        this.nativePointer = nativePointer;
        _address = Int64.fromFloat(nativePointer);
    }

    function get_address() {
        return _address;
    }

    public function get(dataType:DataType, offset:Int = 0):Any {
        final coreDataType = context.coreDataTypeTable.toCoreDataType(dataType, true);

        switch coreDataType {
            case SInt64 | UInt64: return getInt64(offset);
            case Void: throw "Void is only for function definition";
            default: // pass
        }

        var value = context.module.getValue(
            nativePointer + offset,
            EmDataType.toLLVMType(dataType)
        );

        switch coreDataType {
            case UInt8: value = NumberUtil.intToUInt8(value);
            case UInt16: value = NumberUtil.intToUInt16(value);
            case UInt32: value = NumberUtil.intToUInt(value);
            default: // pass
        }

        return value;
    }

    function getInt64(offset:Int) {
        return Int64.make(
            context.module.getValue(
                nativePointer + offset + 4,
                EmDataType.toLLVMType(DataType.SInt32)
            ),
            context.module.getValue(
                nativePointer + offset,
                EmDataType.toLLVMType(DataType.SInt32)
            )
        );
    }

    public function set(value:Any, dataType:DataType, offset:Int = 0) {
        switch context.coreDataTypeTable.toCoreDataType(dataType, true) {
            case SInt64 | UInt64:
                setInt64(NumberUtil.toInt64(value), offset);
            default:
                context.module.setValue(
                    nativePointer + offset,
                    value,
                    EmDataType.toLLVMType(dataType)
                );
        }
    }

    function setInt64(value:Int64, offset:Int) {
        context.module.setValue(
            nativePointer + offset,
            value.low,
            EmDataType.toLLVMType(DataType.SInt32)
        );
        context.module.setValue(
            nativePointer + offset + 4,
            value.high,
            EmDataType.toLLVMType(DataType.SInt32)
        );
    }

    public function arrayGet(index:Int, dataType:DataType):Any {
        return get(dataType, index * EmDataType.getSize(dataType));
    }

    public function arraySet(index:Int, value:Any, dataType:DataType) {
        set(value, dataType, index * EmDataType.getSize(dataType));
    }
}
