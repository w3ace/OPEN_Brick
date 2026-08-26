/*

 Basic Lego brick builder module for OpenScad by Jorg Janssen 2013 (CC BY-NC 3.0) 
 To use this in your own projects add:

 use <path_to_this_file/lego_brick_builder.scad>
 
 ## TBD: fix usage

 brick (length, width, height [,smooth]);

 Length and width are in standard lego brick dimensions. 
 Height is in flat brick heights, so for a normal lego brick height = 3.
 Add optional smooth = true for a brick without studs. 
 Use height = 0 to just put studs/knobs on top of other things.
*/
// Let OpenSCAD scale tessellation with the size of each curve.  A fixed $fn
// makes tiny studs as expensive as a complete circular wall.
$fn = 0;
$fa = $preview ? 12 : 4;
$fs = $preview ? 1 : 0.4;

include <_conf.scad>;
include <grid_rectangle_brick.scad>;
include <RoundBrickBuilder.scad>;
// include <ReducerBrickBuilder.scad>;



 // this is it:
 color("gray") 


polygon([[0,0],[0,5],[5,5],[5,10],[10,10],[10,15],[15,15],[15,20],[10,20],[10,25],[5,25],[5,30],[0,30]]);


//longhouseBrick(base=5,length=10);





module longhouseBrick (base=5,length=10) {
    union() {
    for(x= [0:base-1]) {
        translate([0,x*BRICK_WIDTH,0]) {
            grid_rectangle_brick(length,1,3,1);
        }

    }
    }

}

//
