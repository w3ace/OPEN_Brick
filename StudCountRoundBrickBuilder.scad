/*

Build one-stud-wide circular bricks from a stud count rather than a nominal
radius. Adjacent stud centres are always one 8 mm stud pitch apart.

*/

include <_conf.scad>;
include <BrickFunctions.scad>;


// Circumradius of a regular polygon whose side is one stud pitch. OpenSCAD's
// trigonometric functions use degrees.
function studCountRadius(circumference_studs, stud_pitch=BRICK_WIDTH) =
	stud_pitch/(2*sin(180/circumference_studs));


// Make an arc containing `studs` top studs out of a circle containing
// `circumference_studs` studs. The brick occupies exactly one angular pitch
// per stud and is one 8 mm stud pitch wide in the radial direction.
module studCountRoundBrick(studs=4, circumference_studs=40, height=3,
		start_angle=0, studs_on_top=true, attributes=[]) {
	angle_pitch = 360/circumference_studs;
	center_radius = studCountRadius(circumference_studs);
	inner_radius = center_radius-BRICK_WIDTH/2;
	outer_radius = center_radius+BRICK_WIDTH/2;
	brick_start = start_angle-angle_pitch/2;
	brick_sweep = studs*angle_pitch;
	full_circle = studs == circumference_studs;
	masonry = attributeValue(attributes, "masonry", 0);
	archway = attributeValue(attributes, "archway", 0);
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
	assert(archway <= 0 || studs >= 3,
		"studCountRoundBrick: archway requires at least 3 studs");
	assert(archway <= 0 || height*PLATE_HEIGHT > WALL_THICKNESS,
		"studCountRoundBrick: archway height must exceed the top-wall thickness");

	difference() {
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

				if (masonry > 0)
					_roundStudCountMasonry(
						inner_radius, outer_radius, height*PLATE_HEIGHT,
						brick_start, brick_sweep, angle_pitch, full_circle
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

		if (archway > 0)
			_roundStudCountArchway(
				inner_radius, outer_radius, height*PLATE_HEIGHT,
				brick_start+angle_pitch, brick_sweep-2*angle_pitch
			);
	}
}


// Cut a centred opening while retaining one complete stud pitch as a pier at
// each end of the brick.  The semicircular profile is compressed vertically
// when necessary so even a wide opening retains a printable top wall.
module _roundStudCountArchway(inner_radius, outer_radius, brick_height,
		angle_start, angle_sweep) {
	overlap = .1;
	segments = max(8, ceil(angle_sweep/3));
	mid_radius = (inner_radius+outer_radius)/2;
	opening_width = mid_radius*angle_sweep*PI/180;
	arch_rise = min(opening_width/2, (brick_height-WALL_THICKNESS)/2);
	spring_height = brick_height-WALL_THICKNESS-arch_rise;
	n = segments+1;
	points = concat(
		[for (r=[inner_radius-overlap, outer_radius+overlap])
			for (i=[0:segments])
				let(a=angle_start+angle_sweep*i/segments)
				[r*cos(a), r*sin(a), -overlap]],
		[for (r=[inner_radius-overlap, outer_radius+overlap])
			for (i=[0:segments])
				let(
					a=angle_start+angle_sweep*i/segments,
					u=2*i/segments-1,
					z=spring_height+arch_rise*sqrt(max(0, 1-u*u))
				)
				[r*cos(a), r*sin(a), z]]
	);
	polyhedron(points=points, faces=concat(
		[for (i=[0:segments-1]) [i, i+1, n+i+1, n+i]],
		[for (i=[0:segments-1]) [2*n+i, 3*n+i, 3*n+i+1, 2*n+i+1]],
		[for (i=[0:segments-1]) [i, 2*n+i, 2*n+i+1, i+1]],
		[for (i=[0:segments-1]) [n+i, n+i+1, 3*n+i+1, 3*n+i]],
		[[0, n, 3*n, 2*n]],
		[[segments, 2*n+segments, 3*n+segments, n+segments]]
	), convexity=10);
}


// Cut shallow mortar joints into both curved faces.  Each course is one and a
// half plates high, and alternate courses shift their upright joints by half a
// stud pitch to create a running-bond pattern.  The cuts stop short of an arc's
// ends so its structural end walls retain clean edges.
module _roundStudCountMasonry(inner_radius, outer_radius, brick_height,
		angle_start, angle_sweep, angle_pitch, full_circle=false) {
	joint_depth = min(1, WALL_THICKNESS/2);
	joint_width = .45;
	course_height = 1.5*PLATE_HEIGHT;
	course_count = ceil(brick_height/course_height);
	joint_angle = min(angle_pitch/5,
		2*asin(min(1, joint_width/(2*((inner_radius+outer_radius)/2)))));
	end_margin = full_circle ? 0 : joint_angle;

	// Bevel the top and bottom edges with half of a bed-joint profile.  Extending
	// the cutter across each body boundary gives the first and last masonry
	// courses the same raked edge as the courses between them.
	for (z = [-joint_width/2, brick_height-joint_width/2])
		_roundStudCountMasonryFaces(
			inner_radius, outer_radius, z, joint_width,
			angle_start, angle_sweep, joint_depth, false
		);

	// Horizontal bed joints between courses.
	if (course_count > 1)
		for (course = [1:course_count-1])
			if (course*course_height < brick_height)
				_roundStudCountMasonryFaces(
					inner_radius, outer_radius,
					course*course_height-joint_width/2, joint_width,
					angle_start, angle_sweep, joint_depth, false
				);

	// Upright joints, staggered on successive courses.
	for (course = [0:course_count-1]) {
		course_bottom = course*course_height;
		course_top = min((course+1)*course_height, brick_height);
		phase = (course % 2)*angle_pitch/2;
		for (joint = [-1:ceil(angle_sweep/angle_pitch)+1]) {
			joint_center = angle_start+phase+joint*angle_pitch;
			if (full_circle ||
				(joint_center-joint_angle/2 > angle_start+end_margin &&
				 joint_center+joint_angle/2 < angle_start+angle_sweep-end_margin))
				_roundStudCountMasonryFaces(
					inner_radius, outer_radius, course_bottom,
					course_top-course_bottom, joint_center-joint_angle/2,
					joint_angle, joint_depth
				);
		}
	}
}


module _roundStudCountMasonryFaces(inner_radius, outer_radius, z, height,
		angle_start, angle_sweep, depth, bevel_angular=true) {
	overlap = .08;
	bevel_angle = 45;
	_roundStudCountBeveledJoint(
		inner_radius-overlap, inner_radius+depth, z, height,
		angle_start, angle_sweep, bevel_angle, bevel_angular
	);
	_roundStudCountBeveledJoint(
		outer_radius+overlap, outer_radius-depth, z, height,
		angle_start, angle_sweep, bevel_angle, bevel_angular
	);
}


// Form a shallow frustum rather than a square-sided slot.  The opening at the
// brick face is narrowest and the cut widens toward its recessed bottom.  This
// leaves the exposed (outside) edge of each simulated stone wider than its
// inside edge.  Bed joints keep their angular ends square because those ends
// normally lie at the brick's end walls.
module _roundStudCountBeveledJoint(surface_radius, bottom_radius, z, height,
		angle_start, angle_sweep, bevel_angle=45, bevel_angular=true) {
	depth = abs(bottom_radius-surface_radius);
	inset = min(depth/tan(bevel_angle), height/2-1);
	mid_radius = (surface_radius+bottom_radius)/2;
	angle_inset = bevel_angular
		? min(angle_sweep/2-1,
			2*asin(min(1, inset/(2*mid_radius))))
		: 0;
	segments = max(1, ceil(angle_sweep/3));
	n = segments+1;
	points = concat(
		[for (i=[0:segments])
			let(a=angle_start+angle_sweep*i/segments)
			[bottom_radius*cos(a), bottom_radius*sin(a), z]],
		[for (i=[0:segments])
			let(a=angle_start+angle_sweep*i/segments)
			[bottom_radius*cos(a), bottom_radius*sin(a), z+height]],
		[for (i=[0:segments])
			let(a=angle_start+angle_inset+(angle_sweep-2*angle_inset)*i/segments)
			[surface_radius*cos(a), surface_radius*sin(a), z+inset]],
		[for (i=[0:segments])
			let(a=angle_start+angle_inset+(angle_sweep-2*angle_inset)*i/segments)
			[surface_radius*cos(a), surface_radius*sin(a), z+height-inset]]
	);
	polyhedron(points=points, faces=concat(
		[for (i=[0:segments-1]) [i, i+1, n+i+1, n+i]],
		[for (i=[0:segments-1]) [2*n+i, 3*n+i, 3*n+i+1, 2*n+i+1]],
		[for (i=[0:segments-1]) [i, 2*n+i, 2*n+i+1, i+1]],
		[for (i=[0:segments-1]) [n+i, n+i+1, 3*n+i+1, 3*n+i]],
		[[0, n, 3*n, 2*n]],
		[[segments, 2*n+segments, 3*n+segments, n+segments]]
	), convexity=10);
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
