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


//---------------------------------------------------------
// CONSTANTS
//---------------------------------------------------------

#define MAX_STEPS 64
#define STEP_SIZE 0.015625

//#define MAX_STEPS 32
//#define STEP_SIZE 0.03125

#define LIGHT_NUM 2


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

uniform vec3 uLightP[LIGHT_NUM];  // point lights
uniform vec3 uLightC[LIGHT_NUM];

uniform vec3 uColor;      // color of volume
uniform sampler2D uTex;   // 3D(2D) volume texture
uniform vec3 uTexDim;     // dimensions of texture


//---------------------------------------------------------
// PROGRAM
//---------------------------------------------------------

// TODO: convert world to local volume space
vec3 toLocal(vec3 p) {
  return p + vec3(0.5);
}

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

// calc density by ray marching
float getDensity(vec3 ro, vec3 rd) {
  vec3 step = rd*STEP_SIZE;
  vec3 pos = ro;
  
  float density = 0.0;
  
  for (int i=0; i<MAX_STEPS; ++i) {    
    density += (1.0-density) * sampleVolTex(pos)*STEP_SIZE;
    
    pos += step;
    
    if (density > 0.95 ||
      pos.x > 1.0 || pos.x < 0.0 ||
      pos.y > 1.0 || pos.y < 0.0 ||
      pos.z > 1.0 || pos.z < 0.0)
      break;
  }
  
  return density;
}

vec4 raymarch(vec3 ro, vec3 rd) {
  vec3 step = rd*STEP_SIZE;
  vec3 pos = ro;
  
  vec4 cout = vec4(0.0);
  
  for (int i=0; i<MAX_STEPS; ++i) {
    // sample density
    float density = 5.0*sampleVolTex(pos);
    
    // sample light, compute color
    vec3 color = vec3(0.0);
    for (int k=0; k<1; ++k) {
      vec3 ld = normalize( toLocal(uLightP[k]) - pos );
      float lfog = 2.0*getDensity(pos, ld);
      
      vec3 lightc = uLightC[k]*(1.0-lfog);
      color += lightc * uColor * STEP_SIZE;
    }
    
    //vec3 testcol = vec3(1.0, 0.0, 0.0);
    ////color = (pos.y>0.75 || pos.y<0.25) ? testcol : uColor;
    //color = mix(testcol, uColor, pos.y);
    
    cout.rgb += (1.0-cout.a) * color;
    cout.a += (1.0-cout.a) * density * STEP_SIZE;
    
    pos += step;
    
    if (cout.a > 0.95 ||
      pos.x > 1.0 || pos.x < 0.0 ||
      pos.y > 1.0 || pos.y < 0.0 ||
      pos.z > 1.0 || pos.z < 0.0)
      break;
  }
  
  return cout;
}

void main() {
  // in world coords, just for now
  vec3 ro = vPos1n;
  vec3 rd = normalize( ro - toLocal(uCamPos) );
  //vec3 rd = normalize(ro-uCamPos);
  
  gl_FragColor = raymarch(ro, rd);
  // gl_FragColor = vec4(uColor, getDensity(ro,rd));
  // gl_FragColor = vec4( vec3(sampleVolTex(vPos1n)), 1.0);
  // gl_FragColor = vec4(vPos1n, 1.0);
  // gl_FragColor = vec4(uLightP[0], 1.0);
}