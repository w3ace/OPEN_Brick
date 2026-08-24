/*

Make Round Bricks for 3d printing that are compatible with LEGO brands bricks.

*/

include <BrickFunctions.scad>;


module roundBrick(		outer_radius=2, inner_radius = 1, reduce=0, height = 3, 
						degrees_start=10, degrees_end=360,  supports=0, attributes = [] ) {

	// Resolve the public attribute list once.  Previously the list was scanned
	// three times while building the same brick, adding unnecessary CSG nodes
	// and making the effects of each option harder to follow.
	flattop = attributeValue(attributes, "flattop", 0);
	window = attributeValue(attributes, "window", 0);
	chamfer = attributeValue(attributes, "chamfer", 0);
	thinwall = attributeValue(attributes, "thinwall", 0);
	archway = attributeValue(attributes, "archway", 0);
	link = attributeValue(attributes, "link", 0);
	// `supports` is retained as a fallback for models made with the old API.
	// New models should describe the flare's corbels entirely through attributes.
	corbels = attributeValue(attributes, "corbels", supports);
	corbel_spacing = attributeValue(attributes, "corbel_spacing", 30);
	corbel_width = attributeValue(attributes, "corbel_width", 12);
	corbel_phase = attributeValue(attributes, "corbel_phase", 6);


//	thinwall=0, window=0,	chamfer=0,
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
							[((outer_radius-inner_radius)*BRICK_WIDTH),height*PLATE_HEIGHT-PLATE_HEIGHT*((corbels>0) ? corbels : .3)],
							[((outer_radius-inner_radius+reduce)*BRICK_WIDTH),BRICK_BOTTOM],
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
							[(outer_radius-inner_radius)*BRICK_WIDTH,height*PLATE_HEIGHT-PLATE_HEIGHT*((corbels>0) ? corbels : .3)],
							[((outer_radius-inner_radius+reduce)*BRICK_WIDTH),BRICK_BOTTOM],
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

		bottom_difference_polygon = (inner_radius == 0) ? [[0,0],[0,STUD_HEIGHT+.3],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,STUD_HEIGHT+.3],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,-.1], [0,0]]

					: [[WALL_THICKNESS,0],[WALL_THICKNESS,STUD_HEIGHT+.3],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,STUD_HEIGHT+.3],
							[((outer_radius-inner_radius+((reduce<0) ? reduce:0))*BRICK_WIDTH)-WALL_THICKNESS,0], [WALL_THICKNESS,0] ];

		// Give the cutter a small overlap on every CSG boundary.  The old cutter
		// shared its bottom and inner radial faces with the flare and extended a
		// full annulus beyond it.  OpenSCAD's preview could consequently leave
		// coincident fragments (and display the subtraction far outside the
		// corbels).  A negative reduction makes the flare exactly -reduce studs
		// deep, so limit the cutter to that region.
		corbel_overlap = .01;
		corbel_depth = -reduce*BRICK_WIDTH*1.1;
		corbel_gap_polygon = [[-corbel_overlap,BRICK_BOTTOM-corbel_overlap],
							[-corbel_overlap,height*PLATE_HEIGHT*.5],
							[corbel_depth+corbel_overlap,height*PLATE_HEIGHT],
							[corbel_depth+corbel_overlap,BRICK_BOTTOM-corbel_overlap]];

		inner_difference_polygon = [[0,0],[0,height*PLATE_HEIGHT+PLATE_HEIGHT*2],
							[BRICK_WIDTH,height*PLATE_HEIGHT+PLATE_HEIGHT*2],
							[BRICK_WIDTH,0],[0,0]];



	// Take things away from finished brick.						
	difference() {

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
							rotate([0,0,degrees_start])
								rotate_extrude(angle=degrees_end-degrees_start,convexity=10) // Take Polygon from below and build 3d circular shape
									translate([inner_radius*BRICK_WIDTH,0,0])
										polygon(bottom_difference_polygon);

						}                        

						// Bottom Carriage for Antistuds
						if(degrees_start>0 || degrees_end<360) {
							rotate([0,0,degrees_start])
	                            translate([inner_radius*BRICK_WIDTH,0,0])
	                            	rotate([0,90,0])
		                                linear_extrude(height=(outer_radius-inner_radius+((reduce<0)?reduce:0))*BRICK_WIDTH,convexity=10)
		                                    polygon([[0,0],[-BRICK_BOTTOM,0],[-BRICK_BOTTOM,WALL_THICKNESS],
		                                        [0,WALL_THICKNESS],[0,0]]);
							rotate([0,0,degrees_end])
	                            translate([inner_radius*BRICK_WIDTH,0,0])
	                            	rotate([0,90,0])
		                                linear_extrude(height=(outer_radius-inner_radius+((reduce<0)?reduce:0))*BRICK_WIDTH,convexity=10)
		                                    polygon([[0,0],[-BRICK_BOTTOM,0],[-BRICK_BOTTOM,-WALL_THICKNESS],
		                                        [0,-WALL_THICKNESS],[0,0]]);

		                }
						//	echo (bottom_difference_polygon);
						//  Add Studs on top of Brick where they belong
						//  Reduce here gets to actual rows of studs on top.

						if (flattop == 0)
							makeRoundStuds(outer_radius-reduce,inner_radius,height,1,degrees_start,degrees_end);


					}

					// Cutting the bottom circle where studs need to come through.

					makeRoundStuds(outer_radius+1,((inner_radius <1)?outer_radius-2:inner_radius-1),0,4,degrees_start,degrees_end);

				
				}

			//  Add AntiStuds   Hollow Columns inside Building Brick
			// Build the normal antistud grid, then clip its tubes to the actual
			// lower footprint.  Selecting a smaller grid alone would lose useful
			// partial tubes along the reduced edge; clipping retains those tubes
			// without allowing the full-size grid to protrude past the base.
			makeRoundAntistuds(outer_radius,inner_radius,height,degrees_start,degrees_end,
				outer_radius+min(reduce,0));
		}


		// Trim a small amount for 3D printing corner bulge ( unless 360 degree brick )

			if (degrees_end-degrees_start < 360) {
				// Studs centred near an end face extend beyond the nominal annulus.
				// Extend the end cutters radially past both faces so those small
				// overhanging fragments are removed as well.
				stud_trim_margin = STUD_RADIUS+.2;
				stud_trim_inner = inner_radius*BRICK_WIDTH
					-BRICK_WIDTH*((inner_radius==0)?0:.5)-stud_trim_margin;
				stud_trim_length = (outer_radius-inner_radius)*BRICK_WIDTH
					+BRICK_WIDTH*((inner_radius==0)?0:.5)+stud_trim_margin*2;

				rotate([0,0,degrees_start])
					translate([stud_trim_inner,-WALL_THICKNESS*9.8,-PLATE_HEIGHT])
						cube([stud_trim_length,WALL_THICKNESS*10,(height+2)*PLATE_HEIGHT+.2]);
		
				rotate([0,0,degrees_end])
					translate([stud_trim_inner,-WALL_THICKNESS*.2,-PLATE_HEIGHT])
						cube([stud_trim_length,WALL_THICKNESS*10,(height+2)*PLATE_HEIGHT]);
			}


			// Apply attribute-driven subtractions to the main block.

			if (window > 0)
				makeCathedralWindows(outer_radius,inner_radius,height,degrees_start,degrees_end,window);

			if (chamfer > 0) {
							// Chamfer Corners TODO: Make a reduce Chamfer.  
								//  TODO: Pass chamfer as depth of corner chop

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

			if (thinwall > 0) {
							//  Hollow out Brick for thinwall design
								rotate([0,0,degrees_start+5])
									rotate_extrude(angle=degrees_end-degrees_start-10,convexity=10) // Take Polygon from below and build 3d circular shape
										translate([(inner_radius)*BRICK_WIDTH,0])
											polygon(thinwall_polygon); 
							            // Add more cases as needed
			}

			if (archway > 0) {

							// Archway

							angle_base_width = sin(archway)*2;

							angle_scale = (outer_radius+1)/(inner_radius-1);

							rotate([0,0,(degrees_end-degrees_start)/2+degrees_start])
                                translate([(inner_radius-1)*BRICK_WIDTH,0])
                                    rotate([0,90,0])
                                        linear_extrude(height=(outer_radius-inner_radius+2)*BRICK_WIDTH,scale=[1.2,angle_scale])
                                            // Standard Arch
										 scale([height*.52*(15/archway),1])
                                              circle(angle_base_width/2*(inner_radius-1)*BRICK_WIDTH);

                                            // Rounded Horseshoe
                                   /*         scale([((height-1)*PLATE_HEIGHT)/(inner_radius*BRICK_WIDTH*.7),1])
                                                union () {  
                                                    translate([-PLATE_HEIGHT*3,0])
                                                        circle(.33*(inner_radius-1)*BRICK_WIDTH);
	                                               square([height*PLATE_HEIGHT*.6,angle_base_width*(inner_radius-1)*BRICK_WIDTH],center=true);

	                                      
                                                } */

/*							rotate([0,0,(degrees_end-degrees_start)/2+degrees_start])
								translate([inner_radius*BRICK_WIDTH+BRICK_WIDTH*.5,0])
								 scale([1,1.5,height*.35])
									rotate([0,90,0])
                                        cylinder(h=(outer_radius-inner_radius)*BRICK_WIDTH+BRICK_WIDTH,
                                        	r1=PLATE_HEIGHT*.96, r2=PLATE_HEIGHT*2.27, center=true);        
*/


			}

			if (link > 0)
				translate([-round(link/2)*BRICK_WIDTH+.3,inner_radius*BRICK_WIDTH+.3,-.1])
					cube([link*BRICK_WIDTH-.6,2*BRICK_WIDTH-.6,height*PLATE_HEIGHT]);

	

			// Start with the solid flare and remove the gaps between corbels.
			// Spacing, width, and phase are angles in degrees; phase locates the
			// leading edge of the first gap in the repeating pattern.
			corbel_gap = corbel_spacing-corbel_width;
			if(corbels>0 && reduce<0 && corbel_spacing>0 && corbel_gap>0) {
				first_gap = floor((degrees_start-corbel_phase-corbel_gap)/corbel_spacing);
				last_gap = ceil((degrees_end-corbel_phase)/corbel_spacing);
				for(n=[first_gap:1:last_gap]) {
					gap_start = corbel_phase+n*corbel_spacing;
					if (gap_start < degrees_end && gap_start+corbel_gap > degrees_start) {
						// Clip boundary gaps to the requested arc.  Besides preserving
						// clean end walls, this prevents misleading geometry outside a
						// partial arc in OpenSCAD's fast preview.
						clipped_gap_start = max(gap_start,degrees_start);
						clipped_gap_end = min(gap_start+corbel_gap,degrees_end);
							rotate([0,0,clipped_gap_start])
								rotate_extrude(angle=clipped_gap_end-clipped_gap_start,convexity=10)
									translate([(outer_radius+reduce)*BRICK_WIDTH,0])
										polygon(corbel_gap_polygon);
					}
				}
			}

			
			if(inner_radius != 0) {
				rotate([0,0,degrees_start-15])
					rotate_extrude(angle=degrees_end-degrees_start+30,convexity=10) // Take Polygon from below and build 3d circular shape
						translate([(inner_radius-1)*BRICK_WIDTH,-PLATE_HEIGHT,0])
							polygon(inner_difference_polygon);
			}


				rotate([0,0,degrees_start-15])
					rotate_extrude(angle=degrees_end-degrees_start+30,convexity=10) // Take Polygon from below and build 3d circular shape
						translate([(outer_radius)*BRICK_WIDTH,-PLATE_HEIGHT,0])
							polygon(inner_difference_polygon);



//		}  
		
	} 

			if (link > 0)
				translate([-round(link/2)*BRICK_WIDTH+.3,inner_radius*BRICK_WIDTH+.3,0])
					rectBrick(length=link,width=2,height=height);

			if (archway > 0) {

							// Archway
                   /*         rotate([0,0,(degrees_end-degrees_start)/2+degrees_start])
                                translate([inner_radius*BRICK_WIDTH-.2,0])
                                    rotate([0,90,0])
		                                linear_extrude(height=(outer_radius-inner_radius)*BRICK_WIDTH+BRICK_WIDTH,scale=[1,1.6])
                                            circle(cos(75)*inner_radius*BRICK_WIDTH);
                     */                   }
}



