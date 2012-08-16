#ifdef GL_ES
precision highp float;
#endif

//---------------------------------------------------------
// CONSTANTS
//---------------------------------------------------------
#define EPS       0.0001
#define PI        3.14159265
#define HALFPI    1.57079633
#define ROOTTHREE 0.57735027

//---------------------------------------------------------
// MACROS
//---------------------------------------------------------
#define EQUALS(A,B) (abs(A-B)<EPS)

varying vec2 vUv;
varying vec3 vPos0; // position in world coords
varying vec3 vPos1; // position in object coords
varying vec3 vPos1n; // normalized 0 to 1, for texture lookup

uniform vec3 uCamCenter;
uniform vec3 uCamPos;
uniform vec3 uCamUp;

uniform sampler2D uTex;
uniform vec3 uTexDim;

bool equals(float a, float b) {
  return abs(a-b) < EPS;
}

float sampleVolTex(vec3 pos) {
  float zSlice = (pos.z)*(uTexDim.z-1.0);   // float value of slice number, slice 0th to 63rd
  
  // calc y tex coord  
  float offsetPixels = floor(zSlice)*uTexDim.y;  // offset pixels from top of texture, upper slice
  float yposPixels = pos.y*(uTexDim.y-1.0);  // y position in pixels, pix 0th to 63rd
  
  float y0 = min( (offsetPixels+yposPixels+0.5)/(uTexDim.y*uTexDim.z), 1.0);
  float y1 = min( (offsetPixels+yposPixels+uTexDim.y+0.5)/(uTexDim.y*uTexDim.z), 1.0);
    
  // (bi)linear interped val at two slices
  float z0 = texture2D(uTex, vec2(pos.x, y0)).g;
  float z1 = texture2D(uTex, vec2(pos.x, y1)).g;
  
  // questionable?
  if EQUALS(pos.z,1.0)
    return z0;
  else
    // lerp them, for trilinear, using remaining fraction of zSlice
    return mix(z0, z1, fract(zSlice));
}

void main() {
  // world coords
  vec3 P = vPos0;
  vec3 R = normalize(P-uCamPos);
  
  
  
  gl_FragColor = vec4( vec3(sampleVolTex(vPos1n)), 1.0);
  // gl_FragColor = vec4(vPos1n, 1.0);
}