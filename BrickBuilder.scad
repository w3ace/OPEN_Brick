/*

 Basic Lego brick builder module for OpenScad by Jorg Janssen 2013 (CC BY-NC 3.0) 
 To use this in your own projects add:

 use <path_to_this_file/lego_brick_builder.scad>
 brick (length, width, height [,smooth]);

 Length and width are in standard lego brick dimensions. 
 Height is in flat brick heights, so for a normal lego brick height = 3.
 Add optional smooth = true for a brick without studs. 
 Use height = 0 to just put studs/knobs on top of other things.
*/
$fn = 100;

include <_conf.scad>;
include <RectBrickBuilder.scad>;
include <RoundBrickBuilder.scad>;
// include <ReducerBrickBuilder.scad>;



 // this is it:
 color("green") 
 //brick(1,6,3);
 //

	//round_brick(8,8,3, studstyle=1,radius=4,inner_radius=2,degrees=90 );

roundBrick(3,0,9,reduce=2,degrees=360);
//

//reducerBrick(5,4,3,degrees=90);


//roundBrick(4,3,3,degrees=90);

// module brick
// 
// create a lego brick length x width x height 

