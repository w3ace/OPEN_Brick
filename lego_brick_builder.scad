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

 // this is it:
 color("gray") 
 //brick(1,6,3);
 //
	round_brick(8,8,3, studstyle=1,radius=4,inner_radius=2,degrees=90 );


// module brick
// 
// create a lego brick length x width x height 

module brick(length = 4, width = 2, height = 3, studstyle = 1 ){

	difference() {
		union() {
			make_shell(length,width,height,studstyle);

			// Studs
			if(studstyle>0){
				make_studs(length,width,height,studstyle);
			}
			antistuds(length,width,height,studstyle);
		}
	//	chamfer_corners(length,width,height);
	}
}


// module round_brick
//
// create a circular lego brick 

module round_brick(length = 4, width = 2, height = 3, radius = 2, inner_radius = 1, studstyle = 1,degrees=360) {

	// Round the x and y corners of the brick
	difference() {
		union() {  // Circle , Outer Wall, INner Wall
			intersection() {
				// Combine a brick with circle 
				brick(length,width,height,studstyle);
				translate([length*BRICK_WIDTH/2,width*BRICK_WIDTH/2,0]) {
					linear_extrude(height*2*PLATE_HEIGHT) {
						circle(radius*BRICK_WIDTH);
					}

				}
			}
			// Make Walls for 1/2 and 1/4 circles
			if(degrees<=180) {
				translate([0,length*BRICK_WIDTH/2,0])
					cube([length*BRICK_WIDTH,WALL_THICKNESS,height*PLATE_HEIGHT]);
				if(degrees==90) {
					translate([width*BRICK_WIDTH/2,0,0])
						cube([WALL_THICKNESS,width*BRICK_WIDTH,height*PLATE_HEIGHT]);
				}
			}

			// Outer Wall
			translate([length*BRICK_WIDTH/2,width*BRICK_WIDTH/2,0]) {
				linear_extrude(height*PLATE_HEIGHT) {
					difference() {
						circle(radius*BRICK_WIDTH);
						circle((radius*BRICK_WIDTH)-WALL_THICKNESS);
					}

				}
			}
			// Inner Wall
			translate([length*BRICK_WIDTH/2,width*BRICK_WIDTH/2,0]) {
				linear_extrude(height*PLATE_HEIGHT) {
					difference() {
						circle(inner_radius*BRICK_WIDTH+WALL_THICKNESS);
						circle(inner_radius*BRICK_WIDTH);
					}

				}
			}
		}
		// Inner Radius Cutout
		translate([length*BRICK_WIDTH/2,width*BRICK_WIDTH/2,-CORRECTION]) {
			linear_extrude(height*1.2*PLATE_HEIGHT+CORRECTION) {
				circle(inner_radius*BRICK_WIDTH);
			}
		}
		// Cut circle into 1/2 and 1/4
		if(degrees <= 180) {
			cube([length*BRICK_WIDTH,width*BRICK_WIDTH/2,height*1.2*PLATE_HEIGHT]);
			if(degrees == 90) { 
				cube([length*BRICK_WIDTH/2,width*BRICK_WIDTH,height*1.2*PLATE_HEIGHT]);
			}
		}
		// Make Anti Studs that break the Inner and Outer Walls
		make_studs(length,width,height,studstyle=4);	
	}

}

module chamfer_corners (length,width,height) {

	for (i = [0:1]) {
		for (j = [0:1]) {
			echo (length*i,width*j);
			translate([length*BRICK_WIDTH*i,width*BRICK_WIDTH*j,0])
				linear_extrude(height*1.2*PLATE_HEIGHT)
					rotate([0,0,((i==1) ? 100 : 10)])
					scale([1,5,1])
					square(CORRECTION*4, center=true);
		}
	}
}

module make_shell(length,width,height,studstyle=0) {

	 // brick shell 
	 difference(){
		cube(size = [length*BRICK_WIDTH-CORRECTION,width*BRICK_WIDTH-CORRECTION,height*PLATE_HEIGHT]);
		translate([WALL_THICKNESS,WALL_THICKNESS,-WALL_THICKNESS])
		union(){
			cube(size = [length*BRICK_WIDTH-2*WALL_THICKNESS,width*BRICK_WIDTH-2*WALL_THICKNESS,
                        (height*PLATE_HEIGHT)+(FLU*.25)]);
			// stud inner holes, radius = pin radius
			if (studstyle != 0) {
				translate([STUD_RADIUS+WALL_THICKNESS,STUD_RADIUS+WALL_THICKNESS,height*PLATE_HEIGHT])
				for (y = [0:width-1]){
					for (x = [0:length-1]){
						translate ([x*BRICK_WIDTH-WALL_THICKNESS,y*BRICK_WIDTH-WALL_THICKNESS,-CORRECTION])
						cylinder(h=WALL_THICKNESS+2*CORRECTION,r=PIN_RADIUS);
					}
				} 
			} 
			// small bottom line edge for smooth bricks
			if (studstyle !=0) {
				translate([-WALL_THICKNESS-CORRECTION,-WALL_THICKNESS-CORRECTION,FLU-CORRECTION]) 
				difference() {
					cube([length*BRICK_WIDTH+2*CORRECTION,width*BRICK_WIDTH+2*CORRECTION,EDGE+CORRECTION]);
					translate([EDGE+CORRECTION,EDGE+CORRECTION,-CORRECTION])
					cube([length*BRICK_WIDTH-2*EDGE,width*BRICK_WIDTH-2*EDGE,EDGE+3*CORRECTION]); 
				}
			}
		}
	} 
}

