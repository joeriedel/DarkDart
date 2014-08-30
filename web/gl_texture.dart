library gl_texture;
import 'dart:typed_data';
import 'dart:web_gl' as webgl;

abstract class GLTexture {
  
  final webgl.RenderingContext gl;
  final webgl.Texture texture;
  
  GLTexture(webgl.RenderingContext gl) :
    gl = gl,
    texture = gl.createTexture();
}

class GLTexture2D extends GLTexture {
  
  final int width;
  final int height;
    
  GLTexture2D(webgl.RenderingContext gl, this.width, this.height) : super(gl);
  
  void uploadTyped(int levelOfDetail, int internalFormat, int format, int type, TypedData data) {
    gl.bindTexture(webgl.TEXTURE_2D, texture);
    gl.texImage2DTyped(webgl.TEXTURE_2D, levelOfDetail, internalFormat, width, height, 0, format, type, data);
  }
}