module makeCathedralWindows(outer_radius=2,inner_radius=1,height=3,degrees_start=0,degrees_end,window=1,frame=0) {

    stained_glass_window_polygon = [[-PLATE_HEIGHT,PLATE_HEIGHT*1.5],[-PLATE_HEIGHT,PLATE_HEIGHT*height*.7],
        [0,PLATE_HEIGHT*height*.85],[PLATE_HEIGHT,PLATE_HEIGHT*height*.7],
        [PLATE_HEIGHT,PLATE_HEIGHT*1.5],[0,PLATE_HEIGHT*1.5]];


//	for (i = [(degrees_start+15):30:(degrees_end-15)]) {

	// COWBOY ALERT
		rotate([0,0,(degrees_end-degrees_start)/2+degrees_start])
		    translate([inner_radius*BRICK_WIDTH-.2,0,0])
		        rotate([90,0,90])
		            linear_extrude( height=(outer_radius-inner_radius)*BRICK_WIDTH+.4,convexity = 10)
		            	polygon(stained_glass_window_polygon);
//	}
}

module makeRoundStuds(outer_radius=2,inner_radius=1,height=3,studstyle=1,degrees_start=0,degrees_end=360, reduce=0) {

	// Make Studs for Round Bricks that only place studs that are wanted 
	// 
	//  

