/*
 * Orrery gear generator
 * and helper functions
 */

include <MCAD/involute_gears.scad> 
include <MCAD/teardrop.scad> 

// thickness of the inter-gear washers
washer = 1;

// gear pitch in mm; 2 is printable but not robust.
// 4 seems decent
pitch=4;

// gear height in mm; 5 seems solid
height=5;

// Create a mirrored flip of the children objects
// at an optional displacement
module mirrordupe(p=[0,0,0])
{
    children();
    mirror(p) children();
}

// Create a spiral of n copies of the children objects
// at an optional displacement
module fanout(n=5, p=[0,0,0])
{
	for(i=[1:n])
		rotate([0,0,i*360/n])
		translate(p)
		children();
}

// create a washer boss to reduce friction between gears
module washer(inner_diameter)
{
	translate([0,0,height-washer])
	render() difference()
	{
		cylinder(d=inner_diameter+6,h=washer, $fn=32);
		translate([0,0,-1]) cylinder(d=inner_diameter, h=washer+1, $fn=32);
	}
}

// Create a solid double-stacked herringbone gear with
// the specific number of teeth.
// twist 0 is a straight cut gear
// twist 1 is a mild herringbone
// twist 2 is more pronounced and works well
// negative twist gears mesh with positive twist gears
// large bore diameter creates a hollow inside
module herringbone(
	number_of_teeth,
	height=height,
	pitch=pitch,
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
		//twist		= twist,
		twist		= 0, // all straight
		gear_thickness	= height/2,
		rim_thickness	= height/2,
		hub_thickness	= height/2,
		bore_diameter	= bore_diameter
	);
}


// Create a gear for the orrery 
module orrery_gear(
	number_of_teeth,
	height=height,
	pitch=pitch,
	spokes=5,
	thickness=4, // thickness of the gear ring
	bore_diameter=5,
	hub_thickness=5,
	spoke_thickness=3,
	direction=1
)
{
	// generate a gear with most of the inside cut out
	render()
	translate([0,0,height/2])
	herringbone(
		number_of_teeth=number_of_teeth,
		height=height,
		pitch=pitch,
		bore_diameter=pitch*number_of_teeth/PI - thickness*2,
		twist = direction == 0 ? 0 : direction > 0 ? 2 : -2
	);

	// generate the spokes spiraling around the center
	//fanout(spokes, [bore_diameter/2,-spoke_thickness/2,0])
	fanout(spokes, [bore_diameter/2,-spoke_thickness/2 + (direction == 0 ? 0 : direction < 0 ? -spoke_thickness : +spoke_thickness),0])
		cube([
			pitch*number_of_teeth/(2*PI)-bore_diameter/2-thickness,
			spoke_thickness,
			height
		]);

	// generate the center hub
	if (spokes != 0)
	rotate([0,0,direction == 0 ? 0 : direction > 0 ? 180/spokes/2 : -180/spokes/2])
	render() difference()
	{
		cylinder(d=bore_diameter+2*hub_thickness, h=height, $fn=spokes);
		translate([0,0,-1]) cylinder(d=bore_diameter, h=height+2, $fn=32);
	}
}

// Create a hollow shaft of length l with *inner* diameter d
// and wall thickness thick.
module shaft(l,d,thick=1)
{
	render() difference()
	{
		cylinder(h=l, d=d+thick, $fn=32);
		translate([0,0,-1]) cylinder(h=l+2, d=d, $fn=32);
	}
}

// Create the shaft and cut out the top to allow it
// to connect to a coupler.
module shaft_top(l,d,thick=1)
{
	render() difference()
	{
		shaft(l,d,thick);

		// three cutout thingies
		fanout(3)
		translate([0,0,l])
		rotate([0,90,0])
		cylinder(r=4, h=d, $fn=3);
	}
}

module hollow_cylinder(d1,d2,h)
{
	render() difference() {
		cylinder(h=h, d=d1, $fn=32);

		translate([0,0,-1])
		cylinder(h=h+2, d=d2, $fn=32);
	}
}

// Create the coupler that will fasten to the top
// of a hollow shaft of inner diameter d.
module shaft_coupler(d,thick=1,clearance=0.25,spokes=3)
{
	// the three "cutouts" that are embossed on the inside
	render() intersection()
	{
		hollow_cylinder(d+thick*2, d, height);

		// need to match the cutouts of shaft_top
		mirror([0,0,1])
		fanout(spokes, [0,0,-0.5])
		rotate([0,90,0])
		cylinder(r=4, h=d, $fn=3);
	}

	// thin washer at the "top"
	//translate([0,0,height-washer*2])
	hollow_cylinder(d+thick*2, d, 0.5);

	// and the outer ring that slips over the shaft
	// with a little bit of extra clearance
	//translate([0,0,washer])
	hollow_cylinder(d+thick*4, d+thick+clearance, height);
}

module hexnut(d)
{
	cylinder(d=1.8*d, h=3.5, $fn=6);
}
