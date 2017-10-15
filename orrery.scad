/*
 * Six planet orrery with earth moon
 */
include <publicDomainGearV1.1.scad>

time = $t*360;

// gear pitch in mm
pitch = 2;

// thickness of the gear material, in mm
gear_height = 2;

// thickness of the brace and bottom plates
brace_height = 3;

// thickness of the shim washers
shim_height = 0.5;

// thickness of a gear + shim
gsh = gear_height + shim_height;

// conversion from N teeth to radius
teeth_rad = pitch / (2*PI);

// height of the top plate
top_height = 7 * gsh + brace_height;

// height of the inner planet ring
inner_height = top_height + 2 * brace_height + gsh;


// height for each of the planets
saturn_height = top_height + brace_height + shim_height;
jupiter_height = saturn_height + shim_height + 1;
mars_height = jupiter_height + shim_height + 1;
moon_height = mars_height + shim_height + 1;
earth_height = moon_height + gsh + 1;
venus_height = earth_height + 1;
mercury_height = venus_height + 1;
sun_height = mercury_height + 10;

mars_height = top_height + 2 * brace_height - 2;

// shaft diameters from mcmaster are telescoping,
// not sure how well they spin relative to each other.
// both metric (nice sizes) and imperial are available
// https://www.mcmaster.com/#standard-red-metal-hollow-tubing/=19tckjh
shafts = [
/*
	2/32 * 25.4,
	3/32 * 25.4,
	4/32 * 25.4,
	5/32 * 25.4,
	6/32 * 25.4,
	7/32 * 25.4,
	8/32 * 25.4,
	9/32 * 25.4,
*/
	2, 3, 4, 5, 6, 7, 8, 9,
];



// Create an h mm high gear with n teeth, to fit on shaft number s
module orrery_gear(n,s)
{
	render() difference()
	{
		//translate([0,0,gear_height/2]) gear(mm_per_tooth=pitch, number_of_teeth=n, hole_diameter=shafts[s], thickness=gear_height);
		cylinder(r=n*teeth_rad, h=gear_height, $fn=n);
		translate([0,0,-1]) cylinder(r=n*teeth_rad - 2, h=gear_height+2, $fn=n);
	}

	render() difference()
	{
		union()
		{
			cylinder(d=shafts[s]+2, h=gear_height, $fn=32);
			for(i=[0:2])
				rotate([0,0,i*360/3])
				translate([-2,0,0])
				cube([n*teeth_rad,gear_height,gear_height]);
		}
			
		translate([0,0,-1]) cylinder(d=shafts[s], h=gear_height+2, $fn=32);
	}
}


// create a hollow shaft
module shaft(h,s)
{
	render() difference()
	{
		cylinder(d=shafts[s],h=h, $fn=64);
		translate([0,0,-1]) cylinder(d=shafts[s]-0.52,h=h+2, $fn=64);
	}
}


// these are all on the same shaft
module inner_drive()
{
	// mars
	translate([0,0,3*gsh+brace_height]) orrery_gear(32,4);

	// skip the brace

	// earth
	translate([0,0,2*gsh]) orrery_gear(46,4);

	// venus
	translate([0,0,1*gsh]) orrery_gear(57,4);

	// mercury
	translate([0,0,0*gsh]) orrery_gear(74,4);

	translate([0,0,-shim_height]) shaft(top_height + brace_height, 4);
}


module inner_shafts()
{
	// saturn
	rotate([0,0,time*(16/60)*(36/61)*(61/30)*(15/76)+8.5])
	color("green") translate([0,0,6*gsh+brace_height]) {
		orrery_gear(76, 7);
		shaft(saturn_height-6*gsh-brace_height,7);
	}

	// jupiter
	rotate([0,0,time*(16/60)*(36/61)+7])
	color("purple") translate([0,0,5*gsh+brace_height]) {
		orrery_gear(61, 6);
		shaft(jupiter_height-5*gsh-brace_height,6);
	}


	// mars
	rotate([0,0,time*32/60+2.9])
	color("red") translate([0,0,3*gsh+brace_height]) {
		orrery_gear(60,5);
		shaft(mars_height-3*gsh-brace_height,5);
	}

	// fixed gear for the moon
	color("silver") translate([0,0,3*gsh]) shaft(moon_height-3*gsh,4);


	// earth
	rotate([0,0,time*46/46+4])
	color("blue") translate([0,0,2*gsh]) {
		orrery_gear(46,2);
		shaft(earth_height-2*gsh,3);
	}

	// venus
	rotate([0,0,time*57/35])
	color("pink") translate([0,0,1*gsh]) {
		orrery_gear(35,2);
		shaft(venus_height-1*gsh,2);
	}

	// mercury
	rotate([0,0,time*74/18+10])
	color("gray") translate([0,0,0*gsh]) {
		orrery_gear(18,1);
		shaft(mercury_height-0*gsh,1);
	}
}


