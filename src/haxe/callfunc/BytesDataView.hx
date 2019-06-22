package callfunc;

import haxe.Int64;
import haxe.io.ArrayBufferView;
import haxe.io.Bytes;
import haxe.io.Encoding;

using callfunc.BytesTools;

/**
 * Data view using Bytes as the underlying buffer array.
 */
class BytesDataView implements DataView {
    public var buffer(get, never):Any;
    public var byteLength(get, never):Int;
    public var byteOffset(get, never):Int;

    public final bytes:Bytes;
    final _bytes:Bytes;
    final _byteLength:Int;
    final _byteOffset:Int;

    /**
     * @param bytes Underlying byte array
     * @param byteOffset Absolute index position of the buffer in which this
     *     view will represent as index 0.
     * @param byteLength Number of bytes this view will represent.
     */
    public function new(bytes:Bytes, byteOffset:Int = 0, ?byteLength:Int) {
        _bytes = this.bytes = bytes;
        _byteOffset = byteOffset;
        _byteLength = byteLength != null ? byteLength : bytes.length;
    }

    /**
     * Create a new buffer and return a view to it.
     * @param size Number of bytes.
     */
    public static function alloc(size:Int):DataView {
        return new BytesDataView(Bytes.alloc(size));
    }

    /**
     * Convert from ArrayBufferView.
     */
    public static function fromArrayBufferView(view:ArrayBufferView):DataView {
        return new BytesDataView(view.buffer, view.byteOffset, view.byteLength);
    }

    function get_buffer():Any {
        return _bytes;
    }

    function get_byteOffset():Int {
        return _byteOffset;
    }

   function get_byteLength():Int {
       return _byteLength;
   }

    public function get(position:Int):Int {
        return _bytes.get(_byteOffset + position);
    }

    public function set(position:Int, value:Int) {
        _bytes.set(_byteOffset + position, value);
    }

    public function getUInt8(position:Int):Int {
        return get(position);
    }

    public function setUInt8(position:Int, value:Int) {
        set(position, value);
    }

    public function getInt8(position:Int):Int {
        return _bytes.getSInt8(_byteOffset + position);
    }

    public function setInt8(position:Int, value:Int) {
        set(position, value);
    }

    public function getUInt16(position:Int):Int {
        return _bytes.getUInt16(_byteOffset + position);
    }

    public function setUInt16(position:Int, value:Int) {
        _bytes.setUInt16(_byteOffset + position, value);
    }

    public function getInt16(position:Int):Int {
        return _bytes.getSInt16(_byteOffset + position);
    }

    public function setInt16(position:Int, value:Int) {
        _bytes.setUInt16(_byteOffset + position, value);
    }

    public function getUInt32(position:Int):UInt {
        return _bytes.getInt32(_byteOffset + position);
    }

    public function setUInt32(position:Int, value:UInt) {
        _bytes.setInt32(_byteOffset + position, value);
    }

    public function getInt32(position:Int):Int {
        return _bytes.getInt32(_byteOffset + position);
    }

    public function setInt32(position:Int, value:Int) {
        _bytes.setInt32(_byteOffset + position, value);
    }

    public function getInt64(position:Int):Int64 {
        return _bytes.getInt64(_byteOffset + position);
    }

    public function setInt64(position:Int, value:Int64) {
        _bytes.setInt64(_byteOffset + position, value);
    }

    public function getFloat(position:Int):Float {
        return _bytes.getFloat(_byteOffset + position);
    }

    public function setFloat(position:Int, value:Float) {
        _bytes.setFloat(_byteOffset + position, value);
    }

    public function getDouble(position:Int):Float {
        return _bytes.getDouble(_byteOffset + position);
    }

    public function setDouble(position:Int, value:Float) {
        _bytes.setDouble(_byteOffset + position, value);
    }

    public function blit(position:Int, source:DataView, sourcePosition:Int = 0,
            ?sourceLength:Int) {
        sourceLength = sourceLength != null ? sourceLength : source.byteLength;
        _bytes.blit(
            _byteOffset + position,
            source.buffer,
            source.byteOffset + sourcePosition,
            sourceLength);
    }


    public function blitBytes(position:Int, source:Bytes, sourcePosition:Int = 0,
            ?sourceLength:Int) {
        sourceLength = sourceLength != null ? sourceLength : source.length;
        _bytes.blit(
            _byteOffset + position,
            source,
            sourcePosition,
            sourceLength);
    }


    public function fill(pos:Int, len:Int, value:Int) {
        _bytes.fill(_byteOffset + pos, len, value);
    }


    public function sub(position:Int, length:Int):DataView {
        return new BytesDataView(buffer, _byteOffset + position, length);
    }

    public function toBytes(position:Int = 0, ?length:Int):Bytes {
        length = length != null ? length : byteLength;
        return _bytes.sub(_byteOffset + position, length);
    }

    public function getString(pos:Int, len:Int, ?encoding:Encoding):String {
        return _bytes.getString(_byteOffset + pos, len, encoding);
    }

    public function setString(position:Int, string:String, ?encoding:Encoding) {
        var stringBytes = Bytes.ofString(string, encoding);
        blitBytes(position, stringBytes);
    }
}
