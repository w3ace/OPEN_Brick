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
brick(4,1,2, studstyle =3);

module make_shell(length,width,height,smooth,studstyle) {

	 // brick shell /*
	 difference(){
		cube(size = [length*BRICK_WIDTH,width*BRICK_WIDTH,height*PLATE_HEIGHT]);
		translate([WALL_THICKNESS,WALL_THICKNESS,-WALL_THICKNESS])
		union(){
			cube(size = [length*BRICK_WIDTH-2*WALL_THICKNESS,width*BRICK_WIDTH-2*WALL_THICKNESS,
                        (height*PLATE_HEIGHT)+(FLU*.25)]);
			// stud inner holes, radius = pin radius
			if (!smooth && studstyle > 1) {
				translate([STUD_RADIUS+WALL_THICKNESS,STUD_RADIUS+WALL_THICKNESS,height*PLATE_HEIGHT])
				for (y = [0:width-1]){
					for (x = [0:length-1]){
						translate ([x*BRICK_WIDTH-WALL_THICKNESS,y*BRICK_WIDTH-WALL_THICKNESS,-CORRECTION])
						cylinder(h=WALL_THICKNESS+2*CORRECTION,r=PIN_RADIUS);
					}
				} 
			} 
			// small bottom line edge for smooth bricks
			if (smooth) {
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

module make_studs (length,width,height,studstyle,logo) {

		translate([STUD_RADIUS+WALL_THICKNESS,STUD_RADIUS+WALL_THICKNESS,height*PLATE_HEIGHT])
		for (y = [0:width-1]){
			for (x = [0:length-1]){
				translate ([x*BRICK_WIDTH,y*BRICK_WIDTH,-CORRECTION])
				if (studstyle == 3) {
					difference(){
						cylinder(h=STUD_HEIGHT+CORRECTION, r=STUD_RADIUS);
						// Stud inner holes
						translate([0,0,-CORRECTION])
						cylinder(h=STUD_HEIGHT*2+CORRECTION,r=PIN_RADIUS);
					} 
				} else {
					difference(){
						cylinder(h=STUD_HEIGHT+CORRECTION, r=STUD_RADIUS);
						// Stud inner holes
						translate([0,0,-CORRECTION])
						cylinder(h=0.5*STUD_HEIGHT+CORRECTION,r=PIN_RADIUS);
					} 
				}
				// tech logo - disable this if your printer isn't capable of printing this small
				if (logo == 2) {
					if ( length > width){
						translate([x*BRICK_WIDTH+0.8,y*BRICK_WIDTH-1.9,STUD_HEIGHT-CORRECTION])
						resize([1.2*1.7,2.2*1.7,0.254+CORRECTION])
						rotate(a=[0,0,90])
						import("tech.stl"); 
					}
					else {
						translate([x*BRICK_WIDTH-1.9,y*BRICK_WIDTH-0.8,STUD_HEIGHT-CORRECTION])
						resize([2.2*1.7,1.2*1.7,0.254+CORRECTION])
						import("tech.stl");				
					}		
				}	
				if (logo == 3) {
					translate ([x*BRICK_WIDTH+CORRECTION,y*BRICK_WIDTH-CORRECTION,STUD_HEIGHT-CORRECTION])		
					cube([1,1,2*CORRECTION]);
					translate ([x*BRICK_WIDTH-0.9,y*BRICK_WIDTH-0.9,STUD_HEIGHT-CORRECTION])		
					cube([1,1,0.3]);
				}	
			}
		}
	}

module brick(length = 4, width = 2, height = 3, smooth = false, studstyle = 1, logo = 1 ){

	make_shell(length,width,height,smooth,studstyle);

	// Studs
	if(!smooth){
		make_studs(length,width,height,studstyle,logo);
	}

	// Pins x
	if (width == 1 && length > 1) {	
			for (x = [1:length-1]){
				if (height > 1 && studstyle == 1) {
					translate([x*BRICK_WIDTH,0.5*BRICK_WIDTH,0]) {
		                union() {
		                    cylinder(h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION,r=PIN_RADIUS);
		                    translate([0,0,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS])
		                        cylinder(h=FLU+CORRECTION,r1=PIN_RADIUS,r2=PIN_RADIUS+1.9);
		                }
		            }
	   				translate([x*BRICK_WIDTH-0.5*SUPPORT_THICKNESS,CORRECTION,STUD_HEIGHT])
					cube(size=[SUPPORT_THICKNESS,BRICK_WIDTH-2*CORRECTION,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS+CORRECTION]);
				} else {
					translate([x*BRICK_WIDTH,0.5*BRICK_WIDTH,0]) 
		            cylinder(h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION,r=PIN_RADIUS);
		            
		        }
			}
		}
	

	// Pins y
	if (length == 1 && width > 1) {	
			for (y = [1:width-1]){
			translate([0.5*BRICK_WIDTH,y*BRICK_WIDTH,0])
			cylinder(h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION,r=PIN_RADIUS);
			// Supports
			if (height > 1) {
			translate([CORRECTION,y*BRICK_WIDTH-0.5*SUPPORT_THICKNESS,STUD_HEIGHT])
			cube(size=[BRICK_WIDTH-2*CORRECTION,SUPPORT_THICKNESS,height*PLATE_HEIGHT-STUD_HEIGHT-WALL_THICKNESS+CORRECTION]);}
			
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

	