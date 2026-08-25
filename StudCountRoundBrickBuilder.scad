/*

Build one-stud-wide circular bricks from a stud count rather than a nominal
radius. Adjacent stud centres are always one 8 mm stud pitch apart.

*/

include <_conf.scad>;


// Circumradius of a regular polygon whose side is one stud pitch. OpenSCAD's
// trigonometric functions use degrees.
function studCountRadius(circumference_studs, stud_pitch=BRICK_WIDTH) =
	stud_pitch/(2*sin(180/circumference_studs));


// Make an arc containing `studs` top studs out of a circle containing
// `circumference_studs` studs. The brick occupies exactly one angular pitch
// per stud and is one 8 mm stud pitch wide in the radial direction.
module studCountRoundBrick(studs=4, circumference_studs=40, height=3,
		start_angle=0, studs_on_top=true) {
	angle_pitch = 360/circumference_studs;
	center_radius = studCountRadius(circumference_studs);
	inner_radius = center_radius-BRICK_WIDTH/2;
	outer_radius = center_radius+BRICK_WIDTH/2;
	brick_start = start_angle-angle_pitch/2;
	brick_sweep = studs*angle_pitch;
	full_circle = studs == circumference_studs;
	// Convert the desired end-wall thickness to an angle at the stud centres.
	end_wall_angle = full_circle ? 0 : min(angle_pitch/3,
		asin(min(1, WALL_THICKNESS/(2*center_radius)))*2);

	assert(circumference_studs >= 4 && circumference_studs == floor(circumference_studs),
		"studCountRoundBrick: circumference_studs must be an integer of at least 4");
	assert(studs >= 1 && studs == floor(studs),
		"studCountRoundBrick: studs must be a positive integer");
	assert(studs <= circumference_studs,
		"studCountRoundBrick: studs cannot exceed circumference_studs");
	assert(height > 0, "studCountRoundBrick: height must be positive");

	union() {
		// A hollow, open-bottom shell with radial walls and, for an arc, solid
		// end walls. The top is left thick enough to support the studs.
		difference() {
			_roundStudCountWedge(
				inner_radius, outer_radius, height*PLATE_HEIGHT,
				brick_start, brick_sweep
			);
			_roundStudCountWedge(
				inner_radius+WALL_THICKNESS,
				outer_radius-WALL_THICKNESS,
				height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION,
				brick_start+end_wall_angle,
				brick_sweep-2*end_wall_angle,
				z=-CORRECTION
			);
		}

		if (studs_on_top)
			for (i = [0:studs-1])
				rotate([0, 0, start_angle+i*angle_pitch])
					translate([center_radius, 0, height*PLATE_HEIGHT-CORRECTION])
						cylinder(h=STUD_HEIGHT+CORRECTION, r=STUD_RADIUS);

		// As on a conventional one-stud-wide brick, clutch pins sit between
		// neighbouring studs. A complete ring also gets the closing pin.
		pin_count = full_circle ? studs : studs-1;
		if (pin_count > 0)
			for (i = [0:pin_count-1])
				rotate([0, 0, start_angle+(i+.5)*angle_pitch])
					translate([center_radius, 0, 0])
						cylinder(
							h=height*PLATE_HEIGHT-WALL_THICKNESS+CORRECTION,
							r=PIN_RADIUS
						);
	}
}


module _roundStudCountWedge(inner_radius, outer_radius, wedge_height,
		angle_start, angle_sweep, z=0) {
	rotate([0, 0, angle_start])
		rotate_extrude(angle=angle_sweep, convexity=10)
			translate([0, z])
				polygon([
					[inner_radius, 0],
					[inner_radius, wedge_height],
					[outer_radius, wedge_height],
					[outer_radius, 0]
				]);
}
