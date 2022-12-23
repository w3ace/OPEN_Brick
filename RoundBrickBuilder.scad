/*

Make Round Bricks for 3d printing that are compatible with LEGO brands bricks.


*/


module roundBrick(outer_radius = 2, inner_radius = 1, height = 3, studstyle = 1,degrees=360) {

	// roundBrick - build a round toy brick
	// 
	//  outer_radius, inner_radius-			Number of studs wide the outer circle and inner circle will be
	//  

 	difference() {
		intersection() {  
			union() {  
				// Draw side walls and top of the building brick
				rotate_extrude()
					translate([(inner_radius+1)*BRICK_WIDTH,0,0])
						difference() {
							square([(outer_radius-inner_radius)*BRICK_WIDTH,height*PLATE_HEIGHT]);
							translate([WALL_THICKNESS,0,0])
								square([(outer_radius-inner_radius)*BRICK_WIDTH-WALL_THICKNESS*2,height*PLATE_HEIGHT-WALL_THICKNESS]);					
						}
				//  Add Studs on top of Brick where they belong
				makeRoundStuds((outer_radius+1),(inner_radius+1),height,studstyle);
				//  Add AntiStuds   Hollow Columns inside Building Brick
				makeRoundAntistuds((outer_radius+1),(inner_radius+1),height);

		if(degrees<=180) {
			translate([-(outer_radius+1)*BRICK_WIDTH,0,0])
				cube([(outer_radius+1)*2*BRICK_WIDTH,WALL_THICKNESS,height*PLATE_HEIGHT]);
			if(degrees==90) {
				translate([-WALL_THICKNESS,-(outer_radius+1)*BRICK_WIDTH,0])
					cube([WALL_THICKNESS,(outer_radius+1)*2*BRICK_WIDTH,height*PLATE_HEIGHT]);
			}
		}


			}
			// Intersect to cut studs that stick are part on / part off the circle
			rotate_extrude()
				translate([(inner_radius+1)*BRICK_WIDTH,0,0])
					square([(outer_radius-inner_radius)*BRICK_WIDTH,height*PLATE_HEIGHT*1.2]);
		}
		//  Difference Studs - (studstyle == 4) cuttouts at the bottom in the inner and outer wall where other studs attach		
		makeRoundStuds((outer_radius+1),(inner_radius+1),0,studstyle=4);	
			// Cut circle into 1/2 and 1/4
		if(degrees <= 180) {
			translate([-(outer_radius+1)*BRICK_WIDTH,-(outer_radius+1)*BRICK_WIDTH,0])
			cube([(outer_radius+1)*BRICK_WIDTH*2,(outer_radius+1)*BRICK_WIDTH,height*1.2*PLATE_HEIGHT]);
			if(degrees == 90) { 
				cube([(outer_radius+1)*BRICK_WIDTH,(outer_radius+1)*BRICK_WIDTH*2,height*1.2*PLATE_HEIGHT]);
			}
		}

	}
}

module makeRoundStuds(outer_radius=2,inner_radius=1,height=3,studstyle=1) {

	// Make Studs for Round Bricks that only place studs that are wanted 
	// 
	//  

	for (y = [-outer_radius-.5:1:outer_radius+.5]){
		for (x = [-outer_radius+.5:1:outer_radius-.5]){


			if((x*x+y*y <= ((outer_radius+((studstyle==4)?.5:0))*(outer_radius+((studstyle==4)?.5:0))*4)/4) && (x*x+y*y >= (inner_radius*inner_radius*4-((studstyle==4)?10:0))/4)) {
				translate ([x*BRICK_WIDTH,y*BRICK_WIDTH,height*PLATE_HEIGHT-CORRECTION])
					if (studstyle == 3) {
					// Studstyle 3 Technic style studs
						difference() {
							cylinder(h=STUD_HEIGHT, r=STUD_RADIUS);
							// Stud inner holes
							translate([0,0,-CORRECTION])
							cylinder(h=STUD_HEIGHT*2,r=PIN_RADIUS);
						} 
					} else {
						// Fully Filled Stud - Generic - And  (studstyle == 4) - Antistud
						cylinder(h=STUD_HEIGHT+((studstyle==4) ? CORRECTION*2 : 0), r=STUD_RADIUS+((studstyle==4) ? CORRECTION*.4 : 0));

					}

			}
		}
	}
}

module makeRoundAntistuds(outer_radius=2,inner_radius=1,height=3) {

	for (y = [-outer_radius:outer_radius]){
		for (x = [-outer_radius:outer_radius]){
			if((x*x+y*y <= ((outer_radius+1)*(outer_radius+1)*4)/4) && (x*x+y*y >= (inner_radius-1*inner_radius-1*4)/4)) {
				translate([x*BRICK_WIDTH,y*BRICK_WIDTH,0])
					difference() {
						cylinder (h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION, r = ANTI_STUD_RADIUS);
						cylinder (h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION, r = ANTI_STUD_RADIUS-WALL_THICKNESS/2);
					}
			}
		}
	}
}		

// module round_brick
//
// create a circular lego brick 

module oldRoundBrick(length = 4, width = 2, height = 3, radius = 2, inner_radius = 1, studstyle = 1,degrees=360) {

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