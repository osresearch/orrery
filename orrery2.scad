/*
 * Two-shaft orrery of the first six planets
 * and the moon of the third.
 *
 * 
 */

include <MCAD/involute_gears.scad> 
include <MCAD/teardrop.scad> 

// thickness of the inter-gear washers
washer = 0.5;

module mirrordupe(p)
{
    children();
    mirror(p) children();
}

module fanout(n=5, p=[0,0,0])
{
	for(i=[1:n])
		rotate([0,0,90+i*360/n])
		translate(p)
		children();
}

// create a washer boss to reduce friction between gears
module washer(inner_diameter)
{
	translate([0,0,5-washer])
	render() difference()
	{
		cylinder(d=inner_diameter+4,h=washer, $fn=32);
		translate([0,0,-1]) cylinder(d=inner_diameter, h=washer+1, $fn=32);
	}
}

module herringbone(
	number_of_teeth,
	height=5,
	pitch=4,
	twist=1,
	bore_diameter=5
) {
	// circumference = pitch * number of teeth
	// radius = circumference / (2*PI)
	// circular_pitch = radius * 360 / number_of_teeth
	//    = (pitch * 360) / (2*PI)

	mirrordupe([0,0,height])
	gear(
		number_of_teeth	= number_of_teeth,
		circular_pitch	= (pitch * 360) / (2*PI),
		twist		= twist,
		gear_thickness	= height/2,
		rim_thickness	= height/2,
		hub_thickness	= height/2,
		bore_diameter	= bore_diameter
	);
}


module orrery_gear(
	number_of_teeth,
	height=5,
	pitch=4,
	spokes=5,
	thickness=3,
	bore_diameter=5,
	hub_thickness=5,
	spoke_thickness=3,
	direction=1
)
{
	// generate a gear with most of the inside cut out
	translate([0,0,height/2])
	herringbone(
		number_of_teeth=number_of_teeth,
		height=height,
		pitch=pitch,
		bore_diameter=pitch*number_of_teeth/PI - thickness*2,
		twist = direction == 0 ? 0 : direction > 0 ? 2 : -2
	);

	// generate the spokes spiraling around the center
	fanout(spokes, [bore_diameter/2,-spoke_thickness/2,0])
		cube([
			pitch*number_of_teeth/(2*PI)-bore_diameter/2-thickness,
			spoke_thickness,
			height
		]);

	// generate the center hub
	render() difference()
	{
		cylinder(d=bore_diameter+hub_thickness, h=height, $fn=32);
		translate([0,0,-1]) cylinder(d=bore_diameter, h=height+2, $fn=32);
	}
}

module shaft(l,d,thick=1)
{
	render() difference()
	{
		cylinder(h=l, d=d, $fn=32);
		translate([0,0,-1]) cylinder(h=l+2, d=d-thick, $fn=32);
	}
}

pitch=4;


module inner_stack(h=5)
{
	shaft(h*5, 5, 1);

	// mars, skipping one level
	translate([0,0,4*h]) orrery_gear(32, height=h, direction=-1);

	// earth
	translate([0,0,2*h]) orrery_gear(46,height=h, direction=-1);

	// venus
	translate([0,0,1*h]) orrery_gear(57,height=h, direction=-1);

	// mercury
	translate([0,0,0*h]) orrery_gear(74,height=h, direction=-1);
}

module outer_stack(h=5)
{
	shaft(h*3, 5, 1);

	// saturn
	translate([0,0,2*h]) orrery_gear(19,height=h, direction=-1);

	// jupiter
	translate([0,0,1*h]) orrery_gear(36,height=h, direction=-1);

	// takeoff
	translate([0,0,0*h]) orrery_gear(74,height=h, direction=-1);
}

module mercury_gear(h=5)
{
	orrery_gear(18, height=h-washer, bore_diameter=4);
	shaft(h*16, 4, 1);
}

module venus_gear(h=5)
{
	orrery_gear(35, height=h, bore_diameter=6);
	shaft(h*14, 6, 1);
}

module earth_gear(h=5)
{
	// need to make room for the moon gear
	orrery_gear(46, height=h, bore_diameter=8);
	translate([0,0,h]) shaft(h*11, 8, 1);
}

module moon_brace(h=5)
{
	render() difference()
	{
		union() {
			hull()
			fanout(3, [0,-30,0])
			cylinder(r=10, h=h-washer);

			// washer for the mars gear to sit on
			translate([0,0,h-washer]) cylinder(d=20, h=washer);
		}

		// make sure there is an opening for the
		// other shafts
		translate([0,0,-1]) cylinder(d=10-1,h=h+2);
	}

	// shaft up to the moon gear
	shaft(h*10, 10, 1);

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
		pitch=3
	);
}

module mars_gear(h=5)
{
	// both the mars gear and the take off
	translate([0,0,h]) orrery_gear(18, height=h, bore_diameter=12);
	orrery_gear(60, height=h, bore_diameter=12);
	translate([0,0,h]) shaft(h*7, 12, 1);
}

module jupiter_gear(h=5)
{
	orrery_gear(56, height=h, bore_diameter=14);
	translate([0,0,h]) shaft(h*4, 14, 1);
}

module saturn_gear(h=5)
{
	orrery_gear(73, height=h, bore_diameter=16);
	translate([0,0,h]) shaft(h*2, 16, 1);
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
translate([0,80,0]) color("white") mercury_gear(h=height);
translate([50,80,0]) color("green") earth_gear(h=height);
translate([120,80,0]) color("blue") venus_gear(h=height);
translate([-30,100,0]) color("silver") moon_gear(h=height);
translate([200,-40,0]) color("red") mars_gear(h=height);
translate([200,+40,0]) color("purple") jupiter_gear(h=height);
translate([300,0,0]) color("gold") saturn_gear(h=height);
}

//plate();

//assembly();

module test()
{
	teeth1=18;
	teeth2=30;
	dist=(teeth1+teeth2)*pitch / (2*PI) + 0.5;

	color("red") {
		orrery_gear(teeth1, height=5-washer, bore_diameter=4, direction=+1);
		shaft(25, 4, 1);
		washer(4);
	}

	//translate([0,0,5])
	translate([-30,20,0])
	color("blue") {
		orrery_gear(teeth2, height=5-washer, bore_diameter=6, direction=+1);
		shaft(15, 6, 1);
		washer(6);
	}

	//translate([dist,0,0])
	translate([35,0,0])
	{
		orrery_gear(teeth2, 5, pitch=pitch, direction=-1, bore_diameter=6);
		translate([0,0,5])
		orrery_gear(teeth1, 5-washer, pitch=pitch, direction=-1, bore_diameter=6);
		translate([0,0,5]) washer(6);
	}
	
	translate([0,40,0])
	{
		hull() {
			cylinder(d=20, h=5-washer);
			translate([dist,0,0]) cylinder(d=20, h=5-washer);
		}

		shaft(20,2);
		washer(2);

		translate([dist,0,0]) {
			shaft(20,4);
			washer(4);
		}
	}

	translate([0,65,0])
	render() difference() {
		hull() {
			cylinder(d=20, h=5);
			translate([dist,0,0]) cylinder(d=20, h=5);
		}

		translate([0,0,-1]) cylinder(d=2+0.5, h=5+2, $fn=32);
		translate([dist,0,-1]) cylinder(d=4+0.5, h=5+2, $fn=32);
	}
}

test();
