
import java.util.*;

ArrayList<Point>    points     = new ArrayList<Point>();
ArrayList<Edge>     edges      = new ArrayList<Edge>();
ArrayList<Edge>     edgesUpper      = new ArrayList<Edge>();

//variables for giftwrap
Point current = new Point(0,0);
Point checking = new Point(0,0);
Point lowest = new Point(0,0);
Point maxInd= new Point(0,0);
Point valid = new Point(0,0);  
Edge nextPossible = new Edge(current, valid);
PVector v1, v2;

double minAngle = 720;
double angle = 0;
ArrayList<Double> all_angles = new ArrayList<Double>();
ArrayList<Point> list = new ArrayList<Point>();
ArrayList<Double> dist = new ArrayList<Double>();

//variables for qHull
Point rl = new Point(0, 0);
Point lh = new Point(0, 0);
Point p1 = new Point(0, 0);
Point p2 = new Point(0, 0);

ArrayList<Point>    uppers     = new ArrayList<Point>();
ArrayList<Point>    lowers     = new ArrayList<Point>();
ArrayList<Point>    updatePts     = new ArrayList<Point>();

int j = 0;
int i = 0;
int k = 0;

//variables to trigger giftwrap and quickhull algorithms
int gWrap = 0;
int qHull = 0;
  
boolean reachTop = false;
boolean saveImage = false;
boolean isLowerHull = false;

int numOfPoints = 4;

//function to reset variables 
//used adding and clearing points and animations
void reset(){
  edges.clear(); 
  edgesUpper.clear();
  gWrap = 0; 
  checking = new Point(-1,-1); 
  reachTop = false;
    j = 0;
    i = 0;
    k = 0;
        minAngle = 360;
        list.clear();
        dist.clear();
        all_angles.clear();
        
  qHull = 0;
  isLowerHull = false;
  rl = new Point(0,0);
  lh = new Point(0,0);
  
  current = new Point(0,0);
  valid = new Point(0,0);  
  nextPossible = new Edge(current, valid);
  
}

//base functions for giftwrap and qHull are in ConvexHull file

void generateRandomPoints(){
  for( int i = 0; i < numOfPoints; i++){
    points.add( new Point( random(100,width-100), random(100,height-100) ) );
  }
 
}

void setup(){
  size(800,800,P3D);
 
}

