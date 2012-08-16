#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUv;
varying vec3 vPos0;
varying vec3 vPos1;

void main()
{
  vUv = uv;
  gl_Position = projectionMatrix *
                modelViewMatrix *
                vec4(position,1.0);
  vPos0 = ( objectMatrix * vec4(position, 1.0) ).xyz;
  vPos1 = position;
}