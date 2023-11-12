/*

Make Round Bricks for 3d printing that are compatible with LEGO brands bricks.


*/



module roundBrick(		outer_radius = 2, inner_radius = 1, reduce=0, height = 3, 
						degrees_start=10, degrees_end=360, thinwall=0, window=0,	chamfer=0,supports=0) {
	// window=0, chamfer=0, supports=0) {

	// roundBrick - build a round toy brick
	// 
	//  outer_radius, inner_radius-			Number of studs wide the outer circle and inner circle will be
	//  

		brick_polygon = (reduce>0) ? [[0,BRICK_BOTTOM],[0,height*PLATE_HEIGHT], 
							[(((outer_radius-inner_radius-reduce==0)?.5:outer_radius-inner_radius-reduce))*BRICK_WIDTH,height*PLATE_HEIGHT],
							[((outer_radius-inner_radius)*BRICK_WIDTH),PLATE_HEIGHT],
							[((outer_radius-inner_radius)*BRICK_WIDTH),BRICK_BOTTOM],[0,BRICK_BOTTOM]]
					: (reduce < 0) ? [[0,BRICK_BOTTOM],[0,height*PLATE_HEIGHT],
							[((outer_radius-inner_radius)*BRICK_WIDTH),height*PLATE_HEIGHT],
							// Drop the outer edge of the polygon for battlements
							[((outer_radius-inner_radius)*BRICK_WIDTH),height*PLATE_HEIGHT-PLATE_HEIGHT*((supports>0) ? supports : .3)],
							[((outer_radius-inner_radius+reduce)*BRICK_WIDTH),BRICK_BOTTOM*((supports>0)?1:1)],
							[((outer_radius-inner_radius+reduce)*BRICK_WIDTH),BRICK_BOTTOM],
							[0,BRICK_BOTTOM]]
					: [[0,BRICK_BOTTOM],
							[0,height*PLATE_HEIGHT],
							[(outer_radius-inner_radius)*BRICK_WIDTH,height*PLATE_HEIGHT],
							[(outer_radius-inner_radius)*BRICK_WIDTH,BRICK_BOTTOM],
							[0,BRICK_BOTTOM]	] ; 

		brick_intersect_polygon = (reduce>0) ?		[	[0,0],[0,height*PLATE_HEIGHT+PLATE_HEIGHT],
							[(((outer_radius-inner_radius-reduce==0)?.5:outer_radius-inner_radius-reduce))*BRICK_WIDTH,height*PLATE_HEIGHT+PLATE_HEIGHT],
							[(((outer_radius-inner_radius-reduce==0)?.5:outer_radius-inner_radius-reduce))*BRICK_WIDTH,height*PLATE_HEIGHT],
							[((outer_radius-inner_radius)*BRICK_WIDTH),PLATE_HEIGHT],
							[((outer_radius-inner_radius)*BRICK_WIDTH),0],[0,0]]
					: (reduce < 0) ?	[[0,0],[0,height*PLATE_HEIGHT+PLATE_HEIGHT],
							[((outer_radius-inner_radius)*BRICK_WIDTH),height*PLATE_HEIGHT+PLATE_HEIGHT],
							[(outer_radius-inner_radius)*BRICK_WIDTH,height*PLATE_HEIGHT-PLATE_HEIGHT*((supports>0) ? supports : .3)],
							[((outer_radius-inner_radius+reduce)*BRICK_WIDTH),BRICK_BOTTOM*((supports>0)?1:1)],
							[((outer_radius-inner_radius+reduce)*BRICK_WIDTH),0],[0,0]]
					: [[0,0],[0,height*PLATE_HEIGHT*1.2],
							[(outer_radius-inner_radius)*BRICK_WIDTH,height*PLATE_HEIGHT*1.2],
							[(outer_radius-inner_radius)*BRICK_WIDTH,0],
							[0,0]]			;	

		thinwall_polygon = [[-.1,BRICK_BOTTOM+WALL_THICKNESS/3],[-.1,(height*PLATE_HEIGHT)-WALL_THICKNESS],
							[((outer_radius-inner_radius-abs(reduce))*BRICK_WIDTH)-WALL_THICKNESS,height*PLATE_HEIGHT-(outer_radius-inner_radius)*BRICK_WIDTH*0.6],
							[((outer_radius-inner_radius-abs(reduce))*BRICK_WIDTH)-WALL_THICKNESS,BRICK_BOTTOM+WALL_THICKNESS/3],				
							[-.1,BRICK_BOTTOM+WALL_THICKNESS/3]]			;	

		bottom_polygon = [[0,0],[0,BRICK_BOTTOM],
							[(outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH,BRICK_BOTTOM],
							[(outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH,0], 
							[0,0]];

		bottom_difference_polygon = (inner_radius == 0) ? [[0,0],[0,BRICK_BOTTOM+.2],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,BRICK_BOTTOM+.2],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,-.1], [0,0]]

					: [[WALL_THICKNESS,0],[WALL_THICKNESS,BRICK_BOTTOM+.2],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,BRICK_BOTTOM+.2],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,0], [WALL_THICKNESS,0] ];

		supports_difference_polygon = [[0,BRICK_BOTTOM],[0,height*PLATE_HEIGHT*.65],
							[(outer_radius-inner_radius)*BRICK_WIDTH,height*PLATE_HEIGHT+PLATE_HEIGHT],
							[(outer_radius-inner_radius)*BRICK_WIDTH,BRICK_BOTTOM],
							[0,BRICK_BOTTOM]];


