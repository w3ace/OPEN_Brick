/*

 Basic Lego brick builder module for OpenScad by Jorg Janssen 2013 (CC BY-NC 3.0) 
 To use this in your own projects add:

 use <path_to_this_file/lego_brick_builder.scad>
 brick (length, width, height [,smooth]);

 Length and width are in standard lego brick dimensions. 
 Height is in flat brick heights, so for a normal lego brick height = 3.
 Add optional smooth = true for a brick without studs. 
 Use height = 0 to just put studs/knobs on top of other things.


  roundBrick usage

  outer_radius = 2, // outside ring in lego stud increments
  inner_radius = 1,  // inner ring in lego stud increments 
  height = 3,           // height of brick in standard LEGO units 
  studstyle = 1,        // stud is hollow = 0 or filled =1 
  topstyle=3,           // topstyle 
  degrees=360,          // length of round block arc in degrees
  reduce=0,
  window=0 

*/
$fn = 150;

include <_conf.scad>;
include <RectBrickBuilder.scad>;
include <RoundBrickBuilder.scad>;

// include <ReducerBrickBuilder.scad>;



 // this is it:
 //brick(1,6,3);
 //

	//round_brick(8,8,3, studstyle=1,radius=4,inner_radius=2,degrees=90 );

outer_radius= 4;
inner_radius = 3;
// Negate Reduction is 1ease
reduce =0;
height=3;

degrees_start = 60;
degrees_end = 120;
supports = 0;

attributes = [["thinwall",0],["link",0],
               ["archway",0],
               ["flattop",0],
               ["window",0],
               ["chamfer",0]];

               
//translate([-BRICK_WIDTH,inner_radius*BRICK_WIDTH,0])
//rectBrick(length=2,width=2,height=3);

// translate ([0,0,PLATE_HEIGHT*3])
color("DarkKhaki") {
    roundBrick(

        outer_radius,
        inner_radius,
        reduce,
        height,
      
        degrees_start,
        degrees_end,
        supports,

        attributes
    ); 
}

/*



    roundBrick(

        outer_radius=6,
        inner_radius=2,
        reduce=0,
        height=3,
      
        degrees_start=0,
        degrees_end =75,
        supports=0,

        attributes =["flattop",0]
    ); 
*/
// 


//reducerBrick(5,4,3,degrees=90);


//roundBrick(4,3,3,degrees=90);

// module brick
// 
// create a lego brick length x width x height 

