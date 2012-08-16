#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUv;
varying vec3 vPos0; // position in world coords
varying vec3 vPos1; // position in object coords

uniform vec3 uCamCenter;
uniform vec3 uCamPos;
uniform vec3 uCamUp;
uniform mat4 uObjectMatrixInverse;

void main() {
  // world coords
  vec3 R0 = vPos0;
  vec3 R1 = normalize(R0-uCamPos);
  
  gl_FragColor = vec4(vPos0, 1.0);
}