echo (brick_polygon);
	difference() {

		// Trim Edges off 
		intersection() {  


			// Block Creation
			union() {
				difference() {
					union() {
						// MAIN BRICK POLYGON
						rotate([0,0,degrees_start])
							rotate_extrude(angle=degrees_end-degrees_start,convexity=10) // Take Polygon from below and build 3d circular shape
								translate([inner_radius*BRICK_WIDTH,0,0])
									polygon(brick_polygon);

						// LOWER BRICK SHELL - Difference of two polygons.
						difference() {
							rotate([0,0,degrees_start])
								rotate_extrude(angle=degrees_end-degrees_start,convexity=10) // Take Polygon from below and build 3d circular shape
									translate([inner_radius*BRICK_WIDTH,0,0])
										polygon(bottom_polygon); 
							rotate([0,0,degrees_start+((degrees_start != 0 || degrees_end != 360) ? 4 : 0)])
								rotate_extrude(angle=degrees_end-degrees_start-((degrees_start != 0 || degrees_end != 360) ? 8 : 0),convexity=10) // Take Polygon from below and build 3d circular shape
									translate([inner_radius*BRICK_WIDTH,-.2,0])
										polygon(bottom_difference_polygon);

						}

						//	echo (bottom_difference_polygon);
						//  Add Studs on top of Brick where they belong
						//  Reduce here gets to actual rows of studs on top.

						makeRoundStuds(outer_radius-reduce,inner_radius,height,1,degrees_start,degrees_end);

						if (window ==1 ) {  // Windows
								makeCathedralWindows(outer_radius,inner_radius,height,degrees_start,degrees_end,window,1);
							} else {	
						//		makeArcherWindows(outer_radius,inner_radius,height,degrees_end,window,1);					
						}
					}
				
					makeRoundStuds(outer_radius+1,inner_radius-1,0,4,degrees_start,degrees_end);
				}

			//  Add AntiStuds   Hollow Columns inside Building Brick
			makeRoundAntistuds(outer_radius,inner_radius,height,degrees_end);			
		}


			// Intersect to cut studs that stick are part on / part off the circle

			rotate([0,0,degrees_start])
				rotate_extrude(angle=degrees_end-degrees_start,convexity=10)
					translate([inner_radius*BRICK_WIDTH,0,0])
						polygon(brick_intersect_polygon);

		} 

		union() {
			if(window ==1) {
			//		echo (degrees_end,degrees_start);
					makeCathedralWindows(outer_radius,inner_radius,height,degrees_start,degrees_end,window);
			} else {
	//			makeArcherWindows(outer_radius,inner_radius,height,degrees_end,window);					
			}


		// Trim a small amount for 3D printing corner bulge ( unless 360 degree brick )

			if (degrees_end-degrees_start < 360) {

				rotate([0,0,degrees_start])
					cube([outer_radius*BRICK_WIDTH+.2,WALL_THICKNESS*.2,height*PLATE_HEIGHT+.2]);
		
				rotate([0,0,degrees_end])
					translate([0,-WALL_THICKNESS*.2,0])
						cube([outer_radius*BRICK_WIDTH+.2,WALL_THICKNESS*.2,height*PLATE_HEIGHT+.2]);
			}

			//  Hollow out Brick for thinwall design

			if(thinwall) {
				rotate([0,0,degrees_start+5])
					rotate_extrude(angle=degrees_end-degrees_start-10,convexity=10) // Take Polygon from below and build 3d circular shape
						translate([(inner_radius)*BRICK_WIDTH,0])
							polygon(thinwall_polygon); 
			}

		// Chamfer Corners TODO: Make a reduce Chamfer. 

			if(chamfer==1) {
				rotate([0,0,degrees_start])
					translate([inner_radius*BRICK_WIDTH,0,(height*PLATE_HEIGHT+PLATE_HEIGHT)/2]) 
						rotate([0,0,45])
							cube([WALL_THICKNESS,WALL_THICKNESS ,height*PLATE_HEIGHT+PLATE_HEIGHT],center = true);
				rotate([0,0,degrees_end])
					translate([inner_radius*BRICK_WIDTH,0,(height*PLATE_HEIGHT+PLATE_HEIGHT)/2]) 
						rotate([0,0,45])
							cube([WALL_THICKNESS,WALL_THICKNESS ,height*PLATE_HEIGHT+PLATE_HEIGHT],center = true);
				rotate([0,0,degrees_start])
					translate([outer_radius*BRICK_WIDTH,0,(height*PLATE_HEIGHT+PLATE_HEIGHT)/2]) 
						rotate([0,0,45])
							cube([WALL_THICKNESS,WALL_THICKNESS ,height*PLATE_HEIGHT+PLATE_HEIGHT],center = true);
				rotate([0,0,degrees_end])
					translate([outer_radius*BRICK_WIDTH,0,(height*PLATE_HEIGHT+PLATE_HEIGHT)/2]) 
						rotate([0,0,45])
							cube([WALL_THICKNESS,WALL_THICKNESS ,height*PLATE_HEIGHT+PLATE_HEIGHT],center = true);
			}


			// Supports cutouts
			if(supports>0 && reduce<0) {
				for(i=[6:30:360]) {
					if ( i+30>=degrees_start && i-30 <= degrees_end) {
							rotate([0,0,i])
								rotate_extrude(angle=18,convexity=10)
									translate([(outer_radius+reduce)*BRICK_WIDTH,0])
										polygon(supports_difference_polygon);
					}

				

				}


			}



		}  
		
	} 

}



