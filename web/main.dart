import 'dart:html';
import 'dart:typed_data';
import 'dart:math' show Random;
import 'dart:web_gl' as webgl;
//import 'package:vector_math/vector_math.dart';
import 'gl_canvas.dart';
import 'gob.dart';

void checkRequirements() {
  print('Checking server support of partial HTTP GET...');
  HttpRequest req = new HttpRequest();
  req..open('GET', 'http://www.joecodegood.net/darkdart/lorum.txt')
     ..setRequestHeader('Range', 'bytes=0-499')
     ..setRequestHeader('Cache-Control', 'no-cache')
     ..onLoadEnd.listen((e) {
        print(req.status);
        print(req.statusText);
        if ((req.status == 200) || (req.status == 206)) {
          print(req.responseHeaders);
          String responseType = req.responseType;
          if ((responseType == "") || (responseType == 'string')) {
            int length = req.responseText.length;
            print('Received $length');
            //print(req.responseText);
            if (length == 500) {
              return;
            }
          } else if (responseType == 'arraybuffer') {
            ByteBuffer bytes = req.response;
            int length = bytes.lengthInBytes;
            print('Received $length');
            if (length == 500) {
              return;
            }
          } else if (responseType == 'blob') {
            Blob blob = req.response;
            int length = blob.size;
            print('Received $length');
            if (length == 500) {
              return;
            }
          }
        }
        throw new Exception('Server must support partial HTTP GET!');
      })
     ..send('');
}

void checkRequirements2() {
  HttpRequest req = new HttpRequest();
  req..open('HEAD', 'http://www.joecodegood.net/darkdart/DARK.GOB')
     ..onLoadEnd.listen((value) {
        print(req.status);
        print(req.statusText);
        if ((req.status == 200) || (req.status == 206)) {
          print(req.responseHeaders);
        }
      })
     ..send('');
}

class MainLoop {
  final GLCanvas glCanvas;
  
  MainLoop(this.glCanvas);
  
  void start() {
    window.animationFrame.then(_update);
  }
  
  void _update(double time) {
    glCanvas.setViewport();
    glCanvas.gl.clearColor(0, 0, 0, 1);
    glCanvas.gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);
    window.animationFrame.then(_update);
  }
}

void _startMainLoop() {
  CanvasElement canvas = document.getElementById("gameViewport");
    GLCanvas glCanvas = new GLCanvas(canvas);
    
    MainLoop refresh = new MainLoop(glCanvas);
    refresh.start();
}

void main() {
  print("Entering main...");
  //checkRequirements();
  openGOB('/DARK.GOB')
    .then((_) => openGOB('/SOUNDS.GOB'))
    .then((_) => openGOB('/SPRITES.GOB'))
    .then((_) => openGOB('/TEXTURES.GOB'))
    .then((_) {
      //printGOBFiles();
      _startMainLoop();
    });
  
  //checkRequirements2();
  //HttpRequest.getString("files/myfile.txt").then((String fileContents) { print(fileContents); });
}