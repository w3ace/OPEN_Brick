/*

Make Round Bricks for 3d printing that are compatible with LEGO brands bricks.


*/



module roundBrick(outer_radius = 2, inner_radius = 1, height = 3, studstyle = 1,topstyle=3,degrees=360, reduce=0,window=0) {

	// roundBrick - build a round toy brick
	// 
	//  outer_radius, inner_radius-			Number of studs wide the outer circle and inner circle will be
	//  
	difference() {
		intersection() {  
			union() {  
				// Draw side walls and top of the building brick
			 	difference() {
					rotate_extrude(angle=degrees,convexity=10) // Take Polygon from below and build 3d circular shape
						translate([(inner_radius+0.01)*BRICK_WIDTH,0,0.01])
							difference() {
								if(reduce > 0) { // Reducer Polygon
									polygon([[0,0],[0,height*PLATE_HEIGHT],
										[((outer_radius-inner_radius-reduce)*BRICK_WIDTH)-0.02,height*PLATE_HEIGHT],
										[((outer_radius-inner_radius)*BRICK_WIDTH)-0.02,PLATE_HEIGHT],
										[((outer_radius-inner_radius)*BRICK_WIDTH)-0.02,0]]);
								} else { // Regular Brick Circle - Rectangle
									square([(outer_radius-inner_radius-0.02)*BRICK_WIDTH,height*PLATE_HEIGHT]);
								}
								translate([WALL_THICKNESS,0,0])
									if(reduce > 0) { // Reducer Polygon
										polygon([[0,0],
												[0,height*PLATE_HEIGHT-WALL_THICKNESS],
												[((outer_radius-inner_radius-reduce)*BRICK_WIDTH-WALL_THICKNESS)-0.02,height*PLATE_HEIGHT-WALL_THICKNESS],
												[((outer_radius-inner_radius)*BRICK_WIDTH-WALL_THICKNESS*2)-0.02,PLATE_HEIGHT],
												[((outer_radius-inner_radius)*BRICK_WIDTH-WALL_THICKNESS*2)-0.02,0]]);
									} else {  // rectangle brick body 
										square([(outer_radius-inner_radius-0.02)*BRICK_WIDTH-WALL_THICKNESS*2,height*PLATE_HEIGHT-WALL_THICKNESS/2]);					
									}
							}
					//  Difference Studs - (studstyle == 4) cuttouts at the bottom in the inner and outer wall where other studs attach		
					makeRoundStuds(outer_radius+1,inner_radius-1,0,4,degrees);
				}
				//  Add Studs on top of Brick where they belong
				makeRoundStuds(outer_radius,inner_radius,height,studstyle,degrees);
				//  Add AntiStuds   Hollow Columns inside Building Brick
				makeRoundAntistuds(outer_radius,inner_radius,height,degrees);

				if(degrees<=180) {
					translate([-outer_radius*BRICK_WIDTH,0,0])
						cube([outer_radius*2*BRICK_WIDTH,WALL_THICKNESS,height*PLATE_HEIGHT]);
		 			if(degrees==90) {
						translate([-WALL_THICKNESS,-outer_radius*BRICK_WIDTH,0])
							cube([WALL_THICKNESS*2,outer_radius*2*BRICK_WIDTH,height*PLATE_HEIGHT]);
					}
				}

				if (window) {  // Windows
					makeWindow(outer_radius,inner_radius,height,degrees,window,1);
				}

			}
				// Intersect to cut studs that stick are part on / part off the circle
			rotate_extrude(angle=degrees,convexity=10)
				translate([(inner_radius+.01)*BRICK_WIDTH,0,0])
				if(reduce > 0) { // Reducer
					polygon([[0,0],[0,height*PLATE_HEIGHT+PLATE_HEIGHT],
						[(outer_radius-inner_radius-reduce)*BRICK_WIDTH,height*PLATE_HEIGHT+PLATE_HEIGHT],
										[((outer_radius-inner_radius-reduce)*BRICK_WIDTH)-0.02,height*PLATE_HEIGHT],
										[((outer_radius-inner_radius)*BRICK_WIDTH)-0.02,PLATE_HEIGHT],
										[((outer_radius-inner_radius)*BRICK_WIDTH)-0.02,0]]);
					echo([[0,0],[0,height*PLATE_HEIGHT],
						[(outer_radius-inner_radius-topstyle+1)*BRICK_WIDTH,height*PLATE_HEIGHT+PLATE_HEIGHT],
						[(outer_radius-inner_radius)*BRICK_WIDTH,PLATE_HEIGHT],
						[(outer_radius-inner_radius)*BRICK_WIDTH,0],[0,0]]);
				} else {
					square([(outer_radius-inner_radius-.02)*BRICK_WIDTH,height*PLATE_HEIGHT*1.2]);
				}
		}

		union() {
			if(window) {
				makeWindow(outer_radius,inner_radius,height,degrees,window);
			}

			// Cut back a small bit of the 90 and 180 brick straight ends to account for 3d printing error	
			if(degrees<=180) {
				translate([-outer_radius*BRICK_WIDTH,0,0])
					cube([outer_radius*2*BRICK_WIDTH,WALL_THICKNESS*.2,height*PLATE_HEIGHT]);
					if(degrees==90) {
						translate([0,-outer_radius*BRICK_WIDTH,0])
							cube([WALL_THICKNESS*.2,outer_radius*2*BRICK_WIDTH,height*PLATE_HEIGHT]);
				}
			}
		}
	}
}


