library gob;
import 'dart:typed_data';
import 'dart:collection';
import 'dart:async';
import 'files.dart';
import 'byte_stream.dart';

Future openGOB(String url) {
  Completer completer = new Completer();
  
  if (_openGOBs.containsKey(url)) {
    new Future(completer.complete);
    return completer.future;
  }
  
  //print('Opening ${url}...');
  _GOB.open(url).then((gob) {
    _openGOBs[url] = gob;
    completer.complete();
  })
  .catchError(completer.completeError);
  
  return completer.future;
}

Future<ByteBuffer> getGOBFile(String name) {
  
  _GOBEntry entry = _gobFiles[name.toUpperCase()];
  if (entry == null) {
    return new Future(() => throw new Exception('$name is not in any open GOB files.'));
  }
  
  return entry.gob.file.read(entry.ofs, entry.length);
}

void printGOBFiles() {
  _gobFiles.forEach((K, V) => print(K));
}

HashMap _openGOBs = new HashMap(); // holds _GOBs
HashMap _gobFiles = new HashMap(); // holds _GOBEntrys

class _GOBEntry {
  final int ofs;
  final int length;
  final String name;
  final _GOB gob;
  
  _GOBEntry(this.gob, this.name, this.ofs, this.length);
}

class _GOB {
  final File file;
  HashMap _dir = new HashMap();
  
  _GOB._construct(this.file);
  
  void printDir() {
    _dir.forEach((K, V) => print(K));
  }
  
  static Future open(String url) {
    Completer completer = new Completer();
    
    File.open(url).then((file) {
      _getDirOfs(file).then((dirOfs) {
        _getNumFiles(file, dirOfs).then((numFiles) {
          _getGOBDir(file, dirOfs, numFiles, completer);
        })
        .catchError(completer.completeError);
      })
      .catchError(completer.completeError);
    })
    .catchError(completer.completeError);
    
    return completer.future;
  }
  
  static Future<int> _getDirOfs(File file) {
    Completer completer = new Completer();
    
    file.read(0, 8).then((buffer) {
      var bytes = new ByteStream.fromByteBuffer(buffer);
      String id = bytes.getChars(3);
      if (id != 'GOB') {
        throw new FormatException('Not a GOB file.');
      }
      if (bytes.getUInt8() != 0xA) {
        throw new FormatException('Not a GOB file (0xA).');
      }
      int dirOfs = bytes.getUInt32();
      
      completer.complete(dirOfs);
    })
    .catchError(completer.completeError);
    
    return completer.future;
  }
  
  static Future<int> _getNumFiles(File file, int dirOfs) {
    Completer completer = new Completer();
    
    file.read(dirOfs, 4).then((buffer) {
      var bytes = new ByteStream.fromByteBuffer(buffer);
      int numFiles = bytes.getUInt32();
      completer.complete(numFiles);
    })
    .catchError(completer.completeError);
    
    return completer.future;
  }
  
  static void _getGOBDir(File file, int dirOfs, int numFiles, Completer completer) {
    // GOB entry is 21 bytes
    file.read(dirOfs+4, numFiles*21).then((buffer) {
      ByteStream bytes = new ByteStream.fromByteBuffer(buffer);
      _GOB gob = new _GOB._construct(file);
      for (var i = 0; i < numFiles; ++i) {
        _GOBEntry entry = _readGOBEntry(gob, bytes);
        gob._dir[entry.name]= entry;
        _gobFiles[entry.name] = entry;
      }
      
      print('${file.url} opened with $numFiles file(s).');
      completer.complete();
    })
    .catchError(completer.completeError);
  }
  
  static _GOBEntry _readGOBEntry(_GOB gob, ByteStream bytes) {
    int ofs = bytes.getUInt32();
    int length = bytes.getUInt32();
    String name = bytes.getChars(13).toUpperCase();
    return new _GOBEntry(gob, name, ofs, length);
  }
}