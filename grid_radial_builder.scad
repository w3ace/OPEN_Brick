/*

Build an annular brick with a conventional Cartesian anti-stud grid underneath
and a chord-spaced radial row of studs on top.

*/

include <_conf.scad>;
include <RoundBrickBuilder.scad>;


// Radius, in millimetres, which makes neighbouring stud centres one stud pitch
// apart when circumference_studs studs are distributed around a complete ring.
function grid_radial_stud_radius(circumference_studs,
		stud_pitch=BRICK_WIDTH) =
	stud_pitch/(2*sin(180/circumference_studs));


// The body radii remain integer stud-grid dimensions so the underside can use
// roundBrick's Cartesian anti-stud grid. The outer edge is the first grid
// radius which encloses the radial stud row plus half a stud pitch; the inner
// edge is exactly two integer stud pitches inside it.
function grid_radial_outer_radius(circumference_studs) =
	ceil(grid_radial_stud_radius(circumference_studs)/BRICK_WIDTH+.5);

function grid_radial_inner_radius(circumference_studs) =
	grid_radial_outer_radius(circumference_studs)-2;


module grid_radial_builder(circumference_studs=32, degrees_start=0,
		degrees_end=360, height=3, reduce=0) {
	angle_pitch = 360/circumference_studs;
	stud_radius = grid_radial_stud_radius(circumference_studs);
	outer_radius = grid_radial_outer_radius(circumference_studs);
	inner_radius = grid_radial_inner_radius(circumference_studs);
	sweep = degrees_end-degrees_start;
	full_circle = sweep == 360;
	// A closed ring must not repeat its first stud at degrees_start + 360.
	stud_count = full_circle
		? circumference_studs
		: floor(sweep/angle_pitch)+1;

	assert(circumference_studs >= 4 &&
		circumference_studs == floor(circumference_studs),
		"grid_radial_builder: circumference_studs must be an integer of at least 4");
	assert(degrees_end > degrees_start,
		"grid_radial_builder: degrees_end must be greater than degrees_start");
	assert(sweep <= 360,
		"grid_radial_builder: the angular sweep cannot exceed 360 degrees");
	assert(height > 0, "grid_radial_builder: height must be positive");

	union() {
		// roundBrick supplies an integer-grid shell and its normal Cartesian
		// anti-studs. flattop prevents its Cartesian top-stud pass.
		roundBrick(
			outer_radius=outer_radius,
			inner_radius=inner_radius,
			reduce=reduce,
			height=height,
			degrees_start=degrees_start,
			degrees_end=degrees_end,
			attributes=[["flattop", 1]]
		);

		rotate([0,0,180/circumference_studs])
		for (i = [0:stud_count-2])
			rotate([0, 0, degrees_start+i*angle_pitch])
				translate([stud_radius, 0, height*PLATE_HEIGHT-.1])
					cylinder(h=STUD_HEIGHT+.1, r=STUD_RADIUS);

	}

}