module makeWindow(outer_radius=2,inner_radius=1,height=3,degrees=360,window=1,frame=0) {

	windows = round(inner_radius*5*(degrees/360));
	zoff = height*PLATE_HEIGHT*.3;

	for (i = [(degrees/windows)/2:degrees/windows:degrees]) {
		echo (i,windows);
		translate([0,0,zoff*1.6])
			rotate([-i,90,0]) 
				linear_extrude(outer_radius*BRICK_WIDTH)
					if(frame) {
						polygon([[zoff-WALL_THICKNESS,-PLATE_HEIGHT-WALL_THICKNESS],
							[-zoff*1.2-WALL_THICKNESS,0],[-zoff-WALL_THICKNESS,PLATE_HEIGHT+WALL_THICKNESS],
							[zoff+WALL_THICKNESS,PLATE_HEIGHT+WALL_THICKNESS],[zoff+WALL_THICKNESS,-PLATE_HEIGHT-WALL_THICKNESS]]);
					} else {
						polygon([[-zoff,-PLATE_HEIGHT],[-zoff*1.2,0],[-zoff,PLATE_HEIGHT],
							[zoff,PLATE_HEIGHT],[zoff,-PLATE_HEIGHT]]);
					}
//					square([PLATE_HEIGHT*3,PLATE_HEIGHT*2],center=true);	
	}
}

module makeCobble(outer_radius=2,inner_radius=1,height=3,degrees=360) {

	color("blue")
		translate([outer_radius*BRICK_WIDTH,0,0])
			linear_extrude(BRICK_WIDTH*.2)
				difference() {
					square(PLATE_HEIGHT,PLATE_HEIGHT*2);
					square(PLATE_HEIGHT*.9,PLATE_HEIGHT*1.8);
				}

}



module makeRoundStuds(outer_radius=2,inner_radius=1,height=3,studstyle=1,degrees=360) {

	// Make Studs for Round Bricks that only place studs that are wanted 
	// 
	//  

	for (y = [((degrees<=180)?-.5:-outer_radius-.5):outer_radius-.5]){		
		for (x = [((degrees<=90)?-.5:-outer_radius-.5):outer_radius-.5]){


			if((x*x+y*y <= ((outer_radius+((studstyle==4)?.5:0))*(outer_radius+((studstyle==4)?.5:0))*4)/4) 
					&& (x*x+y*y >= (inner_radius-((studstyle==4)?.5:0))*(inner_radius-((studstyle==4)?.5:0))*4/4)) {
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
						cylinder(h=STUD_HEIGHT+((studstyle==4) ? CORRECTION*1.5: 0), r=STUD_RADIUS+((studstyle==4) ? CORRECTION*.3 : 0));

					}

			}
		}
	}
}