module makeCathedralWindows(outer_radius=2,inner_radius=1,height=3,degrees_start=0,degrees_end,window=1,frame=0) {

    stained_glass_window_polygon = [[-PLATE_HEIGHT,PLATE_HEIGHT*1.5],[-PLATE_HEIGHT,PLATE_HEIGHT*height*.7],
        [0,PLATE_HEIGHT*height*.85],[PLATE_HEIGHT,PLATE_HEIGHT*height*.7],
        [PLATE_HEIGHT,PLATE_HEIGHT*1.5],[0,PLATE_HEIGHT*1.5]];


	for (i = [(degrees_start+15):30:(degrees_end-15)]) {
		rotate([0,0,i])
		    translate([inner_radius*BRICK_WIDTH-.2,0,0])
		        rotate([90,0,90])
		            linear_extrude( height=(outer_radius-inner_radius)*BRICK_WIDTH+.4,convexity = 10)
		            	polygon(stained_glass_window_polygon);
	}
}

module makeRoundStuds(outer_radius=2,inner_radius=1,height=3,studstyle=1,degrees_start=0,degrees_end=360, reduce=0) {

	// Make Studs for Round Bricks that only place studs that are wanted 
	// 
	//  

	// Ugly test to shift the grid of top studs.
    xoff = (outer_radius-inner_radius == 0) ? 0 : .5;
    yoff = (outer_radius-inner_radius == 0) ? 0 : .5;

    echo (outer_radius, inner_radius, reduce, xoff,yoff);

	for (y = [((degrees_end<=180)?-yoff:-outer_radius-yoff):outer_radius-yoff]){		
		for (x = [((degrees_end<=90)?-xoff:-outer_radius-xoff):outer_radius-xoff]){

			if( ( x*x+y*y <= ((outer_radius+((studstyle==4)?.5:0))*(outer_radius+((studstyle==4)?.5:0)))) //*4)/4) 
				&& (x*x+y*y >= ((inner_radius-((studstyle==4)?.5:0))*(inner_radius-((studstyle==4)?.5:0))))
				&& ((atan2(y,x)+360)%360) > degrees_start - ((studstyle==4)?5:0) // ((inner_radius == 0) ? -5 : 0))
				 && ((atan2(y,x)+360)%360) < degrees_end + ((studstyle==4)?5:0)
				) { //*4)/4)) {

//echo("HIT ---->  ",x,y,degrees_end,offset,atan2(y,x)%360);

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
						union() {
						// Fully Filled Stud - Generic - And  (studstyle == 4) - Antistud
							cylinder(h=STUD_HEIGHT + ((studstyle==4) ? .1 : 0), 
								r=STUD_RADIUS + ((studstyle==4) ? .15 : 0));
				//			if (studstyle==4) { cylinder(h=PLATE_HEIGHT*0.3,r=STUD_RADIUS+.4); }
						}

					}

			}
		}
	}
}