module outer_drive2()
{
	// saturn
	translate([0,0,3*gsh]) orrery_gear(15,3);

	// jupiter output
	translate([0,0,2*gsh]) orrery_gear(30,3);

	// jupiter input
	translate([0,0,1*gsh]) orrery_gear(50,3);
	translate([0,0,-brace_height]) shaft(4*gsh+brace_height*2-shim_height, 4);
}


module outer_drive1()
{
	translate([0,0,1*gsh]) orrery_gear(16,3);
	translate([0,0,0*gsh]) orrery_gear(32,3);
	translate([0,0,-brace_height]) shaft(4*gsh+2*brace_height-shim_height,4);
}



module planets()
{
	rotate([0,0,time*74/18])
	color("gray") translate([shafts[1]/2,-0.5,mercury_height-1]) cube([20,1,1]);

	rotate([0,0,time*57/35])
	color("pink") translate([shafts[2]/2,-0.5,venus_height-1]) cube([30,1,1]);

	rotate([0,0,time*46/46])
	translate([shafts[3]/2,0,earth_height-1])
	{
	color("blue") translate([0,-0.5,0]) cube([146*teeth_rad+5,1,1]);

	translate([(146+11)*teeth_rad-shafts[3]/2,0,-3])
	rotate([0,0,-time*(146/11)])
	{
		orrery_gear(11,0);
		shaft(10,0);
		translate([0,0,10]) sphere(r=4);
		translate([5,0,10]) sphere(r=1);
	}
	}

	rotate([0,0,time*(32/60)])
	translate([shafts[5]/2,0,mars_height-1])
	color("red") translate([0,-0.5,0]) cube([80,1,1]);

	rotate([0,0,time*(16/60)*(36/61)])
	translate([shafts[6]/2,0,jupiter_height-1])
	color("purple") translate([0,-0.5,0]) cube([100,1,1]);

	rotate([0,0,time*(16/60)*(36/61)*(61/30)*(15/76)])
	translate([shafts[7]/2,0,saturn_height-1])
	color("green") translate([0,-0.5,0]) cube([120,1,1]);
}



translate([(74+18)*teeth_rad,0,0])
rotate([0,0,-time])
inner_drive();

inner_shafts();

// this is just to reverse the direction
// positioning it is tricky: it shouldn't impact the mars gear
color("white")
translate([(32+62)*teeth_rad,(32+32)*teeth_rad,3*gsh+brace_height])
rotate([0,0,+time*(32/32)+2])
outer_drive1();

rotate([0,0,70])
translate([(30+61)*teeth_rad,0,3*gsh+brace_height])
rotate([0,0,-time*(32/32)*(16/50)+5])
outer_drive2();

planets();

// fixed gear for the moon, on a size-4 shaft
color("silver") translate([0,0,moon_height]) orrery_gear(146, 4);

translate([0,0,-shim_height]) shaft(sun_height, 0); // sun shaft


module brace_plate()
{
render() difference()
{
	hull()
	{
		translate([0,0,0])
		cylinder(r=10,h=brace_height-shim_height);

		translate([(74+18)*teeth_rad,0,0])
		cylinder(r=10,h=brace_height-shim_height);

		rotate([0,0,70])
		translate([(30+61)*teeth_rad,0,0])
		cylinder(r=10,h=brace_height-shim_height);

		translate([(32+62)*teeth_rad,(32+32)*teeth_rad,0])
		cylinder(r=10,h=brace_height-shim_height);

		translate([38,10,0]) cylinder(r=2,h=brace_height-shim_height);
		translate([-10,25,0]) cylinder(r=2, h=brace_height-shim_height);
		translate([25,-12,0]) cylinder(r=2, h=brace_height-shim_height);
	}

	// cut shaftways for the three other than the center one
	// that holds the moon gear fixd.
	translate([(74+18)*teeth_rad,0,-1])
	cylinder(d=shafts[4]+0.25, h=brace_height+2, $fn=64);

	rotate([0,0,70])
	translate([(30+61)*teeth_rad,0,-1])
	cylinder(d=shafts[4]+0.25, h=brace_height+2, $fn=64);

	translate([(32+62)*teeth_rad,(32+32)*teeth_rad,-1])
	cylinder(d=shafts[4]+0.25, h=brace_height+2, $fn=64);

	// clear out some mass
	translate([15,10,-1])
	cylinder(d=25, h=brace_height+2);
}
}


// mid-plane brace
color("pink") translate([0,0,3*gsh]) brace_plate();

// top plate, which needs an extra hole
translate([0,0,top_height]) render() difference()
{
	brace_plate();
	translate([0,0,-1]) cylinder(d=shafts[7]+0.25, h=brace_height+2, $fn=64);
}

// cylinders to hold the plates together
translate([38,10,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height);
translate([-10,25,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height);
translate([25,-12,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height);

