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
shim_height = 0.25;

// thickness of a gear + shim
gsh = gear_height + shim_height;

// conversion from N teeth to radius
teeth_rad = pitch / (2*PI);

// height of the top plate
top_height = 7 * gsh + brace_height;

// height of the inner planet ring
inner_height = top_height + 2 * brace_height + gsh;


// height for each of the planets
saturn_height = top_height + brace_height + shim_height * 2;
jupiter_height = saturn_height + shim_height + 1;
mars_height = jupiter_height + shim_height + 1;
moon_height = mars_height + shim_height;
earth_height = moon_height + gsh + 1;
venus_height = earth_height + shim_height + 1;
mercury_height = venus_height + shim_height + 1;
sun_height = mercury_height + 10;


// shaft diameters from mcmaster are telescoping,
// not sure how well they spin relative to each other.
// both metric (nice sizes) and imperial are available
// https://www.mcmaster.com/#standard-red-metal-hollow-tubing/=19tckjh

// shapeways needs at least 0.7mm, which means the shafts must increase
// by 1.5 mm each time
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
module shaft2(h,od,id)
{
	render() difference()
	{
		cylinder(d=od, h=h, $fn=64);
		translate([0,0,-1]) cylinder(d=id,h=h+2, $fn=64);
	}
}

// create a standard hollow shaft
module shaft(h,s)
{
	shaft2(h, shafts[s], shafts[s]-0.7);
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
		// add a extra shaft on the botomto ensure that the jupiter gear
		// doesn't fall down
		translate([0,0,-gsh]) shaft(jupiter_height-4*gsh-brace_height,6);
	}


	// mars
	rotate([0,0,time*32/60+2.9])
	color("red") translate([0,0,3*gsh+brace_height]) {
		orrery_gear(60,5);
		shaft(mars_height-3*gsh-brace_height,5);
	}

	// fixed gear for the moon
	color("silver") translate([0,0,3*gsh]) shaft(moon_height-3*gsh+gear_height,4);


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
	color("gray")
	rotate([0,0,time*74/18])
	translate([0,0,mercury_height-1])
	{
		translate([shafts[1]/2-0.25,-0.5,0])
		{
			cube([20,1,1]);
			translate([20,+0.5,0])
			cylinder(d=1, h=6, $fn=32);

			translate([20,+0.5,6])
			sphere(d=2, $fn=32);
		}
		shaft2(1, shafts[2], shafts[1]);
	}

	color("pink")
	rotate([0,0,time*57/35])
	translate([0,0,venus_height-1])
	{
		translate([shafts[2]/2-0.25,-0.5,0])
		{
			cube([35,1,1]);
			translate([35,+0.5,0])
			cylinder(d=1, h=7, $fn=32);

			translate([35,+0.5,7])
			sphere(d=4, $fn=32);
		}


		shaft2(1, shafts[3], shafts[2]);
	}

	// make the earth rod along with its rotating gear
	rotate([0,0,time*46/46])
	translate([0,0,earth_height-1])
	{
		color("blue") {
		// the rod and circle at the end of it
		translate([shafts[3]/2-0.25,-1,0])
		cube([(146+11)*teeth_rad-shafts[3]/2-shafts[0]/2-0.25,2,1]);

		shaft2(1, shafts[4], shafts[3]);

		translate([(146+11)*teeth_rad,0,0])
		render() difference()
		{
			cylinder(h=1, d=4, $fn=64);
			cylinder(h=1, d=shafts[0]+0.25, $fn=64);
		}
		}

		// the gear and the shaft for the moon/earth combo
		translate([(146+11)*teeth_rad,0,-gear_height-shim_height])
		{
			rotate([0,0,-time*(146/11)])
			{
				orrery_gear(11,0);
				shaft(10,0);
				translate([0,0,10]) sphere(r=4, $fn=32);
				translate([0,3,10]) cube([1,6,1], center=true);
				translate([0,6,10]) sphere(r=1, $fn=32);

				// add a small keeper to prevent it from slipping
				translate([0,0,gsh + 1.1]) cylinder(r=2, h=shim_height);
				//translate([5,0,10]) sphere(r=1);
			}
		}
	}

	color("red")
	rotate([0,0,time*(32/60)])
	translate([0,0,mars_height-1])
	{
		translate([shafts[5]/2-0.25,0,0])
		{
			translate([0,-1,0]) cube([62,2,1]);
			translate([62,0,0]) cylinder(d1=2, d2=1, h=10, $fn=32);
			translate([62,0,10]) sphere(r=3, $fn=32);
		}
		shaft2(1, shafts[7], shafts[5]);
	}

	color("purple")
	rotate([0,0,time*(16/60)*(36/61)])
	translate([0,0,jupiter_height-1])
	{
		translate([shafts[6]/2-0.25,0,0])
		{
			translate([0,-1,0]) cube([80,2,1]);
			translate([80,0,0]) cylinder(d1=2, d2=1, h=11+8, $fn=32);

			// make a hollow sphere
			translate([80,0,11]) render() difference() {
				sphere(r=8, $fn=32);
				sphere(r=7.2, $fn=32);
				rotate([-140,0,0]) cylinder(r=1, h=10, $fn=32);
			}
		}
			
		shaft2(1,shafts[7], shafts[6]);
	}

	color("green")
	rotate([0,0,time*(16/60)*(36/61)*(61/30)*(15/76)])
	translate([0,0,saturn_height-1])
	{
		translate([shafts[7]/2-0.25,0,0])
		{
			translate([0,-1,0]) cube([100,2,1]);
			translate([100,0,0]) cylinder(d1=2, d2=1, h=12+6, $fn=32);
			translate([100,0,12]) {
				render() difference() {
					sphere(r=6,$fn=32);
					sphere(r=5.2,$fn=32);
					rotate([-140,0,0]) cylinder(r=1, h=10, $fn=32);
				}
				rotate([30,0,0]) {
					translate([0,0,-0.5]) render() difference() {
						cylinder(r=9,h=1);
						cylinder(r=7,h=1);
					}
					cube([18,1,1], center=true);
					cube([1,18,1], center=true);
				}
			}
		}

		shaft(1,7);
	}
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

// sun shaft
translate([0,0,-1]) {
	shaft(sun_height-8, 0);

	shaft2(1 - shim_height, shafts[4], shaft[0]);
	translate([0,0,venus_height+2+2*shim_height])
	shaft2(1 - shim_height, shafts[1], shaft[0]);
	translate([0,0,sun_height-0.8]) render() difference() {
		sphere(r=8, $fn=64);
		sphere(r=7.2, $fn=32);
		rotate([-140,0,0]) cylinder(r=1, h=10, $fn=16);
	}
		
}


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
	cylinder(d=shafts[4]+0.5, h=brace_height+2, $fn=64);

	rotate([0,0,70])
	translate([(30+61)*teeth_rad,0,-1])
	cylinder(d=shafts[4]+0.5, h=brace_height+2, $fn=64);

	translate([(32+62)*teeth_rad,(32+32)*teeth_rad,-1])
	cylinder(d=shafts[4]+0.5, h=brace_height+2, $fn=64);

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
	translate([0,0,-1]) cylinder(d=shafts[7]+0.5, h=brace_height+2, $fn=64);
}

// cylinders to hold the plates together
translate([38,10,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height);
translate([-10,25,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height);
translate([25,-12,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height);

