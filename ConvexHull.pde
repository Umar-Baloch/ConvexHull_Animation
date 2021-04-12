//function to return lowest point and set gWrap to 1 which triggers giftwrap algorithm in draw function
void calculateGiftWrap(){

  float min = 800;
  float max = 0;
  
  //finds the lowest and highest point in points set
  for(int i = 0; i < points.size(); i++){
    checking = points.get(i);
    if(checking.p.y < min){
      min = checking.p.y;
      current = checking;
      lowest = checking;
    }
    
    if(checking.p.y > max){
      max = checking.p.y;
      maxInd = checking;
    }
  }
  
  //frame rate based on number of points
  //max frame rate allowed on my machine was 1000
  if(points.size() < 20){frameRate(10);}
  else if (points.size() < 30){frameRate(30);}
  else if (points.size() < 50){frameRate(50);}
  else if (points.size() < 60){frameRate(250);}
  else if (points.size() < 70){frameRate(550);}
  else if (points.size() < 80){frameRate(650);}
  else if (points.size() < 90){frameRate(950);}
  else{frameRate(1000);}
  
  //triggers giftwrap in draw function
  gWrap = 1;
}

//function to call quickhull
void calculateQuickHull(){
     
   float Xmax = 0.0;
   float Xmin = 900.0;
   float RYmin = 900.0;
   float LYmax = 0.0;
   
   //find leftmost and rightmost points
   for(int i = 0; i < points.size(); i++){
     if(points.get(i).p.x < Xmin){
       Xmin = points.get(i).p.x;
     }
     
     if(points.get(i).p.x > Xmax){
       Xmax = points.get(i).p.x;
     }
   }
   
   //find the lowest righmost point and highest leftmost point
   for(int i = 0; i < points.size(); i++){
     if(points.get(i).p.x == Xmax){
       if(points.get(i).p.y < RYmin){
         RYmin = points.get(i).p.y;
         rl = points.get(i);
       }
     }
     
     if(points.get(i).p.x == Xmin){
       if(points.get(i).p.y > LYmax){
         LYmax = points.get(i).p.y;
         lh = points.get(i);
       }
     }
   }
  
  if(points.size() > 0){
   //add first edge seperating points set into 2
    Edge e2 = new Edge(lh, rl); 
    edges.add(e2);
    
    //seperate upper and lower hull points
    uppers = aboveOrBelow(0, lh, rl, points);
    lowers = aboveOrBelow(1, lh, rl, points);
    
    //set frame rate and trigger quickHull in draw function
    frameRate(5);
    qHull = 1;
  }
}


//function to return points set above or below edge(p1,p2)
ArrayList<Point> aboveOrBelow(int select, Point p1, Point p2, ArrayList<Point> points){
  ArrayList<Point> above = new ArrayList<Point>();
  ArrayList<Point> below = new ArrayList<Point>();
  
  //find m of line first
  float m = (p2.p.y - p1.p.y)/(p2.p.x - p1.p.x);
  //c = y - mx
  float c = p1.p.y - m * p1.p.x;
  
  for(int i = 0; i < points.size(); i++){
    
    //y > mx + c for above
    if(points.get(i).p.y > ((m * points.get(i).p.x) + c)){
      above.add(points.get(i));
    }
    //y < mx + c for below
    else if(points.get(i).p.y < ((m * points.get(i).p.x) + c)){
      below.add(points.get(i));
    }
  }
  
  if(select == 0){
    return above;
  }
  else{
    return below;
  }
}

//returns max distance from line to a point
Point max_distance(Point p1, Point p2, ArrayList<Point> points){
  float dist = 0.0;
  float max = 0.0;
  //find max distance and store that point, then return the point with the max distance from line
  Point maxDist = new Point(0, 0);
  
  //find gradient and y-intercept
  float m = (p2.p.y - p1.p.y)/(p2.p.x - p1.p.x);
  float c = p1.p.y - m * p1.p.x;
  
  for(int i = 0; i < points.size(); i++){
    //use distance formlua d = |ax + by + c| / sqrt(a square + b square) 
    //where a, b, c come from line equation ax + by + c = 0 and x, y come from point being checked
    dist = abs((0-m)*points.get(i).p.x + points.get(i).p.y + (0 - c)) / (sqrt(1 + m*m));
    
    if(dist > max){
      max = dist;
      maxDist = points.get(i);
    } 
  }
  
  return maxDist;
}
