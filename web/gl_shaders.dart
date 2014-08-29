import 'dart:web_gl' as webgl;

class GLShaders {
  static const int UNSHADED_ONE_TEXTURE = 0;
  final List<GLShader> S;  
  
  GLShaders(webgl.RenderingContext gl) :
    S = [
          _genUnshadedOneTexture(gl)
        ];
  
  operator [] (int index) => S[index];
  
  static GLShader _genUnshadedOneTexture(webgl.RenderingContext gl) {
    return new GLShader.fromStrings(gl,
        """
        uniform mat4 u_mvp;

        attribute vec4 v_vertex0;
        attribute vec2 v_texcoord0;

        varying vec2 f_texcoord0;
        
        void main(void) {
          gl_Position = u_mvp * v_vertex0;
          f_texcoord0 = v_texcoord0;
        }
        """,
        """
        precision highp float;

        varying vec2 f_texcoord0;

        uniform sampler2D u_t0;

        void main(void) {
          gl_FragColor = texture2D(u_t0, f_texcoord0);
        }
        """
        );
  }
}

class GLShader {
  final webgl.UniformLocation umvp;
  final webgl.Program program;
  
  GLShader(webgl.RenderingContext gl, webgl.Program program) :
    this.program = program,
    this.umvp = gl.getUniformLocation(program, "umvp");
  
  GLShader.fromStrings(webgl.RenderingContext gl, String vertexShader, String fragmentShader) :
    this(gl, glCreateProgramFromStrings(gl, vertexShader, fragmentShader));
}

webgl.Program glCreateProgramFromStrings(webgl.RenderingContext gl, String vertexShaderString, String fragmentShaderString) {
  webgl.Shader vertexShader = glCreateShaderChecked(gl, webgl.RenderingContext.VERTEX_SHADER, vertexShaderString);
  webgl.Shader fragmentShader = glCreateShaderChecked(gl, webgl.RenderingContext.FRAGMENT_SHADER, fragmentShaderString);
  return glCreateProgramChecked(gl, vertexShader, fragmentShader);
}

webgl.Shader glCreateShaderChecked(webgl.RenderingContext gl, int type, String source) {
  var shader = glCreateShader(gl, type, source);
  glCheckShader(gl, shader);
  return shader;
}

webgl.Shader glCreateShader(webgl.RenderingContext gl, int type, String source) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  return shader;
}

webgl.Program glCreateProgramChecked(webgl.RenderingContext gl, webgl.Shader vertexShader, webgl.Shader fragmentShader) {
  var program = glCreateProgram(gl, vertexShader, fragmentShader);
  glCheckProgram(gl, program);
  return program;
}

webgl.Program glCreateProgram(webgl.RenderingContext gl, webgl.Shader vertexShader, webgl.Shader fragmentShader) {
  var program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  return program;
}

void glCheckProgram(webgl.RenderingContext gl, webgl.Program program) {
  gl.useProgram(program);
  if (!gl.getProgramParameter(program, webgl.RenderingContext.LINK_STATUS)) {
    print(gl.getProgramInfoLog(program));
    throw new Exception("glCheckProgram - FAILED");
  }
}

void glCheckShader(webgl.RenderingContext gl, webgl.Shader shader) {
  if (!gl.getShaderParameter(shader, webgl.RenderingContext.COMPILE_STATUS)) {
    print(gl.getShaderInfoLog(shader));
    throw new Exception("glCheckShader - FAILED");
  }
}