module makeRoundAntistuds(outer_radius=2,inner_radius=1,height=3,degrees=360) {

	difference() {
		union() {
			// Supports between AntiStuds X and y
			for (x = [-outer_radius:outer_radius]){
				translate([x*BRICK_WIDTH,-WALL_THICKNESS,STUD_HEIGHT*1.4+((height*PLATE_HEIGHT-PLATE_HEIGHT-WALL_THICKNESS-STUD_HEIGHT)/2)])
					cube([SUPPORT_THICKNESS,outer_radius*2*BRICK_WIDTH,height*PLATE_HEIGHT-STUD_HEIGHT*1.4*WALL_THICKNESS],center = true);
			}
			for (y = [-outer_radius:outer_radius]){
				translate([-WALL_THICKNESS,y*BRICK_WIDTH,STUD_HEIGHT*1.4+((height*PLATE_HEIGHT-PLATE_HEIGHT-WALL_THICKNESS-STUD_HEIGHT)/2)])
					cube([outer_radius*2*BRICK_WIDTH,SUPPORT_THICKNESS,height*PLATE_HEIGHT-WALL_THICKNESS-STUD_HEIGHT*1.4],center = true);
			}

			// Antistud cylinders
			for (y = [((degrees<=180)?0:-outer_radius):outer_radius]){		
				for (x = [((degrees<=90)?0:-outer_radius):outer_radius]){
					if ((x*x+y*y <= outer_radius*outer_radius*4/4) && (x*x+y*y >= inner_radius*inner_radius*4/4)) {
						translate([x*BRICK_WIDTH,y*BRICK_WIDTH,0])
							cylinder (h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION, r = ANTI_STUD_RADIUS);
								cylinder (h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION, r = ANTI_STUD_RADIUS-WALL_THICKNESS/1.8);
					}
				}
			}
		}

		// Hollow out Antistuds
		for (y = [((degrees<=180)?0:-outer_radius):outer_radius]){		
			for (x = [((degrees<=90)?0:-outer_radius):outer_radius]){
				if((x*x+y*y <= ((outer_radius+.5)*(outer_radius+.5)*4)/4) 
					&& (x*x+y*y >= ((inner_radius-.5)*(inner_radius-.5)*4)/4)) {
					translate ([x*BRICK_WIDTH,y*BRICK_WIDTH,0])
						cylinder (h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION, r = ANTI_STUD_RADIUS-WALL_THICKNESS/2);
				}
			}
		}
	}
}


module oldHollowOutAntistuds (outer_radius=2,inner_radius=1,height=3,degrees=360) {

	// Made the blocks too brittle in PLA

		// Hollow out Antistuds
		for (y = [((degrees<=180)?0:-outer_radius):outer_radius]){		
			for (x = [((degrees<=90)?0:-outer_radius):outer_radius]){
				if((x*x+y*y <= ((outer_radius+.5)*(outer_radius+.5)*4)/4) 
					&& (x*x+y*y >= ((inner_radius-.5)*(inner_radius-.5)*4)/4)) {
				
					// Add holes in counter studs to increase flexibility and decrease plastic use
					if (height>2)
						translate ([x*BRICK_WIDTH-BRICK_WIDTH/4-WALL_THICKNESS/4,y*BRICK_WIDTH+BRICK_WIDTH/4+WALL_THICKNESS/4,PLATE_HEIGHT*1.5])
							rotate ([45,90,0]) 
								cylinder (h=ANTI_STUD_RADIUS*2.1, r = ANTI_STUD_RADIUS-WALL_THICKNESS);
					//		rotate ([45,45,0]) 
						translate ([x*BRICK_WIDTH-BRICK_WIDTH/4-WALL_THICKNESS/4,y*BRICK_WIDTH-BRICK_WIDTH/4+WALL_THICKNESS/4,PLATE_HEIGHT*.75])
							rotate ([-45,90,0])
								cylinder (h=ANTI_STUD_RADIUS*2.1, r = ANTI_STUD_RADIUS-WALL_THICKNESS);
						
				}
			}
		}
}		

