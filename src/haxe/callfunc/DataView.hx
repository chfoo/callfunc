package callfunc;

import haxe.io.Encoding;
import haxe.Int64;
import haxe.io.ArrayBufferView;
import haxe.io.Bytes;

using callfunc.BytesTools;

/**
 * Provides an abstract view to Bytes.
 *
 * The get and set integer methods use signed/unsigned N-bit values.
 * Float and double numbers are 32- and 64-bit values respectively.
 * The position is defined as the offset from the start of the view.
 *
 * Protection against out-of-bounds is not guaranteed and is not mandatory
 * for implementations.
 */
interface DataView {
    /**
     * Underlying byte array
     */
    public var buffer(get, never):Any;

    /**
     * Number of bytes this view represents.
     */
    public var byteLength(get, never):Int;

    /**
     * Absolute index position of the buffer in which this view represents
     * as index 0.
     */
    public var byteOffset(get, never):Int;

    // TODO: endian support

    /**
     * @see `DataView.getUInt8()`
     */
    public function get(position:Int):Int;

    /**
     * @see `DataView.setUInt8()`
     */
    public function set(position:Int, value:Int):Void;

    public function getUInt8(position:Int):Int;

    public function setUInt8(position:Int, value:Int):Void;

    public function getInt8(position:Int):Int;

    public function setInt8(position:Int, value:Int):Void;

    public function getUInt16(position:Int):Int;

    public function setUInt16(position:Int, value:Int):Void;

    public function getInt16(position:Int):Int;

    public function setInt16(position:Int, value:Int):Void;

    public function getUInt32(position:Int):UInt;

    public function setUInt32(position:Int, value:UInt):Void;

    public function getInt32(position:Int):Int;

    public function setInt32(position:Int, value:Int):Void;

    public function getInt64(position:Int):Int64;

    public function setInt64(position:Int, value:Int64):Void;

    public function getFloat(position:Int):Float;

    public function setFloat(position:Int, value:Float):Void;

    public function getDouble(position:Int):Float;

    public function setDouble(position:Int, value:Float):Void;

    /**
     * Copy data from another view into this view.
     *
     * @param position Number of bytes offset from the start of the view.
     * @param source The view in which data is copied from.
     * @param sourcePosition Number of bytes offset from the start of the source
     *     view.
     * @param sourceLength Number of bytes to be copied from the source. If not
     *     given, defaults to length of source.
     */
    public function blit(position:Int, source:DataView, sourcePosition:Int = 0,
            ?sourceLength:Int):Void;

    /**
     * Copies data from Bytes to this view.
     *
     * @see `DataView.blit()`.
     */
    public function blitBytes(position:Int, source:Bytes, sourcePosition:Int = 0,
            ?sourceLength:Int):Void;

    /**
     * Sets bytes to given value.
     */
    public function fill(pos:Int, len:Int, value:Int):Void;

    /**
     * Returns a subsection of the current view.
     */
    public function sub(position:Int, length:Int):DataView;

    /**
     * Returns a copy of data to Bytes.
     */
    public function toBytes(position:Int = 0, ?length:Int):Bytes;

    /**
     * Returns a decoded string.
     */
    public function getString(pos:Int, len:Int, ?encoding:Encoding):String;

    /**
     * Encodes a string.
     */
    public function setString(position:Int, string:String, ?encoding:Encoding):Void;
}