	// Ugly test to shift the grid of top studs.
    xoff = (outer_radius-inner_radius == 0) ? 0 : .5;
    yoff = (outer_radius-inner_radius == 0) ? 0 : .5;


	for (y = [((degrees_end<=180)?-yoff:-outer_radius-yoff):outer_radius-yoff]){		
		for (x = [((degrees_end<=90)?-xoff:-outer_radius-xoff):outer_radius-xoff]){

		//	echo (x,y,(x*x+y*y),studstyle,(atan2(y,x)+360)%360,outer_radius,outer_radius*outer_radius,inner_radius,inner_radius*inner_radius);

			if( ( x*x+y*y <= ((outer_radius-((studstyle==4)?.7:1))*(outer_radius-((studstyle==4)?.7:1)))) //*4)/4) 
				&& (x*x+y*y >= ((inner_radius+((studstyle==4)?.7:-.2))*(inner_radius+((studstyle==4)?.7:-.2))))
				&& ((atan2(y,x)+360)%360) >= degrees_start - ((studstyle==4)?5:0) // ((inner_radius == 0) ? -5 : 0))
				 && ((atan2(y,x)+360)%360) <= degrees_end + ((studstyle==4)?5:0)
				) { //*4)/4)) {

//echo("HIT ---->  ",x,y,degrees_start,degrees_end,atan2(y,x)%360);

				translate ([x*BRICK_WIDTH,y*BRICK_WIDTH,height*PLATE_HEIGHT-.1])
					if (studstyle == 3) {
					// Studstyle 3 Technic style studs
						difference() {
		 					cylinder(h=STUD_HEIGHT+.1, r=STUD_RADIUS);
							// Stud inner holes
							translate([0,0,0])
								cylinder(h=STUD_HEIGHT+.3,r=PIN_RADIUS);
						} 
					} else {

						// Fully Filled Stud - Generic - And  (studstyle == 4) - Antistud
							cylinder(h=STUD_HEIGHT + ((studstyle==4) ? .3 : 0), 
								r=STUD_RADIUS + ((studstyle==4) ? .15 : 0));
				//			if (studstyle==4) { cylinder(h=PLATE_HEIGHT*0.3,r=STUD_RADIUS+.4); }
						

					}

			}
		}
	}
}

