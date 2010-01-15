/**
 * binarymillenium
 GPL v3.0
November 2009
 
toxi geom library
http://toxiclibs.googlecode.com/files/toxiclibscore-0014.zip

For use with structured light:

http://code.google.com/p/structured-light/
*/

import javax.media.opengl.*;
//import saito.objloader.*;
import processing.opengl.*;
import com.sun.opengl.util.texture.*;  
import toxi.geom.*;
import java.nio.*;
import com.sun.opengl.util.*;
import javax.media.opengl.glu.*; 

GL gl;
GLU glu;
boolean useRawGL = false;
//OBJModel model;


int numPeriods = 5;
int numPhases = 3;

Texture tex[] = new Texture[numPeriods*numPhases];
PImage texp[] = new PImage[numPeriods*numPhases];

float rotx = PI/4;
float roty = PI/4;

int imind = 0;

XPatternGen patterns;

Matrix4x4 view;
/// the position and orientation of the projector
Matrix4x4 projector;
Vec3D projPos;

Vec3D[] vs;
Vec3D[] vn;
int[][] faces;

float objScale = 90.0;
    
/////////////////////////////////////////////////////////////
void setup() 
{
  size(480, 640, OPENGL);
     
  perspective(PI/16, float(width)/float(height), 1, 20000);
  
   //model = new OBJModel(this, "cube.obj");
   
   //model.debugMode();
   //model.showModelInfo();
   
   
   String[] lines = loadStrings("weird_01.obj");
   
   vs = new Vec3D[1];
   vn = new Vec3D[1];
   
   faces = new int[1][3];
   

   
   int vcount = 0;
   int vncount = 0;
   int fcount = 0;
   for (int i=0; i< lines.length; i++) {
     String[] toks = splitTokens(lines[i]);
     if (toks.length > 2) {
       if (toks[0].equals("v")) {
         //println(i + " " + toks[1] + " " + toks[2] + " " + toks[3]);
         vs[vcount] = new Vec3D(Float.parseFloat(toks[1]),
                               Float.parseFloat(toks[2]),
                               Float.parseFloat(toks[3]));
         
         vcount++;
         Vec3D[] nvs = new Vec3D[vcount+1];
         arraycopy(vs,nvs,vs.length);
         vs = nvs;
         
       }
       
       if (toks[0].equals("vn")) {
         //println(i + " " + toks[1] + " " + toks[2] + " " + toks[3]);
         vn[vncount] = new Vec3D(Float.parseFloat(toks[1]),
                               Float.parseFloat(toks[2]),
                               Float.parseFloat(toks[3]));
         
         vncount++;
         Vec3D[] nvn = new Vec3D[vncount+1];
         arraycopy(vn,nvn,vn.length);
         vn = nvn;
       }
       
       if (toks[0].equals("f")) {
         //println(i + " " + toks[1] + " " + toks[2] + " " + toks[3]);
         
         String[] nums;
         nums = splitTokens(toks[1],"/");
         faces[fcount][0] =Integer.parseInt(nums[0]);
         nums = splitTokens(toks[2],"/");
         faces[fcount][1] =Integer.parseInt(nums[0]);
         nums = splitTokens(toks[3],"/");
         faces[fcount][2] =Integer.parseInt(nums[0]);

         
         //println("face " + fcount + " " + faces[fcount][0] + " " + faces[fcount][1] + " " + faces[fcount][2]);
         fcount++;
         int[][] nfaces = new int[fcount+1][3];
         arraycopy(faces,nfaces,faces.length);
         faces = nfaces;
         
       }
     }
     

   } 
  
  if (true) { 
  patterns = new XPatternGen(width, height,8, numPhases,numPeriods );
  
  
  /*
  /// generate random object
  /// TBD load obj
  float sc = 1;
  
  int mx = 28;
  vs = new Vec3D[mx*mx];
  faces = new int[(mx-1)*(mx)][4];
  for (int i = 0; i < mx; i++) {
     for (int j = 0; j < mx; j++) {
       float lat = i/(float)(mx-1)*PI-PI/2;
       float lng = j/(float)(mx-1)*PI*2-PI;
       
       int ind = i*mx+j;
       float r = 1.5+1.0*noise(i/12.0,j/12.0);
       vs[ind] = new Vec3D( r*cos(lat)*cos(lng), r*cos(lat)*sin(lng),  r*sin(lat) ); 
       //vs[ind] = vs[ind].scale(10);
      
      if ((j>0) && (i >0)) {
        int find = (i-1)*mx + (j-1);
        //faces[find] = new int[4];
        
        faces[find][0] = ind;
        faces[find][1] = ind-1;
        faces[find][2] = ind-1-mx;
        faces[find][3] = ind - mx;
      }
  }}
  */
  
   
  for (int i = 0; i < numPeriods; i++) {
  for (int j = 0; j < numPhases; j++) {
    int ind = i*numPhases+j;
    println("loading " + ind + ", " + i + " " + j + " ");
    try {  
      String name =dataPath(patterns.pnames[i][j]);
      println(name);
      tex[ind] = TextureIO.newTexture(new File(name),true); 
      texp[ind] = loadImage(name);
    }
    catch(Exception e) { println(e); } 
    
    //tex[ind].setTexParameteri(GL.GL_TEXTURE_WRAP_R,GL.GL_REPEAT);    
    //tex[ind].setTexParameteri(GL.GL_TEXTURE_WRAP_S,GL.GL_REPEAT);
   // tex[ind].setTexParameteri(GL.GL_TEXTURE_WRAP_T,GL.GL_REPEAT);
  }}
 
  textureMode(NORMALIZED);
  fill(255);
  stroke(color(44,48,32));
  
  
  float angle = PI/2;
  projPos = new Vec3D(0,0,0);
  
  /// point at the origin
  //Vec3D dirV = new Vec3D(0,0,0).sub(projPos).getNormalized();
  //Quaternion dir = new Quaternion( cos(angle/2), 
   //                   new Vec3D(dirV.x*sin(angle/2),dirV.y*sin(angle/2),dirV.z*sin(angle/2)));
                      
  //projector= dir.getMatrix();
  projector = new Matrix4x4(1,0,0,0,
                            0,1,0,0,
                            0,0,1,0,
                            0,0,0,1);
  view = new Matrix4x4(1,0,0,0,
                            0,1,0,0,
                            0,0,1,0,
                            0,0,0,1);
                            
  }
  
}

