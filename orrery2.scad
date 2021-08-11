/*
 * Two-shaft orrery of the first six planets
 * and the moon of the third.
 */
include <gears.scad>

// The inner stack turns mercury, earth, venus and mars.
// it turns in the NEGATIVE direction, to mesh with the
// positive turning planet gears.
// The entire stack turns on a solid shaft.
module inner_stack(h=5)
{
	bore_diameter=12;
	spokes=9;

	//shaft(h*5, bore_diameter, 1);

	// mars, skipping one level and with a washer on top
	translate([0,0,4*h])
	{
		orrery_gear(32, height=h-washer, direction=-1, bore_diameter=bore_diameter, spokes=spokes);
		washer(bore_diameter);
	}

	// spokes to hold up the mars gear during printing
	translate([0,0,3*h])
	{
		fanout(spokes, [bore_diameter/2,-3/2,0])
			cube([
				pitch*32/(2*PI)-bore_diameter/2-2,
				3,
				height
			]);
		render() difference() {
			cylinder(d=bore_diameter+2*5, h=height, $fn=spokes);
			translate([0,0,-1]) cylinder(d=bore_diameter, h=height+2, $fn=32);
		}
	}


	// earth
	translate([0,0,2*h]) orrery_gear(46,height=h, direction=-1, bore_diameter=bore_diameter, spokes=spokes);

	// venus
	translate([0,0,1*h]) orrery_gear(57,height=h, direction=-1, bore_diameter=bore_diameter, spokes=spokes);

	// mercury
	translate([0,0,0*h]) orrery_gear(74,height=h, direction=-1, bore_diameter=bore_diameter, spokes=spokes);
}

// The outer planet stack turns in the NEGATIVE direction
// and is powered by the Mars takeoff (turning in the positive
// direction), and in turn drives the Jupiter and Saturn
// gears (both in positive direction).
// The outer stack turns on a solid shaft shared with the
// inner stack, so the outer planets must have the same
// total number of teeth as the inner planets.
module outer_stack(h=5)
{
	spokes = 7;
	bore_diameter = 12;
	//shaft(h*3, bore_diameter, 1);

	// saturn
	translate([0,0,2*h]) orrery_gear(19,height=h, direction=-1, bore_diameter=bore_diameter, spokes=spokes);

	// jupiter
	translate([0,0,1*h]) orrery_gear(36,height=h, direction=-1, bore_diameter=bore_diameter, spokes=spokes);

	// takeoff
	translate([0,0,0*h]) orrery_gear(74,height=h, direction=-1, bore_diameter=bore_diameter, spokes=spokes);
}

module mercury_gear(h=5)
{
	orrery_gear(18, height=h-washer, bore_diameter=5, spokes=3);
	shaft_top(h*16, 5, 1);
}

module venus_gear(h=5)
{
	orrery_gear(35, height=h, bore_diameter=6, spokes=4);
	shaft_top(h*14, 6, 1);
}

module earth_gear(h=5)
{
	// need to make room for the moon gear
	orrery_gear(46, height=h, bore_diameter=7, spokes=5);
	shaft_top(h*12, 7, 1);
}

module moon_brace(h=5)
{
	// be sure that the brace clears the earth gear
	// and hope it also clears the drive mercury gear
	render() difference()
	{
		union() {
			hull()
			fanout(3, [46*pitch/(2*PI),0,0])
			cylinder(r=10, h=h-washer);

			// washer for the mars gear to sit on
			translate([0,0,h-washer]) cylinder(d=20, h=washer);
		}

		// make sure there is an opening for the
		// other shafts
		translate([0,0,-1]) cylinder(d=9,h=h+2);

		// and the support braces
		fanout(3, [46*pitch/(2*PI)+5,0,-1])
		cylinder(d=2, h=h+2, $fn=16);
	}

	// shaft up to the moon gear
	shaft_top(h*10, 9, 1);

}

module moon_gear(h=5)
{
	// straight cut, with a finer pitch
	orrery_gear(
		146,
		height=h,
		spokes=12,
		bore_diameter=10,
		direction=0,
		pitch=4
	);

	// and a shaft-alignment thingy
	shaft_coupler(10);
}

module mars_gear(h=5)
{
	// both the mars gear and the take off
	translate([0,0,h]) orrery_gear(18, height=h, bore_diameter=12, spokes=6);
	orrery_gear(60, height=h, bore_diameter=12);
	shaft_top(h*8, 12, 1);
}

module jupiter_gear(h=5)
{
	orrery_gear(56, height=h, bore_diameter=14, spokes=7);
	shaft_top(h*5, 14, 1);
}

module saturn_gear(h=5)
{
	orrery_gear(73, height=h, bore_diameter=16, spokes=8);
	shaft_top(h*3, 16, 1);
}

height = 5;
center = pitch * (46 + 46) / (2*PI) + 0.25;


module assembly()
{
translate([0,0,5*height]) outer_stack(h=height);
color("pink") translate([0,0,0*height]) inner_stack(h=height);

translate([center,0,0]) {
	color("white") translate([0,0,0*height])
	mercury_gear(h=height);

	color("blue") translate([0,0,1*height])
	venus_gear(h=height);

	color("green") translate([0,0,2*height])
	earth_gear(h=height);

	color("silver") translate([0,0,3*height])
	moon_brace(h=height);

	color("silver") translate([0,0,12*height])
	moon_gear(h=height);

	color("red") translate([0,0,4*height])
	mars_gear(h=height);

	// skip the takeoff

	color("purple") translate([0,0,6*height])
	jupiter_gear(h=height);

	color("gold") translate([0,0,7*height])
	saturn_gear(h=height);
}
}

module plate()
{
translate([0,0,0]) color("yellow") outer_stack(h=height);
translate([100,0,0]) color("pink") inner_stack(h=height);
translate([0,70,0]) color("white") mercury_gear(h=height);
translate([50,80,0]) color("green") earth_gear(h=height);
translate([120,80,0]) color("blue") venus_gear(h=height);
translate([-30,100,0]) color("silver") moon_brace(h=height);
translate([0,200,0]) color("silver") moon_gear(h=height);
translate([200,-40,0]) color("red") mars_gear(h=height);
translate([200,+40,0]) color("purple") jupiter_gear(h=height);
translate([300,0,0]) color("gold") saturn_gear(h=height);
}


//plate();

assembly();

//shaft_coupler(6);
//moon_gear();