module makeRoundAntistuds(outer_radius=2,inner_radius=1,height=3,degrees_end=360) {

//	difference() {
//		union() {



			// Antistud cylinders
			for (y = [((degrees_end<=180)?0:-outer_radius):outer_radius]){		
				for (x = [((degrees_end<=90)?0:-outer_radius):outer_radius]){


		/*	if( ( x*x+y*y <= ((outer_radius+((studstyle==4)?.5:0))*(outer_radius+((studstyle==4)?.5:0)))) //*4)/4) 
				&& (x*x+y*y >= ((inner_radius-((studstyle==4)?.5:0))*(inner_radius-((studstyle==4)?.5:0))))
				 && ((atan2(y,x)+360)%360) >= degrees_start
				 && ((atan2(y,x)+360)%360) <= degrees_end
				) { */

					if ((x*x+y*y <= outer_radius*outer_radius*4/4) 
						&& (x*x+y*y >= inner_radius*inner_radius*4/4)
						&& ((atan2(y,x)+360)%360) >= degrees_start
						&& ((atan2(y,x)+360)%360) < degrees_end) {
						translate([x*BRICK_WIDTH,y*BRICK_WIDTH,0])
							difference() {
								cylinder (h=BRICK_BOTTOM+.2, r = ANTI_STUD_RADIUS);
								translate([0,0,-.2])
									cylinder (h=BRICK_BOTTOM+.2, r = ANTI_STUD_RADIUS-WALL_THICKNESS*.6);
							}

							//	cylinder (h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION, r = ANTI_STUD_RADIUS-WALL_THICKNESS/1.8);
					}
				}
			}



	//	}

		// Hollow out Antistuds
	/*	for (y = [((degrees_end<=180)?0:-outer_radius):outer_radius]){
			for (x = [((degrees_end<=90)?0:-outer_radius):outer_radius]){
				if((x*x+y*y <= ((outer_radius+.5)*(outer_radius+.5)*4)/4) 
					&& (x*x+y*y >= ((inner_radius-.5)*(inner_radius-.5)*4)/4)) { 
					translate ([x*BRICK_WIDTH,y*BRICK_WIDTH,-.1])
						cylinder (h=BRICK_BOTTOM+0.12, r = ANTI_STUD_RADIUS-WALL_THICKNESS/2);
				}
			}
		}  */


			// Supports between AntiStuds X and y
	/*		for (x = [-outer_radius:outer_radius]){
				translate([x*BRICK_WIDTH,-WALL_THICKNESS,STUD_HEIGHT*1.4+((height*PLATE_HEIGHT-PLATE_HEIGHT-WALL_THICKNESS-STUD_HEIGHT)/2)])
					cube([SUPPORT_THICKNESS,outer_radius*2*BRICK_WIDTH,height*PLATE_HEIGHT-STUD_HEIGHT*1.4*WALL_THICKNESS],center = true);
			}
			for (y = [-outer_radius:outer_radius]){
				translate([-WALL_THICKNESS,y*BRICK_WIDTH,STUD_HEIGHT*1.4+((height*PLATE_HEIGHT-PLATE_HEIGHT-WALL_THICKNESS-STUD_HEIGHT)/2)])
					cube([outer_radius*2*BRICK_WIDTH,SUPPORT_THICKNESS,height*PLATE_HEIGHT-WALL_THICKNESS-STUD_HEIGHT*1.4],center = true);
			} */


}


module oldHollowOutAntistuds (outer_radius=2,inner_radius=1,height=3,degrees_end=360) {

	// Made the blocks too brittle in PLA

		// Hollow out Antistuds
		for (y = [((degrees_end<=180)?0:-outer_radius):outer_radius]){		
			for (x = [((degrees_end<=90)?0:-outer_radius):outer_radius]){
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

