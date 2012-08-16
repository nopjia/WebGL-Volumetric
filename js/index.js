c = {};
c.CAM_FOV  = 45;
c.CAM_NEAR = 1;
c.CAM_FAR  = 200;
c.FOG_NEAR = 10;
c.FOG_FAR  = 200;

g = {};
g.width, g.height;
g.container, g.renderer, g.scene, g.camera, g.controls;
g.uniforms;

g.lightC = [];
g.lightP = [];

g.time = 0.0;

function init() {
  // container
  g.container = document.getElementById("container");
  g.width  = window.innerWidth;
  g.height = window.innerHeight;

  // renderer
  g.renderer = new THREE.WebGLRenderer({ 
    clearAlpha: 1, 
    clearColor: 0x000000,
    antialias: true
  });
  g.renderer.setSize( g.width, g.height );
  g.renderer.autoClear = false;  
  g.container.appendChild( g.renderer.domElement );

  // camera
  g.camera = new THREE.PerspectiveCamera(
    c.CAM_FOV, 
    g.width/g.height,
    c.CAM_NEAR,
    c.CAM_FAR
  );
  g.camera.position.set(1, 2, 3);
  g.camera.lookAt(new THREE.Vector3());

  // scene
  g.scene = new THREE.Scene();
  g.scene.add(g.camera);

  // trackball controls
  g.controls = new THREE.TrackballControls(g.camera, g.container);
  g.controls.rotateSpeed = 1.0;
  g.controls.zoomSpeed = 1.2;
  g.controls.panSpeed = 1.0;    
  g.controls.dynamicDampingFactor = 0.3;
  g.controls.staticMoving = false;
  g.controls.noZoom = false;
  g.controls.noPan = false;

  initScene();

  // insert stats
  g.stats = new Stats();
  g.stats.domElement.style.position = 'absolute';
  g.stats.domElement.style.top = '0px';
  g.stats.domElement.style.zIndex = 100;
  g.container.appendChild( g.stats.domElement );

  window.addEventListener( 'resize', onWindowResize, false );
}

function update() {
  //animate();
  g.stats.update();
  g.controls.update();

  // render
  g.renderer.clear();
  g.renderer.render( g.scene, g.camera );

  requestAnimationFrame(update);
};

function onWindowResize(event) {
  g.width  = window.innerWidth;
  g.height = window.innerHeight;

  g.renderer.setSize( g.width, g.height );

  g.camera.aspect = g.width / g.height;
  g.camera.updateProjectionMatrix();

  g.controls.screen.width = g.width;
  g.controls.screen.height = g.height;
  g.controls.radius = ( g.width + g.height ) / 4;
};

function animate() {
  // DEBUGTEST
  //for (var i=4; i<g.scene.children.length; i++) {
  //  g.scene.children[i].rotation.x += 0.01;
  //  g.scene.children[i].rotation.y += 0.01;
  //}
  g.cube.rotation.x += 0.01;
  g.cube.rotation.y += 0.01;
  
  g.cube.position.y = 2.0*Math.sin(g.time);
  
  g.time += 0.01;
}

function initScene() {
  
  // fog
  g.scene.fog = new THREE.Fog( 0x000000, c.FOG_NEAR, c.FOG_FAR );

  //// ground
  //(function() {
  //  var imageCanvas = document.createElement( "canvas" );
  //  var context = imageCanvas.getContext( "2d" );
  //
  //  imageCanvas.width = imageCanvas.height = 128;
  //
  //  context.fillStyle = "#CCC";
  //  context.fillRect( 0, 0, 128, 128 );
  //
  //  context.fillStyle = "#fff";
  //  context.fillRect( 0, 0, 64, 64);
  //  context.fillRect( 64, 64, 64, 64 );
  //
  //  var textureCanvas = new THREE.Texture( imageCanvas, 
  //    THREE.UVMapping, THREE.RepeatWrapping, THREE.RepeatWrapping );
  //  var materialCanvas = new THREE.MeshBasicMaterial( { map: textureCanvas } );
  //
  //  textureCanvas.needsUpdate = true;
  //  textureCanvas.repeat.set( 1000, 1000 );
  //
  //  var geometry = new THREE.PlaneGeometry( 100, 100 );
  //
  //  var meshCanvas = new THREE.Mesh( geometry, materialCanvas );
  //  meshCanvas.scale.set( 100, 100, 100 );
  //  meshCanvas.position.set(0, -1, 0);
  //
  //  g.scene.add(meshCanvas);
  //})();
  
  // lights
  
  // front light
  var light;
  light = new THREE.PointLight();
  light.position.set( 6, 8, 2 );
  light.color.setRGB( 1.0, 0.8, 0.0 );
  g.scene.add( light );
  g.lightP.push(light.position);
  g.lightC.push(light.color);

  // back light
  light = new THREE.PointLight();
  light.position.set( -4, 4, -6 );
  light.color.setRGB( 0.0, 0.4, 0.7 );
  g.scene.add( light );
  g.lightP.push(light.position);
  g.lightC.push(light.color);


  // the cube
  
  var voltex = THREE.ImageUtils.loadTexture("img/test_checker_texture2g.png");
  voltex.minFilter = voltex.magFilter = THREE.LinearFilter;
  voltex.wrapS = voltex.wrapT = THREE.ClampToEdgeWrapping;
  var voltexDim = new THREE.Vector3( 64.0, 64.0, 64.0 );
  
  var volcol = new THREE.Vector3(0.8, 0.8, 0.8);
  
  var uniforms = {
    uCamPos:    { type: "v3", value: g.camera.position },
    uCamCenter: { type: "v3", value: g.controls.target },
    uCamUp:     { type: "v3", value: g.camera.up },    
    uLightP:    { type: "v3v", value: g.lightP },
    uLightC:    { type: "v3v", value: g.lightC },
    uColor:     { type: "v3", value: volcol },
    uTex:       { type: "t", value: 0, texture: voltex },
    uTexDim:    { type: "v3", value: voltexDim }
  }
  
  var shader = new THREE.ShaderMaterial({
    uniforms:       uniforms,
    vertexShader:   loadTextFile("shaders/vol-vs.glsl"),
    fragmentShader: loadTextFile("shaders/vol-fs.glsl")
  });
  
  g.cube = new THREE.Mesh(
    new THREE.CubeGeometry( 1.0, 1.0, 1.0 ),    // must be unit cube
    shader //new THREE.MeshLambertMaterial( { color: 0xCCCCCC } )
  );
  //g.cube.position.set(0.0, 0.0, 0.0);
  //g.cube.scale.set(3.0, 3.0, 3.0);      // scale later
  g.scene.add(g.cube);
}

// perform synchronous ajax load
function loadTextFile(url) {
  var result;
  
  $.ajax({
    url:      url,
    type:     "GET",
    async:    false,
    dataType: "text",
    success:  function(data) {
      result = data;
    }
  });
  
  return result;
}

$(function() {
  init();  
  update();
});