//draw function where most of our algorithm runs
void draw(){
 
  background(255);
  
  translate( 0, height, 0);
  scale( 1, -1, 1 );
  
  strokeWeight(3);
  
  fill(0);
  noStroke();
  for( Point p : points ){
    p.draw();
  }
  
  //draw processed hull edges in green color
  noFill();
  stroke(0, 255, 0);
  for( Edge e : edges ){
    e.draw();
  }
  
  for( Edge e : edgesUpper ){
    e.draw();
  }
 
  //*************************************************************************************************************************************
  //*************************************************************************************************************************************
  
  //if gWrap is triggered from gift wrap function
  if(gWrap == 1){
    
    //draws the edge it currently thinks is the next valid vertex
    stroke(0, 0, 255);
    nextPossible.draw();
    
    //loop to run till current point checks all points and then move to next valid or new current point
    if(j < points.size() && checking.p.x != -1){
      //draw current and checking points in color
      checking = points.get(j);
      stroke(255, 0, 0);
      fill(255, 0, 0);
      ellipse( checking.p.x, checking.p.y, 13,13);
      
      stroke(255, 176, 3);
      fill(255, 176, 3);
      ellipse( current.p.x, current.p.y, 13,13);
      
      //draw checking line in red
      stroke(255, 0, 0);
      line( current.x(), current.y(), checking.x(), checking.y() );
      
      //if topmost point is reached
      if(current == maxInd){ reachTop = true; }
      
      //flip x axis if top most point is reached 
      if(reachTop){
        v1 = new PVector(-10,  0);
        v2 = new PVector(checking.p.x - current.p.x, checking.p.y - current.p.y);
        
        if(current.p.y < checking.p.y){ angle = 360 - Math.toDegrees(PVector.angleBetween(v1, v2)); }
        else{ angle = Math.toDegrees(PVector.angleBetween(v1, v2)); }
      }
      
      else{
        v1 = new PVector(10,  0);
        v2 = new PVector(checking.p.x - current.p.x, checking.p.y - current.p.y);
        
        //find angle 
        //and subtract it from 360 if checking point is lower than current point
        if(checking.p.y < current.p.y){ angle = 360 - Math.toDegrees(PVector.angleBetween(v1, v2)); }
        else{ angle = Math.toDegrees(PVector.angleBetween(v1, v2)); }
      }
      //add angle to list 
      all_angles.add(angle);
      
      //process minimum angle and update next valid point
      if(checking != current){
        if(minAngle > angle){
          minAngle = angle;
          valid = checking;
          
          //updates the edge that it thinks is the next valid edge
          nextPossible = new Edge(current, valid);
        }
      }
      
      //if current point has checked angle for all points
      if(j == points.size() - 1){
        
        //2 for loops to sort colinear points and select the furthest point as the next point 
        double maxDist = 0;
        for(int i = 0; i < points.size(); i++){
          if(minAngle == all_angles.get(i)){
            list.add(points.get(i));
            double distance = sqrt(((points.get(i).y() - current.y()) * (points.get(i).y() - current.y())) 
                                     + ((points.get(i).x() - current.x()) * (points.get(i).x() - current.x())));
            dist.add(distance); 
          }
        }
        for(int i = 0; i < list.size(); i++){
          if(dist.get(i) > maxDist){
            maxDist = dist.get(i);
            valid = list.get(i);
          }
        }
        
        //add new edge to hull
        Edge e1 = new Edge(current, valid);
        edges.add(e1);
        
        //condition to stop loop once lowest vertex is reached
        if(valid == lowest){gWrap = 0;}
        
        //set next valid point as current
        current = valid;
        
        //clear variables for new current point
        j = 0;
        minAngle = 360;
        list.clear();
        dist.clear();
        all_angles.clear();
      }
      
      //counter for loop that is reset to 0 for every new current point
      else{j++;}
    }
  }
  
  
  //*************************************************************************************************************************************
  //*************************************************************************************************************************************
  
  if(qHull == 1){
    
      //check if lower hull bool is true
      /*or if main counter is certain iteration higher than upper hull counter, 
        this ensures lower hull is still computed even if upper hull fails to trigger it*/
        
      if(isLowerHull || j > k + 4){
        
        //if it is first iteration of lower hull
        if(edges.size() == 1){
          p1 = lh;
          p2 = rl;
          updatePts = lowers;
        
          //find max distance point and add two new edges
          Point maxDist = max_distance(p1, p2, updatePts);
          if(maxDist.x() != 0){
            Edge e1 = new Edge(p1, maxDist);
            edges.add(e1);
            e1 = new Edge(maxDist, p2);
            edges.add(e1);
          }
        }
        
        //if not first iteration then iterate through edges in lower hull and find max distance point from those edges
        else if(edges.size() > 1){
          p1 = edges.get(i).getP1();
          p2 = edges.get(i).getP2();
          
          //find points below the current edge
          updatePts = aboveOrBelow(1, p1, p2, points);
          if(updatePts.size() > 0){
            
            //find max distance point from points below edge
            Point maxDist = max_distance(p1, p2, updatePts);
            if(maxDist.x() != 0){
              
              //if Upper hull does not exist then dont remove the first edge
              //else remove the first edge seperating two hulls
              if(edgesUpper.size() == 0 && i == 0){}
              else{edges.remove(i); i--;}
              
              //add two new edges to maxDistance point
              Edge e1 = new Edge(p1, maxDist);
              edges.add(e1);
              Edge e2 = new Edge(maxDist, p2);
              edges.add(e2);
            }
          }
          //counter for edges in lower hull
          i++;
        }
        
        //if counter catches upto to size of edges in lower hull then quickHull is computed
        if(i == edges.size()){
          qHull = 0;
        } 
      }
      
      //if it is Upper Hull (which is computed first and triggers lower hull
      if(!isLowerHull){
        
        //if fisrt iteration
        if(j == 0){
          p1 = lh;
          p2 = rl;
          updatePts = uppers;
          
          //find max distance point above line seperating two hulls and add 2 edges
          Point maxDist = max_distance(p1, p2, updatePts);
          if(maxDist.x() != 0){
            Edge e1 = new Edge(p1, maxDist);
            edgesUpper.add(e1);
            e1 = new Edge(maxDist, p2);
            edgesUpper.add(e1);
          }
        }
        
        //iterate through edges in upper hull and find max distance point
        else{
          p1 = edgesUpper.get(k).getP1();
          p2 = edgesUpper.get(k).getP2();
          
          //find points above the current edge, any points outside the current upper hull will be above edge
          updatePts = aboveOrBelow(0, p1, p2, points);
          
          //if any points above current edge
          //remove current edge and add 2 new edges to max distance point above current edge
          if(updatePts.size() > 0){
            Point maxDist = max_distance(p1, p2, updatePts);
            
            if(maxDist.x() != 0){
              edgesUpper.remove(k);
              k--;
              
              Edge e1 = new Edge(p1, maxDist);
              edgesUpper.add(e1);
              Edge e2 = new Edge(maxDist, p2);
              edgesUpper.add(e2); 
            }
          }
          //counter for upper hull edges
          k++;
        } 
        
        //if counter catches upto upperEdges.size() then trigger lower hull          
        if(k > edgesUpper.size() - 1 ){
          isLowerHull = true;
        }  
      }
      
      //main counter for quickHull
      j++;
  }
  
  
  fill(0);
  stroke(0);
  textSize(18);
  
  textRHC( "Controls", 10, height-20 );
  textRHC( "+/-: Increase/Decrease Number of Random Points Generated", 10, height-40 );
  textRHC( "g: Generate " + numOfPoints + " Random Point(s)", 10, height-60 );
  textRHC( "c: Clear Points", 10, height-80 );
  textRHC( "s: Save Image", 10, height-100 );
  textRHC( "w: Gift-Wrap", 10, height-120 );
  textRHC( "q: Quick-Hull", 10, height-140 );
  
  for( int i = 0; i < points.size(); i++ ){
    textRHC( i+1, points.get(i).p.x+5, points.get(i).p.y+15 );
  }
  
  if( saveImage ) saveFrame( ); 
  saveImage = false;
  
}


