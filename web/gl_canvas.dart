library gl_canvas;
import 'dart:html';
import 'dart:web_gl' as webgl;
import 'gl_shaders.dart';

class GLCanvas {
  
  final CanvasElement canvas;
  final webgl.RenderingContext gl;
  
  GLShaders get shaders => _shaders;
  
  GLShaders _shaders;
  
  GLCanvas(CanvasElement canvas) :
    canvas = canvas,
    gl = canvas.getContext('webgl', {'alpha' : true, 'premultipliedAlpha' : false}) {
    _shaders = new GLShaders(gl);
    window.onResize.listen(_handleResizeEvent);
  }
  
  void setViewport() {
    gl.viewport(0, 0, canvas.width, canvas.height);
  }
  
  void _handleResizeEvent(Event e) {
    _updateCanvasSize();
  }
  
  void _updateCanvasSize() {
    var clWidth = canvas.clientWidth;
    var clHeight = canvas.clientHeight;
    
    if ((clWidth != canvas.width) ||
        (clHeight != canvas.height)) {
      canvas.width = clWidth;
      canvas.height = clHeight;
      
      print("Canvas resized to ${clWidth}x${clHeight}.");
    }
  }
}