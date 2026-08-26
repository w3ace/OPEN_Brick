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
include <grid_rectangle_brick.scad>;
include <RoundBrickBuilder.scad>;
include <RoundBattlementBuilder.scad>;
include <grid_circle_brick.scad>;
include <grid_radial_builder.scad>;


radial_brick(
    circumference_studs = 32,
    height = 3,
    studs = 2,
    attributes=[
        ["archway",0,],
        ["masonry",1]]
);




/*
grid_radial_builder(
    circumference_studs=36,
    height=3,
    reduce=.5,
    degrees_start =110,
    degrees_end = 180
);

*/
/*


outer_radius= 7;
inner_radius =5;
    // Negate Reduction is 1ease
reduce = 0;
height=3;

degrees_start =60;
degrees_end = 120;
supports = 0;

attributes = [["thinwall",0],["link",0],
                ["studs",0],
               ["archway",0],
               ["flattop",0],
               ["window",0],
               ["chamfer",0],
               ["corbels",0],
               ["corbel_spacing",30],
               ["corbel_width",12]];

               
               
               
//translate([-BRICK_WIDTH,inner_radius*BRICK_WIDTH,0])
//grid_rectangle_brick(length=2,width=2,height=3);


  
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
};

*/

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


