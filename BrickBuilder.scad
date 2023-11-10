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
$fn = 100;

include <_conf.scad>;
include <RectBrickBuilder.scad>;
include <RoundBrickBuilder.scad>;
// include <ReducerBrickBuilder.scad>;



 // this is it:
 //brick(1,6,3);
 //

	//round_brick(8,8,3, studstyle=1,radius=4,inner_radius=2,degrees=90 );

outer_radius=6;
inner_radius = 2;
// Negate Reduction is 1ease
reduce = 2;
height=3;

degrees_start =67.5;
degrees_end = 112.5;
supports = 0;
thinwall = 0;
window= 0;  
chamfer =0;

  /*  stained_glass_window_polygon = [[-PLATE_HEIGHT,PLATE_HEIGHT*1.5],[-PLATE_HEIGHT,PLATE_HEIGHT*height*.6],
        [0,PLATE_HEIGHT*height*.7],[PLATE_HEIGHT,PLATE_HEIGHT*height*.6],
        [PLATE_HEIGHT,PLATE_HEIGHT*1.5],[0,PLATE_HEIGHT*1.5]];


rotate([0,0,45])
    translate([inner_radius*BRICK_WIDTH,0,0])
        rotate([90,0,90])
            linear_extrude( height=(outer_radius-inner_radius)*BRICK_WIDTH,convexity = 10)
            polygon(stained_glass_window_polygon); */

    roundBrick(

        outer_radius,
        inner_radius,
        reduce,
        height,
      
        degrees_start,
        degrees_end,

        thinwall,
        window,
        chamfer,
        supports
    );

// 


//reducerBrick(5,4,3,degrees=90);


//roundBrick(4,3,3,degrees=90);

// module brick
// 
// create a lego brick length x width x height 

