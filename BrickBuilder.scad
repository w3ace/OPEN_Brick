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
// Keep curved parts responsive in the preview while retaining a smooth export.
// Using a fixed $fn here made every small stud use 150 facets as well as the
// large ring, which needlessly multiplied the cost of every boolean operation.
$fn = 0;
$fa = $preview ? 12 : 4;
$fs = $preview ? 1 : 0.4;

include <_conf.scad>;
include <RectBrickBuilder.scad>;

include <RoundBrickBuilder.scad>;

// include <ReducerBrickBuilder.scad>;



 // this is it:
 //brick(1,6,3);
 //

	//round_brick(8,8,3, studstyle=1,radius=4,inner_radius=2,degrees=90 );

outer_radius= 4;
inner_radius =1;
// Negate Reduction is 1ease
reduce =0;
height=1;

degrees_start =0;
degrees_end = 90;
attributes = [["thinwall",0],["link",0],
               ["archway",0],
               ["flattop",0],
               ["window",0],
               ["chamfer",0],
               ["corbels",0],
               ["corbel_spacing",30],
               ["corbel_width",12],
               ["corbel_phase",6]];

               
//translate([-BRICK_WIDTH,inner_radius*BRICK_WIDTH,0])
//rectBrick(length=2,width=2,height=3);



  
color("DarkKhaki") {
    roundBrick(
        outer_radius=outer_radius,
        inner_radius=inner_radius,
        reduce=reduce,
        height=height,
        degrees_start=degrees_start,
        degrees_end=degrees_end,
        attributes=attributes
    );
}

/*


    roundBrick(

        outer_radius=6,
        inner_radius=2,
        reduce=0,
        height=3,
      
        degrees_start=60,
        degrees_end =75,
        supports=0,

        attributes =[["flattop",0]]
    ); 
*/
// 


//reducerBrick(5,4,3,degrees=90);


//roundBrick(4,3,3,degrees=90);

// module brick
// 
// create a lego brick length x width x height 