module make_studs (length,width,height,studstyle=1) {

		translate([STUD_RADIUS+WALL_THICKNESS,STUD_RADIUS+WALL_THICKNESS,((studstyle==4) ? 0 : height*PLATE_HEIGHT)])			
		for (y = [0:width-1]){
			for (x = [0:length-1]){
				translate ([x*BRICK_WIDTH,y*BRICK_WIDTH,-CORRECTION])
				// Studstyle 3 Technic style studs
				if (studstyle == 3) {
					difference(){
						cylinder(h=STUD_HEIGHT+CORRECTION, r=STUD_RADIUS);
						// Stud inner holes
						translate([0,0,-CORRECTION])
						cylinder(h=STUD_HEIGHT*2+CORRECTION,r=PIN_RADIUS);
					} 
				} else if (studstyle == 2) {
					// Half filled Stud
					difference(){
						cylinder(h=STUD_HEIGHT+CORRECTION, r=STUD_RADIUS);
						// Stud inner holes
						translate([0,0,-CORRECTION])
							cylinder(h=0.5*STUD_HEIGHT+CORRECTION,r=PIN_RADIUS);
					}
				} else if (studstyle >0) {
					// Fully Filled Stud - Generic - And  (studstyle == 4) - Antistud
					cylinder(h=STUD_HEIGHT+((studstyle==4) ? CORRECTION : CORRECTION*1.4), r=STUD_RADIUS+((studstyle==4) ? CORRECTION*.4 : 0));
				}	

		
			}
		}
	}


module antistuds (length = 4, width = 2, height = 3, studstyle = 1){

	// Pins x
	if (width == 1 && length > 1) {	
		for (x = [1:length-1]){
			if (height > 1 ) {
				if( studstyle == 1) {
					translate([x*BRICK_WIDTH,0.5*BRICK_WIDTH,0]) {
		                union() {
		                    cylinder(h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION,r=PIN_RADIUS);
		                    translate([0,0,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS])
		                        cylinder(h=FLU+CORRECTION,r1=PIN_RADIUS,r2=PIN_RADIUS+1.9);
		                }
		            }
		        }
			}
	   		translate([x*BRICK_WIDTH-0.5*SUPPORT_THICKNESS,CORRECTION,STUD_HEIGHT])
				cube(size=[SUPPORT_THICKNESS,BRICK_WIDTH-2*CORRECTION,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS+CORRECTION]);
		}
	}
	

	// Pins y
	if (length == 1 && width > 1) {	
		for (y = [1:width-1]) {
			translate([0.5*BRICK_WIDTH,y*BRICK_WIDTH,0])
				cylinder(h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION,r=PIN_RADIUS);
			// Supports
			if (height > 1) {
				translate([CORRECTION,y*BRICK_WIDTH-0.5*SUPPORT_THICKNESS,STUD_HEIGHT])
				cube(size=[BRICK_WIDTH-2*CORRECTION,SUPPORT_THICKNESS,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS+CORRECTION]);
			}	
		}
	}
	// Anti Studs
	if (width > 1 && length > 1){
		difference(){
			union(){
				for(y = [1:width-1]){
					for(x = [1:length-1]){
						// anti studs
						translate([x*BRICK_WIDTH,y*BRICK_WIDTH,0])
						cylinder (h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION, r = ANTI_STUD_RADIUS);
						// Supports
						if (height > 1){
							// Support x
	//						if (x%2 == 0 && (length%2 == 0 || length%4 == 1 && x<length/2 || length%4 == 3 && x>length/2) || x%2 == 1 && (length%4 == 3 && x<length/2 || length%4 == 1 && x>length/2)) {
								translate([BRICK_WIDTH*x-0.5*SUPPORT_THICKNESS,y*BRICK_WIDTH-BRICK_WIDTH+WALL_THICKNESS-CORRECTION,STUD_HEIGHT])
                            
                                    cube(size=[SUPPORT_THICKNESS,2*BRICK_WIDTH-2*WALL_THICKNESS,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS+CORRECTION]);

						//	}
							// Supports y							
						//	if (y%2 == 0 && (width%2 == 0 || width%4 == 1 && y<width/2 || width%4 == 3 && y>width/2) || y%2 == 1 && (width%4 == 3 && y<width/2 || width%4 == 1 && y>width/2)) {
								translate([x*BRICK_WIDTH-BRICK_WIDTH+WALL_THICKNESS-CORRECTION,BRICK_WIDTH*y-0.5*SUPPORT_THICKNESS,STUD_HEIGHT])
								cube(size=[2*BRICK_WIDTH-2*WALL_THICKNESS,SUPPORT_THICKNESS,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS+CORRECTION]);
					//		}
						}
					}
				}
			}
			union(){
				for(y = [1:width-1]){
					for(x = [1:length-1]){
						// hollow anti studs
						translate([x*BRICK_WIDTH,y*BRICK_WIDTH,-WALL_THICKNESS])
						cylinder (h=height*PLATE_HEIGHT, r = STUD_RADIUS);				
					}
				}
			}
		}		
	}
}

	