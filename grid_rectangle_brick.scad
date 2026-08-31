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

include <BrickFunctions.scad>;

module grid_rectangle_brick (length = 4, width = 2, height = 3, studstyle = 1,
	attributes = [] ){
	masonry = attributeValue(attributes, "masonry", 0);

	difference() {
		union() {
			makeShell(length,width,height,studstyle);

			// Studs
			if(studstyle>0){
				makeStuds(length,width,height,studstyle);
			}
			antistuds(length,width,height,studstyle);
		}
		if (masonry > 0)
			_grid_rectangle_masonry(length, width, height*PLATE_HEIGHT);
	//	chamfer_corners(length,width,height);
	}
}

// Cut the same shallow, 45-degree-raked running-bond joints used by
// radial_brick().  Bed joints wrap all four faces, while alternate courses
// offset upright joints by half a stud pitch.
module _grid_rectangle_masonry(length, width, brick_height) {
	joint_depth = min(1, WALL_THICKNESS/2);
	joint_width = .45;
	course_height = 1.5*PLATE_HEIGHT;
	course_count = ceil(brick_height/course_height);
	x_size = length*BRICK_WIDTH-CORRECTION;
	y_size = width*BRICK_WIDTH-CORRECTION;

	// Extending the first and last bed joints across the body boundary bevels
	// the edges of the bottom and top courses as on a radial masonry brick.
	for (z = [0, brick_height])
		_grid_rectangle_bed_joint(x_size, y_size, z, joint_width, joint_depth);

	if (course_count > 1)
		for (course = [1:course_count-1])
			if (course*course_height < brick_height)
				_grid_rectangle_bed_joint(
					x_size, y_size, course*course_height,
					joint_width, joint_depth
				);

	for (course = [0:course_count-1]) {
		course_bottom = course*course_height;
		course_top = min((course+1)*course_height, brick_height);
		phase = (course % 2)*BRICK_WIDTH/2;

		for (x = [phase:BRICK_WIDTH:x_size])
			if (x > joint_width/2 && x < x_size-joint_width/2)
				_grid_rectangle_upright_joint(
					x, course_bottom, course_top-course_bottom,
					y_size, true, joint_width, joint_depth
				);
		for (y = [phase:BRICK_WIDTH:y_size])
			if (y > joint_width/2 && y < y_size-joint_width/2)
				_grid_rectangle_upright_joint(
					y, course_bottom, course_top-course_bottom,
					x_size, false, joint_width, joint_depth
				);
	}
}

module _grid_rectangle_bed_joint(x_size, y_size, z, joint_width, depth) {
	_grid_rectangle_face_joint(x_size, 0, z, joint_width, y_size, depth, true);
	_grid_rectangle_face_joint(x_size, y_size, z, joint_width, y_size, depth, true);
	_grid_rectangle_face_joint(y_size, 0, z, joint_width, x_size, depth, false);
	_grid_rectangle_face_joint(y_size, x_size, z, joint_width, x_size, depth, false);
}

module _grid_rectangle_upright_joint(position, z, height, face_length,
		x_faces, joint_width, depth) {
	if (x_faces) {
		_grid_rectangle_face_joint(position, 0, z+height/2, height,
			face_length, depth, false, joint_width);
		_grid_rectangle_face_joint(position, face_length, z+height/2, height,
			face_length, depth, false, joint_width);
	} else {
		_grid_rectangle_face_joint(position, 0, z+height/2, height,
			face_length, depth, true, joint_width);
		_grid_rectangle_face_joint(position, face_length, z+height/2, height,
			face_length, depth, true, joint_width);
	}
}

// `along_x` selects a face parallel to X.  The optional `span` makes an
// upright cutter; otherwise the cutter spans the complete face for a bed
// joint.  Hull between the narrow face slot and wider recessed slot produces
// the 45-degree rake.
module _grid_rectangle_face_joint(position, face, z, joint_height,
		face_length, depth, along_x=true, span=undef) {
	overlap = .08;
	upright = !is_undef(span);
	face_width = upright ? span : face_length+2*overlap;
	inside_width = face_width+2*depth;
	inside_height = joint_height+2*depth;
	far_face = face > 0;

	hull() {
		if (along_x)
			translate([
				upright ? position-face_width/2 : -overlap,
				far_face ? face-overlap : -overlap,
				z-joint_height/2
			]) cube([face_width, overlap*2, joint_height]);
		else
			translate([
				far_face ? face-overlap : -overlap,
				upright ? position-face_width/2 : -overlap,
				z-joint_height/2
			]) cube([overlap*2, face_width, joint_height]);

		if (along_x)
			translate([
				upright ? position-inside_width/2 : -overlap,
				far_face ? face-depth : depth-overlap,
				z-inside_height/2
			]) cube([upright ? inside_width : face_width, overlap, inside_height]);
		else
			translate([
				far_face ? face-depth : depth-overlap,
				upright ? position-inside_width/2 : -overlap,
				z-inside_height/2
			]) cube([overlap, upright ? inside_width : face_width, inside_height]);
	}
}

module makeShell(length,width,height,studstyle=0) {

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

module makeStuds (length,width,height,studstyle=1) {

		translate([STUD_RADIUS+WALL_THICKNESS,STUD_RADIUS+WALL_THICKNESS,((studstyle==4) ? 0 : height*PLATE_HEIGHT)])			
		for (y = [0:width-1]){
			for (x = [0:length-1]){
				translate ([x*BRICK_WIDTH,y*BRICK_WIDTH,-CORRECTION])
				// Studstyle 3 Technic style studs
				if (studstyle == 3) {
					difference(){
						cylinder(h=STUD_HEIGHT, r=STUD_RADIUS);
						// Stud inner holes
						cylinder(h=STUD_HEIGHT*2,r=PIN_RADIUS);
					} 
				} else if (studstyle == 2) {
					// Half filled Stud
					difference(){
						cylinder(h=STUD_HEIGHT, r=STUD_RADIUS);
						// Stud inner holes
							cylinder(h=0.5*STUD_HEIGHT,r=PIN_RADIUS);
					}
				} else if (studstyle >0) {
					// Fully Filled Stud - Generic - And  (studstyle == 4) - Antistud
					cylinder(h=STUD_HEIGHT, r=STUD_RADIUS+((studstyle==4) ? .4 : 0));
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

	