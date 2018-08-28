/***
 * LEGO® brick dimensions
 * https://commons.wikimedia.org/wiki/File:Lego_dimensions.svg
 * http://orionrobots.co.uk/pages/lego-specifications.html
 */


FLU = 1.6; 					// Fundamental Lego Unit = 1.6 mm
BRICK_WIDTH = 5*FLU;    	// basic brick width
BRICK_HEIGHT = 6*FLU;   	// basic brick height
PLATE_HEIGHT = 2*FLU;   	// basic plate height
WALL_THICKNESS = FLU;   	// outer wall of the brick
STUD_RADIUS = 1.5*FLU;  	// studs are the small cylinders on top of the brick 
							// with the lego logo ('nopje' in Dutch)
STUD_HEIGHT = FLU; 
ANTI_STUD_RADIUS = 0.5*4.07*FLU;    // an anti stud is the hollow cylinder inside 
                                    // bricks that have length > 1 and width > 1
PIN_RADIUS = FLU;           // a pin is the small cylinder inside bricks that have length = 1 or width = 1
SUPPORT_THICKNESS = 0.8;    // SUPPORT_THICKNESS: support is the thin surface between anti studs, 
                            // pins and walls, your printer might not print this thin, try thicker!
EDGE = 0.254;               // EDGE: this is the width and height of the bottom line edge of smooth bricks
CORRECTION = 0.4;           // CORRECTION: addition to each size, to make sure all parts connect by 
                            // moving them a little inside each other
