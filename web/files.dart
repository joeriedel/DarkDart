// Basic file system to make HTTP GET look more like local files when reading.
// NOTE: It's a good idea to cache this stuff since it's probably pretty slow
library files;
import 'dart:html';
import 'dart:async';
import 'dart:typed_data';

const String _BASE_URL = 'http://www.joecodegood.net/darkdart';

class File {
  
  final String url;
  final int size;
  
  static Future<File> open(String url) {
    var completer = new Completer();
    
    var req = new HttpRequest();
    // HEAD request to get file size.
    
    req
      ..open('HEAD', _BASE_URL + url)
      ..onLoadEnd.listen((_) {
        //print('${req.status} ${req.statusText} => $url');
        //print(req.responseHeaders);
        if (req.status == 200) {
          var strFileSize = req.getResponseHeader('Content-Length');
          if (strFileSize != null) {
            var fileSize = int.parse(strFileSize);
            completer.complete(new File._construct(url, fileSize));
            return;
          }
        }
        completer.completeError(req);
      })
      ..send('');
    
    return completer.future;
  }
  
  Future<ByteBuffer> read(int offset, int length) {
    if ((length < 0) || (offset < 0) || ((offset+length) > this.size)) {
      // out of bounds read
      return new Future(() => throw new Exception('File read out of bounds.'));
    }
    
    var completer = new Completer();
    var req = new HttpRequest();
    
    req
      ..open('GET', _BASE_URL + url)
      ..responseType = 'arraybuffer'
      ..setRequestHeader('Range', 'bytes=${offset}-${offset+length-1}')
      //..setRequestHeader('Cache-Control', 'no-cache')
      ..onLoadEnd.listen((_) {
          //print('${req.status} ${req.statusText} => $url');
          //print(req.responseHeaders);
          //print(req.responseType);
          if ((req.status == 200) || (req.status == 206)) {
            ByteBuffer bytes = req.response;
            var bufferLength = bytes.lengthInBytes;
            if (bufferLength == length) {
              completer.complete(bytes);
              return;
            }
          }
          completer.completeError(req);
        })
      ..send('');
    
    return completer.future;
  }
  
  File._construct(this.url, this.size);
  
}