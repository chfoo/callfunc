package callfunc;

interface StructType extends Disposable {
    public var size(get, never):Int;
    public var dataTypes(get, never):Array<DataType>;
    public var offsets(get, never):Array<Int>;
}