//////////////////////////////////////////////////////////////////
void keyPressed() {
  float sc = 0.1;
  /*
  if (key == 'a') {
    projPos = projPos.add(sc,0,0);
  }  
  if (key == 'd') {
    projPos = projPos.sub(0.5*sc,0,0);
  }  
  if (key == 'q') {
    projPos = projPos.add(0,0,sc);
  }  
  if (key == 'z') {
    projPos = projPos.sub(0,0,0.5*sc);
  }  
  if (key == 'w') {
    projPos = projPos.add(0,sc,0);
  }  
  if (key == 's') {
    projPos = projPos.sub(0,0.5*sc,0);
  }  
  */
  
  if (key == 'o') {
     texScale *= 1.05; 
  }
  if (key == 'l') {
    texScale *= 0.98;
  }
  /// reset
  if (key == 'r') {
    projPos = new Vec3D(0,0,0);
    projector = new Matrix4x4(1,0,0,0,
                            0,1,0,0,
                            0,0,1,0,
                            0,0,0,1);
    view = new Matrix4x4(1,0,0,0,
                         0,1,0,0,
                         0,0,1,0,
                         0,0,0,1);
                            
    rotx = PI/4;
    roty = PI/4;
    
    texScale = 0.14;
  }  
  
  if (key == 'j') {
    relAngle+= PI/90.0;
    println("angle " + relAngle*180/PI);
    
    //projector = rotateRel(projector, PI/900, new Vec3D(0,1,0));
  }
  if (key == 'k') {
    relAngle -= PI/180.0;
    println("angle " + relAngle*180/PI);
    //projector=rotateAbs(projector, -PI/1800, new Vec3D(0,1,0));
  }
  /*
  if (key == 'u') {
    projector = rotateAbs(projector, sc*PI/10, new Vec3D(0,0,1));
  }
  if (key == 'm') {
    projector = rotateAbs(projector, -sc*PI/20, new Vec3D(0,0,1));
  }
  if (key == 'o') {
    projector = rotateAbs(projector, sc*PI/10, new Vec3D(1,0,0));
  }
  if (key == 'l') {
    projector = rotateAbs(projector, -sc*PI/20, new Vec3D(1,0,0));
  }
  */
  if (key == 'h') {
    drawLine = !drawLine; 
  }
  
  if (key == 'y') {
    switchTex = true;
  }
  
  if (key == 'g') {
    saveIm = true;
  }
  
  if (key =='n') {
     objScale *= 1.02;
     
  }
  if (key == 'm') {
     objScale *= 0.99; 
  }
  
}

