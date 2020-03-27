package callfunc;

import callfunc.core.CoreDataTypeTable;
using haxe.EnumTools;

class ListDataTypes {
    public static function main() {
        final ffi = Callfunc.instance();

        final dataTypes:Array<DataType> = [
            Void,
            UInt8,
            SInt8,
            UInt16,
            SInt16,
            UInt32,
            SInt32,
            UInt64,
            SInt64,
            Float,
            Double,
            UChar,
            SChar,
            UShort,
            SShort,
            SInt,
            UInt,
            SLong,
            ULong,
            Pointer,
            LongDouble,
            ComplexFloat,
            ComplexDouble,
            ComplexLongDouble,
            Size,
            PtrDiff,
            WChar,
            Struct([]),
        ];

        final table = new CoreDataTypeTable(ffi.context);
        final stdout = Sys.stdout();

        for (dataType in dataTypes) {
            stdout.writeString('data type ${dataType.getName()}\n');
            try {
                stdout.writeString('  bytes wide ${ffi.sizeOf(dataType)} \n');
            } catch (exception:Any) {
                stdout.writeString('  no size\n');
            }

            try {
                stdout.writeString('  core type ${CoreDataType.getName(table.toCoreDataType(dataType, false))}\n');
                stdout.writeString('            ${CoreDataType.getName(table.toCoreDataType(dataType, true))}\n');
            } catch (exception:Any) {
                stdout.writeString('  no core type\n');
            }
        }
    }
}
