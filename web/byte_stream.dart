library byte_stream;
import 'dart:typed_data';

class ByteStream {
   final ByteData bytes;
   int ofs;
   final Endianness _E;
   
   ByteStream.fromByteData(this.bytes, [Endianness endian = Endianness.LITTLE_ENDIAN]) : ofs = 0, _E = endian;
   ByteStream.fromByteBuffer(ByteBuffer buffer, [Endianness endian = Endianness.LITTLE_ENDIAN]) : this.fromByteData(new ByteData.view(buffer), endian);
   
   int _inc(int size) {
    int pos = ofs;
    ofs += size;
    return pos;
   }
   
   bool get eos => ofs >= bytes.lengthInBytes;
   int get length => bytes.lengthInBytes;
   
   int getInt8() {
     return bytes.getInt8(_inc(1));
   }
   
   int getUInt8() {
     return bytes.getUint8(_inc(1));
   }
   
   int getInt16() {
     return bytes.getInt16(_inc(2), _E);
   }
   
   int getUInt16() {
     return bytes.getUint16(_inc(2), _E);
   }
   
   int getInt32() {
     return bytes.getInt32(_inc(4), _E);
   }
   
   int getUInt32() {
     return bytes.getUint32(_inc(4), _E);
   }
   
   String getChars(int len) {
     var buffer = new StringBuffer();
     var end = false;
     
     for (var i = 0; i < len; ++i) {
       int code = getUInt8();
       end = end || (code == 0);
       
       if (!end) {
        buffer.writeCharCode(code);
       }
     }
     
     return buffer.toString();
   }
}