module makeRoundAntistuds(outer_radius=2,inner_radius=1,height=3,degrees_start=0,degrees_end=360,
		trim_outer_radius=outer_radius) {

//	difference() {
//		union() {

			// Perform one boolean subtraction for the complete set instead of one
			// difference per antistud. This produces the same disjoint tubes but
			// gives CGAL a much smaller CSG tree to evaluate.
			if (trim_outer_radius < outer_radius)
			intersection() {
				_roundAntistudTubes(outer_radius,inner_radius,degrees_start,degrees_end);
				// The cutter follows the reduced lower radius while leaving a small
				// vertical overlap to avoid coincident CSG faces at the base.
				translate([0,0,-.01])
					cylinder(h=BRICK_BOTTOM+.22,r=trim_outer_radius*BRICK_WIDTH);
			}
			else
				_roundAntistudTubes(outer_radius,inner_radius,degrees_start,degrees_end);



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

module _roundAntistudTubes(outer_radius,inner_radius,degrees_start,degrees_end) {
	difference() {
		union()
			_roundAntistudGrid(outer_radius,inner_radius,degrees_start,degrees_end)
				cylinder(h=BRICK_BOTTOM+.2, r=ANTI_STUD_RADIUS);
		union()
			_roundAntistudGrid(outer_radius,inner_radius,degrees_start,degrees_end)
				translate([0,0,-.2])
					cylinder(h=BRICK_BOTTOM+.3, r=ANTI_STUD_RADIUS-(WALL_THICKNESS*0.6));
	}
}

// Place children at each valid antistud location. Keeping the selection logic
// in one module also prevents the outer and inner tube passes drifting apart.
module _roundAntistudGrid(outer_radius,inner_radius,degrees_start,degrees_end) {
	for (y = [((degrees_end<=180)?0:-outer_radius):outer_radius])
		for (x = [((degrees_end<=90)?0:-outer_radius):outer_radius])
			let(angle=(atan2(y,x)+360)%360)
				if (x*x+y*y <= outer_radius*(outer_radius+.4)
					&& x*x+y*y >= inner_radius*inner_radius
					&& angle >= degrees_start-7
					&& angle < degrees_end+7)
					translate([x*BRICK_WIDTH,y*BRICK_WIDTH,0]) children();
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