///////////////////////////////////////////////

//////////////////////////////////////////////////////////
/// utility functions

Matrix4x4 rotateAbs(Matrix4x4 rot, float df, Vec3D axis) {
  Quaternion quat = new Quaternion(cos(df/2), 
                          new Vec3D(axis.x*sin(df/2),
                                    axis.y*sin(df/2),
                                    axis.z*sin(df/2)) );
                                    
  rot = rot.multiply(quat.getMatrix());
  return rot;
}


///////////////////
Matrix4x4 rotateRel(Matrix4x4 rot, float df, Vec3D axis) {
  Quaternion quat = new Quaternion(cos(df/2), 
                          new Vec3D(axis.x*sin(df/2),
                                    axis.y*sin(df/2),
                                    axis.z*sin(df/2)) );
                                    
  rot = quat.getMatrix().multiply(rot);
  return rot;
}
////

void apply(Matrix4x4 m) {
 applyMatrix( (float)m.matrix[0][0], (float)m.matrix[0][1], (float)m.matrix[0][2], 0,  
                 (float)m.matrix[1][0], (float)m.matrix[1][1], (float)m.matrix[1][2], 0,  
                 (float)m.matrix[2][0], (float)m.matrix[2][1], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[3][0], (float)m.matrix[3][1], (float)m.matrix[3][2], 1  ); 
            
}

/////

boolean switchTex = false;
boolean drawLine = true;
boolean saveIm = false;
float relAngle = 15.0/180.0*PI;