void keyPressed(){
  if( key == 's' ) saveImage = true;
  if( key == '+' ){ numOfPoints++;}
  if( key == '-' ){ numOfPoints = max( numOfPoints-1, 1 );}
  if( key == 'g' ){ reset(); generateRandomPoints();}
  if( key == 'c' ){ points.clear(); reset(); frameRate(1000);}
  if( key == 'w' ){ reset(); calculateGiftWrap();}
  if( key == 'q' ){ reset(); calculateQuickHull();}
  
}



void textRHC( int s, float x, float y ){
  textRHC( Integer.toString(s), x, y );
}


void textRHC( String s, float x, float y ){
  pushMatrix();
  translate(x,y);
  scale(1,-1,1);
  text( s, 0, 0 );
  popMatrix();
}

Point sel = null;


void mousePressed(){
  
  int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  
  float dT = 6;
  for( Point p : points ){
    float d = dist( p.p.x, p.p.y, mouseXRHC, mouseYRHC );
    if( d < dT ){
      dT = d;
      sel = p;
    }
  }
  
  if( sel == null ){
    sel = new Point(mouseXRHC,mouseYRHC);
    points.add( sel );
    
    reset();
  }
}

void mouseDragged(){
  int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  if( sel != null ){
    sel.p.x = mouseXRHC;   
    sel.p.y = mouseYRHC;
    
    reset();
  }
}

void mouseReleased(){
  sel = null;
}




  
