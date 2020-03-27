package randomexample;

import callfunc.AnyInt;
import callfunc.Callfunc;
import callfunc.DataType;
import haxe.ds.Option;
import haxe.io.Bytes;

// This example shows how to obtain random bytes from the OS using system
// libraries.
class RandomExample {
    static final bufferLength = 16;
    static final ffi = Callfunc.instance();

    public static function main() {
        final systemName = Sys.systemName();
        var result;

        quickLog('Operating System: $systemName');

        switch systemName {
            case "Windows":
                result = getWindowsBytes();
            case "Linux":
                result = getLinuxBytes();
            case "Mac":
                result = getMacBytes();
            default:
                quickLog("Unsupported OS.");
                Sys.exit(1);
                return;
        }

        switch result {
            case Some(bytes):
                quickLog("OK");
                final stdOut = Sys.stdout();
                stdOut.writeString(bytes.toHex());
                stdOut.writeString("\n");
                quickLog("Done. Goodbye!");
            case None:
                quickLog("OS is unable to provide random bytes.");
                Sys.exit(1);
        }
    }

    static function quickLog(text:String) {
        final stdErr = Sys.stderr();
        stdErr.writeString(text);
        stdErr.writeString("\n");
    }

    static function getWindowsBytes():Option<Bytes> {
        final STDCALL = 2;
        final library = ffi.openLibrary("Advapi32.dll");

        library.define(
            "SystemFunction036",
            [DataType.Pointer, DataType.ULong],
            DataType.SInt,
            STDCALL
        );

        final buffer = ffi.alloc(bufferLength);
        final result = library.s.SystemFunction036.call(buffer, bufferLength);
        var bytes;

        if (result == 1) {
            bytes = Some(buffer.getDataView(bufferLength).toBytes());
        } else {
            bytes = None;
        }

        buffer.free();
        library.dispose();
        return bytes;
    }

    static function getLinuxBytes():Option<Bytes> {
        final library = ffi.openLibrary("libc.so.6");

        library.define(
            "getrandom",
            [DataType.Pointer, DataType.Size, DataType.UInt],
            DataType.Size
        );

        final buffer = ffi.alloc(bufferLength);
        final result:AnyInt = library.s.getrandom.call(buffer, bufferLength, 0);
        var bytes;

        if (result.toInt() == bufferLength) {
            bytes = Some(buffer.getDataView(bufferLength).toBytes());
        } else {
            bytes = None;
        }

        buffer.free();
        library.dispose();
        return bytes;
    }

    static function getMacBytes():Option<Bytes> {
        final library = ffi.openLibrary("libSystem.dylib");

        library.define(
            "arc4random_buf",
            [DataType.Pointer, DataType.Size]
        );

        final buffer = ffi.alloc(bufferLength);
        library.s.arc4random_buf.call(buffer, bufferLength);

        final bytes =  Some(buffer.getDataView(bufferLength).toBytes());

        buffer.free();
        library.dispose();
        return bytes;
    }
}
