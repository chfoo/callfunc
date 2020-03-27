package callfunc.core;

import haxe.ds.Vector;

/**
 * Table of mappings from DataType to CoreDataType.
 */
class CoreDataTypeTable {
    final context:Context;
    final table:Vector<CoreDataType>;
    final tableValid:Vector<Bool>;
    final fixedWidthTable:Vector<CoreDataType>;
    final fixedWidthTableValid:Vector<Bool>;

    public function new(context:Context) {
        this.context = context;
        final size = 28;
        table = new Vector(size);
        tableValid = new Vector(size);
        fixedWidthTable = new Vector(size);
        fixedWidthTableValid = new Vector(size);

        populateTables();
    }

    function populateTables() {
        final enumValues:Array<DataType> = [
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

        for (index in 0...enumValues.length) {
            try {
                table[index] = DataTypeTools.toCoreDataType(context, enumValues[index], false);
                tableValid[index] = true;
            } catch (exception:String) {
                tableValid[index] = false;
            }

            try {
                fixedWidthTable[index] = DataTypeTools.toCoreDataType(context, enumValues[index], true);
                fixedWidthTableValid[index] = true;
            } catch (exception:String) {
                fixedWidthTableValid[index] = false;
            }
        }
    }

    /**
     * Converts data type to a appropriate core data type.
     *
     * @param dataType
     * @param fixedWidth Whether integer data types are substituted to their
     *     fixed-width data types. If the data type is not an integer, it is left unchanged.
     * @throws String If the data type is not a supported core data type.
     */
    public function toCoreDataType(dataType:DataType,
            fixedWidth:Bool = false):CoreDataType {
        final table:Vector<CoreDataType> = fixedWidth ? fixedWidthTable : this.table;
        final valid:Vector<Bool> = fixedWidth ? fixedWidthTableValid : tableValid;
        var index:Int;

        switch dataType {
            case Void: index = 0;
            case UInt8: index = 1;
            case SInt8: index = 2;
            case UInt16: index = 3;
            case SInt16: index = 4;
            case UInt32: index = 5;
            case SInt32: index = 6;
            case UInt64: index = 7;
            case SInt64: index = 8;
            case Float: index = 9;
            case Double: index = 10;
            case UChar: index = 11;
            case SChar: index = 12;
            case UShort: index = 13;
            case SShort: index = 14;
            case SInt: index = 15;
            case UInt: index = 16;
            case SLong: index = 17;
            case ULong: index = 18;
            case Pointer: index = 19;
            case LongDouble: index = 20;
            case ComplexFloat: index = 21;
            case ComplexDouble: index = 22;
            case ComplexLongDouble: index = 23;
            case Size: index = 24;
            case PtrDiff: index = 25;
            case WChar: index = 26;
            case Struct(fields): index = 27;
        }

        if (valid[index]) {
            return table[index];
        } else {
            throw 'Unable to convert DataType $dataType to CoreDataType';
        }
    }
}
