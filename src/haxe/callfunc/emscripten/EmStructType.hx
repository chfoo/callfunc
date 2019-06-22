package callfunc.emscripten;

class EmStructType implements StructType {
    public var size(get, never):Int;
    public var dataTypes(get, never):Array<DataType>;
    public var offsets(get, never):Array<Int>;

    final _size:Int;
    final _dataTypes:Array<DataType>;
    final _offsets:Array<Int>;

    public function new(dataTypes:Array<DataType>) {
        this._dataTypes = dataTypes;
        _offsets = [];

        var offset = 0;

        for (dataType in dataTypes) {
            var size = EmDataType.getSize(dataType);

            while (offset % size != 0) {
                offset += 1;
            }

            _offsets.push(offset);
            offset += size;
        }

        _size = offset;
    }

    function get_size() {
        return _size;
    }

    function get_dataTypes() {
        return _dataTypes;
    }

    function get_offsets() {
        return _offsets;
    }

    public function dispose() {
        // nothing;
    }
}
