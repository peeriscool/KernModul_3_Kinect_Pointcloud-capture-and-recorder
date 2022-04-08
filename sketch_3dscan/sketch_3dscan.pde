/*
Thomas Sanchez Lengeling.
 http://codigogenerativo.com/
 
 KinectPV2, Kinect for Windows v2 library for processing
 
 Point Cloud Color Example using low level openGL calls and Shaders
 */

import java.nio.*;
import KinectPV2.*;
private KinectPV2 kinect;

//values for the 3d scene
//rotation
float a = 3.1;
float e = 0f;
float r = 250f; //alpha
//z scale value
int   zval     = 1050;
//value to scale the point cloud
float scaleVal = 990;

//rotation
float rotY = 0;
float rotZ = 0;
float rotX = PI;

float depthVal = 4;

int vertLoc;
int colorLoc;

//openGL instances
//render ot openGL object
PGL pgl;

//create a shader
PShader sh;


//VBO buffer location in the GPU
int vertexVboId;
int colorVboId;

//peer
int offsetY = -2030; //vertical
int offsetX; //horizontal

// recording values
int numFrames =  30; // 30 frames  = 1s of recording
int frameCounter = 0; // frame counter

boolean recordFrame = false;  //recording flag
boolean doneRecording = false;

//Array where all the frames are allocated
ArrayList<FrameBuffer> mFrames;

public void setup() {
  size(1920,1080, P3D);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableColorImg(true);
  kinect.enableColorPointCloud(true);

  kinect.init();

  //create shader object with a vertex shader and a fragment shader
  sh = loadShader("frag.glsl", "vert.glsl");


  //create VBO

  PGL pgl = beginPGL();

  // allocate buffer big enough to get all VBO ids back
  IntBuffer intBuffer = IntBuffer.allocate(2);
  pgl.genBuffers(2, intBuffer);

  //memory location of the VBO
  vertexVboId = intBuffer.get(0);
  colorVboId = intBuffer.get(1);

  endPGL();
}

public void draw() {
  background(kinect.getColorImage());

 // image(kinect.getColorImage(), 0, 0, 1920/2,1080/2);

// the values 0 and 400 are used for the
// parameters "u" and "v" to map it directly
// to the vertex points
   //beginShape();
  
   // texture(kinect.getColorImage());
   // vertex(0, -0, 0, -9000,   0);
   // vertex( 1920/2 , 0,  -9000, 1920, 0);
   // vertex( 1920/2,  1080/2,  -9000, 1920, 1080);
   // vertex(0,  1080/2,  -9000, 0,   1080);
   // endShape();
  noStroke();
color c = color(0, 0, 0, r);
fill(c);
rect(0,0, 1920, 1080);

  // The geometric transformations will be automatically passed to the shader
  pushMatrix();
  scale(-1, 1);
  translate(width / 2 + offsetY, height / 2 + offsetX, zval);
  scale(scaleVal, -1 * scaleVal, scaleVal);
  rotate(a, 0, 1f, 0);

  //render to the openGL object
  pgl = beginPGL();
  sh.bind();


  //obtain the point cloud positions
  FloatBuffer pointCloudBuffer = kinect.getPointCloudColorPos();

  //get the color for each point of the cloud Points
  FloatBuffer colorBuffer      = kinect.getColorChannelBuffer();

  //send the the vertex positions (point cloud) and color down the render pipeline
  //positions are render in the vertex shader, and color in the fragment shader
  vertLoc = pgl.getAttribLocation(sh.glProgram, "vertex");
  pgl.enableVertexAttribArray(vertLoc);
  
  
  //enable drawing to the vertex and color buffer
  colorLoc = pgl.getAttribLocation(sh.glProgram, "color");
  pgl.enableVertexAttribArray(colorLoc);

  int vertData = kinect.WIDTHColor * kinect.HEIGHTColor * 3;

  //vertex
  {
    pgl.bindBuffer(PGL.ARRAY_BUFFER, vertexVboId);
    // fill VBO with data
    pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * vertData, pointCloudBuffer, PGL.DYNAMIC_DRAW);
    // associate currently bound VBO with shader attribute
    pgl.vertexAttribPointer(vertLoc, 3, PGL.FLOAT, false, Float.BYTES * 3, 0);
  }

  // color
  {
    pgl.bindBuffer(PGL.ARRAY_BUFFER, colorVboId);
    // fill VBO with data
    pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * vertData, colorBuffer, PGL.DYNAMIC_DRAW);
    // associate currently bound VBO with shader attribute
    pgl.vertexAttribPointer(colorLoc, 3, PGL.FLOAT, false, Float.BYTES * 3, 0);
  }

  // unbind VBOs
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

  //draw the point cloud as a set of points
  pgl.drawArrays(PGL.POINTS, 0, vertData);

  //disable drawing
  pgl.disableVertexAttribArray(vertLoc);
  pgl.disableVertexAttribArray(colorLoc);

  //close the shader
  sh.unbind();
  //close the openGL object
  endPGL();

  popMatrix();

  stroke(255, 0, 0);
  text(frameRate, 50, height- 50);
}

public void mousePressed() {

  println(frameRate);
    saveFrame();
}

public void keyPressed() {

  

  if (key == 'q') {
    a += 0.01;
    println("angle "+a);
  }
  if (key == 'w') {
    a -= 0.01;
    println("angle "+a);
  }
   if (key == 'e') {
    r += 10;
    println("angle "+r);
  }
  if (key == 'r') {
    r -= 10;
    println("angle "+r);
  }
  
  if (key == 'a') {
    zval +=10;
    println(zval);
  }
  if (key == 's') {
    zval -= 10;
    println(zval);
  }

  if (key == 'd') {
    depthVal -= 20;
    println(depthVal);
  }

  if (key == 'f') {
    depthVal += 20;
    println(depthVal);
  }
  if (key == 'z') {
    scaleVal += 20;
    println(scaleVal);
  }
  if (key == 'x') {
    scaleVal -= 20;
    println(scaleVal);
  }
  //peer
 if(key == 'c')
 {
   offsetY += 10;
    println(offsetY);
 }
  if(key == 'v')
 {
   offsetY -= 10;
     println(offsetY);
 }
  if(key == 'b')
 {
   offsetX += 5;
     println(offsetX);
 }
  if(key == 'n')
 {
   offsetX -= 5;
     println(offsetX);
 }
 
}

  /*
  //start recording 30 frames with 'r'
  if (key == 'r') {
    recordFrame = true;
     saveFrame(); //COLOR_IMAGE
  }

  if (key == '1') {
    minD += 10;
    println("Change min: "+minD);
  }

  if (key == '2') {
    minD -= 10;
    println("Change min: "+minD);
  }

  if (key == '3') {
    maxD += 10;
    println("Change max: "+maxD);
  }

  if (key == '4') {
    maxD -= 10;
    println("Change max: "+maxD);
  }
  
 
*/
