/*
 * Two-shaft orrery of the first six planets
 * and the moon of the third.
 */
include <gears.scad>

// 1mm shaft walls turned out to be too thin
shaft_wall = 2;
shaft_sizes = [
	5 + 2.75*0, // 0 mercury
	5 + 2.75*1, // 1 venus
	5 + 2.75*2, // 2 earth
	5 + 2.75*3, // 3 moon (extra thick)
	5 + 2.75*5, // 4 mars
	5 + 2.75*7, // 5 jupiter
	5 + 2.75*9, // 6 saturn
	5 + 2.75*11, // 7 top plate
];

// The inner stack turns mercury, earth, venus and mars.
// it turns in the NEGATIVE direction, to mesh with the
// positive turning planet gears.
// The entire stack turns on a solid 5mm shaft and
// has a real washer at the top.
module inner_stack(h=5)
{
	bore_diameter=5;
	spokes=9;

	//shaft(h*5, bore_diameter, 1);

	// mars, double height with a washer on top
	translate([0,0,3*h])
		orrery_gear(32, height=2*h-washer, direction=-1, bore_diameter=bore_diameter, spokes=spokes);

/*
	// spokes to hold up the mars gear during printing
	translate([0,0,3*h])
	{
		fanout(spokes, [bore_diameter/2,-3/2 - 3,0])
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
*/


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
	bore_diameter = 5;
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
	bore = shaft_sizes[0];
	orrery_gear(18, height=h, bore_diameter=bore, spokes=3);
	shaft_top(h*16, bore, shaft_wall);
}

module venus_gear(h=5)
{
	bore = shaft_sizes[1];
	orrery_gear(35, height=h, bore_diameter=bore, spokes=4);
	shaft_top(h*14, bore, shaft_wall);
}

module earth_gear(h=5)
{
	// need to make room for the moon gear
	bore = shaft_sizes[2];
	orrery_gear(46, height=h, bore_diameter=bore, spokes=5);
	shaft_top(h*12, bore, shaft_wall);
}

module moon_brace(h=5)
{
	bore = shaft_sizes[3];

	// be sure that the brace clears the earth gear
	// and hope it also clears the drive mercury gear
	render() difference()
	{
		union() {
			braceplate(h-washer, 0);

			// washer for the mars gear to sit on
			translate([0,0,h-washer]) cylinder(d=20, h=washer);
		}

		// make sure there is an opening for the
		// other shafts
		translate([0,0,-1]) cylinder(d=bore,h=h+2);

		// as well as clearance for the earth gear
		translate([-center,0,-1]) cylinder(d=48*pitch/PI, h=h+2, $fn=32);
	}

	// shaft up to the moon gear
	shaft_top(h*10, bore, 2*shaft_wall);

}

module moon_gear(h=5)
{
	// straight cut, with a finer pitch
	bore = shaft_sizes[3];
	orrery_gear(
		146,
		height=h,
		spokes=12,
		bore_diameter=bore,
		direction=0,
		pitch=3.5
	);

	// and a shaft-alignment thingy
	shaft_coupler(bore);
}

module mars_gear(h=5)
{
	// both the mars gear and the take off
	bore = shaft_sizes[4];

	// takeoff gear is solid due to sizing
	translate([0,0,h])
	render() difference()
	{
		orrery_gear(18, height=h, bore_diameter=bore, spokes=0, hubthickness=0);
		translate([0,0,-1]) cylinder(d=bore, h=h+2, $fn=32);
	}

	// main mars gear
	orrery_gear(60, height=h, bore_diameter=bore);

	// skip the takeoff gear
	translate([0,0,h*2])
	shaft_top(h*(8-2), bore, 2*shaft_wall);
}

module jupiter_gear(h=5)
{
	bore = shaft_sizes[5];
	orrery_gear(56, height=h, bore_diameter=bore, spokes=7);
	shaft_top(h*5, bore, 2*shaft_wall);
}

module saturn_gear(h=5)
{
	bore = shaft_sizes[6];
	orrery_gear(73, height=h, bore_diameter=bore, spokes=8);
	shaft_top(h*3, bore, 2*shaft_wall);
}

height = 5;
center = pitch * (46 + 46) / (2*PI) + 0.25;

module braceplate(h=height, do_mainshaft=1, do_hexes=0)
{
	// be sure that the brace clears the saturn gear
	teeth = 73;

	// and hope it also clears the drive mercury gear
	render() difference()
	{
		hull() {
			fanout(3, [teeth*pitch/(2*PI),0,0])
			cylinder(r=14, h=h);

			if (do_mainshaft)
			translate([-center,0,0])
			cylinder(r=10, h=h);
		}

		// and the support braces with hexes
		fanout(3, [teeth*pitch/(2*PI)+5,0,-1])
		{
			cylinder(d=shaft_sizes[0], h=h+2, $fn=16);
			translate([0,0,h-2]) {
				if (do_hexes)
					hexnut(5);
				else
					cylinder(d=12, h=h+2);
			}
		}

/*
		// some fancy holes
		fanout(3, [teeth*pitch/(2*PI)*.66,0,-1])
		cylinder(d=25, h=h+2, $fn=7);
*/
		fanout(9, [teeth*pitch/(2*PI)*.5,0,-1])
		cylinder(d=10, h=h+2, $fn=16);

		if (do_mainshaft)
		translate([-center,0,-1])
		cylinder(d=shaft_sizes[0], h=h+2, $fn=32);
	}
}


module baseplate(h=height)
{
	translate([0,0,h])
	mirrordupe([0,0,1])
	render() difference()
	{
		braceplate(h);
		translate([0,0,-1]) cylinder(d=shaft_sizes[0],h=h+2, $fn=32);

		//translate([-center*.66,0,-1]) cylinder(d=30, h=h+2, $fn=9);

		// mainshaft hex nut keeper
		translate([-center,0,h-3]) hexnut(5);
		translate([0,0,h-3]) hexnut(5);

		// and a big cutout
		translate([-center*0.7,0,-1])
		cylinder(d=20,h=h+2);
	}
}

module topplate(h=height)
{
	render() difference()
	{
		braceplate(h);

		// clear the saturn shaft
		translate([0,0,-1])
		cylinder(d=shaft_sizes[7], h=h+2, $fn=32);
	}
		
}


module assembly()
{
translate([-center,0,5*height]) outer_stack(h=height);
color("pink") translate([-center,0,0*height]) inner_stack(h=height);

	color("gold") translate([0,0,0*height])
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

	color("white") translate([0,0,7*height])
	saturn_gear(h=height);

	translate([0,0,-2*height]) baseplate();
	translate([0,0,8*height]) topplate();
}

module plate()
{
translate([0,0,0]) color("yellow") outer_stack(h=height);
translate([100,0,0]) color("pink") inner_stack(h=height);
translate([0,70,0]) color("gold") mercury_gear(h=height);
translate([50,80,0]) color("green") earth_gear(h=height);
translate([120,80,0]) color("blue") venus_gear(h=height);
translate([-30,120,0]) color("silver") moon_brace(h=height);
translate([50,220,0]) color("silver") moon_gear(h=height);
translate([200,-40,0]) color("red") mars_gear(h=height);
translate([200,+40,0]) color("purple") jupiter_gear(h=height);
translate([300,0,0]) color("white") saturn_gear(h=height);
translate([280,100,0]) color("white") baseplate(h=height);
translate([190,170,0]) color("white") topplate(h=height);
}


mode = 0;

if (mode==0) assembly(); else
if (mode==1) plate();