//////////////////////////////////////////////////////////////
void draw() {
  
   
   PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;   
   glu = ((PGraphicsOpenGL)g).glu;  
   GL gl = pgl.beginGL();
      
   perspective(PI/16, float(width)/float(height), 1, 20000);
  
   
  /// only do this synchronously with drawing
  if (switchTex) {
    imind++;
    imind %= numPeriods*numPhases;  
    /*
    try { tex  = TextureIO.newTexture(new File(dataPath(imnames[imind])),true); }
    catch(Exception e) { println(e); } 
    */
    //println("using texture " + imnames[imind]); 
    
  }
  switchTex = false;
  
  background(0);
  noStroke();
  
  translate(width, height, -2400);
  
  
  rotateZ(PI/2); 
  //println(relAngle);
  projector=rotateRel(view, relAngle, new Vec3D(0,1,0));
  //Matrix4x4 view = rotateRel(projector, relAngle, new Vec3D(0,1,0) );

  if (useRawGL) {
  gl.glEnable(gl.GL_LIGHTING);
  gl.glEnable(gl.GL_LIGHT0);
  
  float position[] = { -100,100,10,1.0f};
  //projPos.x,  projPos.y,  projPos.z, 1.0f };
  
  float diffuse[] = { 1.0f, 1.0f, 1.0f, 1.0f };
  float amb[] = { 0.1f, 0.1f, 0.1f, 1.0f };
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_AMBIENT, amb,0);
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_POSITION,  position ,0);
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_DIFFUSE, diffuse,0 );
  } else {
    Vec3D p = new Vec3D(1000.0*(float)projector.matrix[2][0],
    1000.0*(float)projector.matrix[2][1],
    1000.0*(float)projector.matrix[2][2]);
    ambientLight( 5,5,5,p.x,p.y,p.z);
    pointLight( 255,255,255,p.x,p.y,p.z); //projPos.x,projPos.y,projPos.z);
    //println(p);
  }
  
  apply(view);
  /*rotateZ(PI/2); 
  rotateY(-rotx);     
  rotateX(roty);
  */

  scale(objScale);
  

  //lights();
  //pointLight(projPos.x,projPos.y,projPos.z, 255,0,0);
  
  drawObject(tex[imind], texp[imind]);
  
  if (saveIm) {
    String name = "phase" + (imind + 1001) + ".jpg";
    saveFrame(name);
    println("saving " + name);
    
    /// save the depth buffer
    if (imind == 0) {
      
      

  
      float[] newData = new float[width*height];
      byte[] data = new byte[(width*height)*4];
      
      FloatBuffer fb = BufferUtil.newFloatBuffer(width*height);
      gl.glReadPixels(0, 0, width, height, GL.GL_DEPTH_COMPONENT, GL.GL_FLOAT, fb); 
      fb.rewind();
   
      int viewport[] = new int[4]; 
      double[] proj  = new double[16];
      double[] model = new double[16];
      gl.glGetIntegerv(GL.GL_VIEWPORT, viewport, 0);
      gl.glGetDoublev(GL.GL_PROJECTION_MATRIX, proj,0);
      gl.glGetDoublev(GL.GL_MODELVIEW_MATRIX, model,0);
      
      double[] pos=new double[4];
    
      for (int j = 0; j < height; j++) {
      for (int i = 0; i < width; i++) {
      // framebuffer has opposite vertical coord  
        int ind = j*width+i;
        
        float rawd = 0;
        
        int ind1 = (height-j-1)*width+i;
        rawd = fb.get(ind1);

         glu.gluUnProject(i,height-j,rawd, model,0,proj,0,viewport,0,pos,0); 
         float d = (float)-pos[2];
               
         data = floatToBytes(data, ind*4, d);
         
        //if (d < mind) mind = d;
        //if (d > maxd) maxd = d; 
        
        //d+= (maxd-mind)/15.0 * noise((float)j/2.0,(float)i/2.0,f*10);
          
        //if (d > fard) d = fard;
        //if (d < neard) d = neard;
        
        //float distf=  1.0 - ((d-neard)/(fard-neard));   

        //tx.pixels[ind] = makecolor(distf); //color(distf*255); //   
      }}
   
    
      saveBytes("heightdata.dat",data);
      }
    
    imind++;  
 
  } 
  if (imind >= numPeriods*numPhases) { 
    saveIm = false;
    imind = 0;
  }
  

  if (drawLine) {
    noLights();
    strokeWeight(3.0);
    stroke(255,255,255);
    line(projPos.x,projPos.y, projPos.z, 
         projPos.x+15.0*(float)projector.matrix[2][0],
         projPos.y+15.0*(float)projector.matrix[2][1], 
         projPos.z+15.0*(float)projector.matrix[2][2]);
  }
  
    pgl.endGL();
}

/////////////////////////////////////////////////////

byte[] floatToBytes(byte[] rv, int i, float val) {
    //byte[] rv = new byte[4];
    
      int bits = Float.floatToIntBits(val);
      rv[i+3] = (byte) ((bits >> 24) & 0xff);
      rv[i+2] = (byte) ((bits >> 16) & 0xff);
      rv[i+1] = (byte) ((bits >> 8)  & 0xff);
      rv[i+0] = (byte) ((bits >> 0)  & 0xff);
      
      return rv;
}
///////////////////////////////////////////////////

int counttemp = 0;
/// TBD make this work non-orthogonally
float texScale = 0.25;

