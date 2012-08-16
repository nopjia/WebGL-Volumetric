#ifdef GL_ES
precision highp float;
#endif

//---------------------------------------------------------
// MACROS
//---------------------------------------------------------

#define EPS       0.0001
#define PI        3.14159265
#define HALFPI    1.57079633
#define ROOTTHREE 0.57735027

#define EQUALS(A,B) ( abs((A)-(B)) < EPS )
#define EQUALSZERO(A) ( ((A)<EPS) && ((A)>-EPS) )

#define MAX_STEPS 64.0
#define STEP_SIZE 0.015625

#define MAX_STEPS 32.0
#define STEP_SIZE 0.03125

//---------------------------------------------------------
// SHADER VARS
//---------------------------------------------------------

varying vec2 vUv;
varying vec3 vPos0; // position in world coords
varying vec3 vPos1; // position in object coords
varying vec3 vPos1n; // normalized 0 to 1, for texture lookup

uniform vec3 uCamCenter;
uniform vec3 uCamPos;
uniform vec3 uCamUp;

uniform vec3 uLightP[2];  // point lights
uniform vec3 uLightC[2];

uniform vec3 uColor;      // color of volume
uniform sampler2D uTex;   // 3D(2D) volume texture
uniform vec3 uTexDim;     // dimensions of texture


//---------------------------------------------------------
// PROGRAM
//---------------------------------------------------------

float sampleVolTex(vec3 pos) {  
  // note: z is up in 3D tex coords, pos.z is tex.y, pos.y is zSlice
  float zSlice = (1.0-pos.y)*(uTexDim.z-1.0);   // float value of slice number, slice 0th to 63rd
  
  // calc pixels from top of texture
  float fromTopPixels =
    floor(zSlice)*uTexDim.y +   // offset pix from top of tex, from upper slice  
    pos.z*(uTexDim.y-1.0) +     // y pos in pixels, range 0th to 63rd pix
    0.5;  // offset to center of cell
    
  // calc y tex coords of two slices
  float y0 = min( (fromTopPixels)/(uTexDim.y*uTexDim.z), 1.0);
  float y1 = min( (fromTopPixels+uTexDim.y)/(uTexDim.y*uTexDim.z), 1.0);
    
  // get (bi)linear interped texture reads at two slices
  float z0 = texture2D(uTex, vec2(pos.x, y0)).g;
  float z1 = texture2D(uTex, vec2(pos.x, y1)).g;
  
  // lerp them again (thus trilinear), using remaining fraction of zSlice
  return mix(z0, z1, fract(zSlice));
}

vec4 raymarch(vec3 ro, vec3 rd) {
  vec4 col = vec4(0.0);
  
  for (float i=0.0; i<MAX_STEPS; ++i) {
    vec3 pos = ro + rd*STEP_SIZE*i;
    float a = sampleVolTex(pos)*STEP_SIZE;
    col.a += a;
  }
  
  col.rgb += uColor;
  
  return col;  
}

void main() {
  // in world coords, just for now
  vec3 ro = vPos1n;
  vec3 rd = normalize(ro-uCamPos);
  
  vec4 col = raymarch(ro,rd);
  
  gl_FragColor = col;
  // gl_FragColor = vec4( vec3(sampleVolTex(vPos1n)), 1.0);
  // gl_FragColor = vec4(vPos1n, 1.0);
}