/*

Make curved battlements for 3D printing that are compatible with LEGO brands
bricks.

*/

use <RoundBrickBuilder.scad>;


// Build a complete round brick first, then remove alternating wedges from the
// upper half.  Subtracting the crenels after adding the studs means that studs
// survive only where a merlon still has material beneath it.
module roundBattlement(outer_radius=7, inner_radius=6, height=6,
		degrees_start=0, degrees_end=90, merlon_angle=12, crenel_angle=10,
		phase=0, studs=true) {
	sweep = degrees_end-degrees_start;
	period = merlon_angle+crenel_angle;
	crenel_floor = height*PLATE_HEIGHT/2;
	pattern_origin = degrees_start+phase;

	assert(outer_radius > inner_radius,
		"roundBattlement: outer_radius must be greater than inner_radius");
	assert(inner_radius >= 0,
		"roundBattlement: inner_radius must not be negative");
	assert(height > 0, "roundBattlement: height must be positive");
	assert(sweep > 0 && sweep <= 360,
		"roundBattlement: the angular sweep must be greater than 0 and at most 360 degrees");
	assert(merlon_angle > 0 && crenel_angle > 0,
		"roundBattlement: merlon_angle and crenel_angle must be positive");

	difference() {
		roundBrick(
			outer_radius=outer_radius,
			inner_radius=inner_radius,
			height=height,
			degrees_start=degrees_start,
			degrees_end=degrees_end,
			attributes=studs ? [] : [["flattop", 1]]
		);

		// Include a pattern repeat on either side of the requested arc, then
		// clip each crenel to its ends. This also handles negative phases and
		// patterns whose first or last crenel crosses an end face.
		for (repeat = [
			floor((degrees_start-pattern_origin-merlon_angle)/period)-1 :
			ceil((degrees_end-pattern_origin-merlon_angle)/period)+1
		])
			let(
				unclipped_start=pattern_origin+merlon_angle+repeat*period,
				unclipped_end=unclipped_start+crenel_angle,
				crenel_start=max(degrees_start, unclipped_start),
				crenel_end=min(degrees_end, unclipped_end)
			)
				if (crenel_end > crenel_start)
					_roundCrenelCutter(
						outer_radius, inner_radius, height,
						crenel_floor, crenel_start, crenel_end
					);
					
	}
}


// A radial wedge with a small overlap at every material boundary.  Keeping the
// cutter as a revolved radial volume produces straight, genuinely open crenels
// rather than a scalloped outer wall.
module _roundCrenelCutter(outer_radius, inner_radius, height, floor_height,
		degrees_start, degrees_end) {
	overlap = .2;
	rotate([0, 0, degrees_start])
		rotate_extrude(angle=degrees_end-degrees_start, convexity=10)
			polygon([
				[max(0, inner_radius*BRICK_WIDTH-overlap), floor_height-overlap],
				[max(0, inner_radius*BRICK_WIDTH-overlap), height*PLATE_HEIGHT+STUD_HEIGHT+overlap],
				[outer_radius*BRICK_WIDTH+overlap, height*PLATE_HEIGHT+STUD_HEIGHT+overlap],
				[outer_radius*BRICK_WIDTH+overlap, floor_height-overlap]
			]);
}