Vec3D vertexProj(Vec3D v,Vec3D n, boolean verbose) {
  
  Vec3D rel = v.sub(projPos);
  
  Vec3D uv = new Vec3D();
 
  //if (rel.dot(n) < 0) return uv;
 
  uv = projector.apply(rel);
  
   uv = uv.scale(texScale);
   
   float yscale;
   if (useRawGL) {
  yscale = (float)tex[imind].getHeight()/(float)tex[imind].getWidth();
   } else {
      yscale = (float)texp[imind].height/(float)texp[imind].width;
   }
  if (counttemp ==0)println(yscale);
  uv.x = uv.x+0.5;
  uv.y = (uv.y)*yscale+0.5;
  
    if (counttemp == 0) {
      println("uv " + uv.y + " " + uv.x); 
   }
  //counttemp++;
 
    if (useRawGL) {
    gl.glNormal3f(n.x,n.y,n.z);
    gl.glTexCoord2f(uv.y,uv.x );    
    gl.glVertex3f(v.x,v.y,v.z);
    } else {
      normal(n.x,n.y,n.z);
       vertex(v.x,v.y,v.z, uv.y,uv.x);
    //vertex(v.x, v.y, v.z, pt.x*10, pt.y *10);
    }
 
  
  if (verbose) println(uv.x + " " + uv.y);
  
  return uv;
}

//void vertexProj(Vec3D v) {
//  vertexProj(v,false);
//}

/// draw an object with texture projected onto it
void drawObject(Texture tex,PImage texp) {
  
  /*
  fill(255);
  stroke(255);
  beginShape(LINES);
  for (int i = 0; i < faces.length; i++) {
    vertexProj(vs[faces[i][0]]);
    vertexProj(vs[faces[i][1]]);
    vertexProj(vs[faces[i][2]]);
    vertexProj(vs[faces[i][3]]);
    
    println(vs[faces[i][0]]);
  }
  endShape();
  println();
  */
  
  //model.texture(tex);
  
  /*
  for (int i = 0; i < model.getVertexSize(); i++) {
    PVector v = model.getVertex(i);
    PVector n = model.getNormal(i);
    
    if (counttemp == 0) { 
      println(i + ", " + v.x + " " + v.y + " " + v.z + ", " + n.x + " " + n.y + " " + n.z + " " );
    }
    
    Vec3D uv = vertexProj(new Vec3D(v.x,v.y,v.z), new Vec3D(n.x,n.y,n.z), false);  
    model.setUV(i, new PVector(uv.y,uv.x));
  }
 
  model.draw();
  */
   counttemp++;
  

   

 
  if (useRawGL) {
    tex.bind();  
    tex.enable();  
     gl.glBegin(GL.GL_TRIANGLES);
   //gl.glNormal3f( 0.0f, 0.0f, 1.0f); 
  
   gl.glTexParameteri( GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP );
   gl.glTexParameteri( GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP );
   gl.glTexParameteri( GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_R, GL.GL_CLAMP );
  } else {  
    beginShape(TRIANGLES);
    texture(texp);
  }
  
  // +Z "front" face
  for (int i = 0; i < faces.length-1; i++) {
    //Vec3D uv;
    
    //println( (faces[i][0]-1) + " " +  (faces[i][1]-1) + " " + (faces[i][2]-1));
   
    vertexProj(vs[faces[i][0]-1], vn[faces[i][0]-1],false);
    vertexProj(vs[faces[i][1]-1], vn[faces[i][1]-1],false);
    vertexProj(vs[faces[i][2]-1], vn[faces[i][2]-1],false);

    //vertexProj(vs[faces[i][3]]);
  }
  
  if (useRawGL) {
  gl.glEnd();
  
  tex.disable();
//   / 
  } else {
    endShape();
  }
  
}

void mouseDragged() {
  float rate = 0.005;
  rotx = (pmouseY-mouseY) * rate;
  roty = (mouseX-pmouseX) * rate;
  
  //projector = rotateRel(projector, -rotx, new Vec3D(0,1,0));
  //projector = rotateRel(projector, roty, new Vec3D(1,0,0));
  
  view = rotateRel(view, -rotx, new Vec3D(0,1,0));
  view = rotateRel(view, roty, new Vec3D(1,0,0));
}