/*
 * Six planet orrery with earth moon
 */
include <publicDomainGearV1.1.scad>

time = $t*720;

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

// how much space should we leave between the gear teeth
// this helps with printability
gear_slop = 0.2;

// conversion from N teeth to radius
teeth_rad = pitch / (2*PI);

// height of the top plate
top_height = 7 * gsh + brace_height;

// height of the inner planet ring
inner_height = top_height + 2 * brace_height + gsh;


// height for each of the planets
saturn_height = top_height + brace_height + shim_height + 1;
jupiter_height = saturn_height + shim_height + 1;
mars_height = jupiter_height + shim_height + 1;
moon_height = mars_height + shim_height * 2;
earth_height = moon_height + gsh + 1;
venus_height = earth_height + shim_height + 1;
mercury_height = venus_height + shim_height + 1;
sun_height = mercury_height + 10;


// compute the mesh position for a third gear given the
// xy coordinates of the first two gears and their various lengths
// this uses the law of cosines to get the angle between the two
// fixed gears
function gear_coord(g0, g1, t0, t1) =
	let(a = pitch_radius(pitch, t0) + gear_slop)
	let(b = pitch_radius(pitch, t1) + gear_slop)
	let(dx = g1[0] - g0[0])
	let(dy = g1[1] - g0[1])
	let(c = sqrt(dx*dx+dy*dy))
	let(angle1 = acos((a*a + c*c - b*b) / (2*a*c)))
	let(angle2 = atan2(dy, dx))
	[
		g0[0] + a * cos(angle1+angle2),
		g0[1] + a * sin(angle1+angle2),
		0,
	];

// positions of the shafts -- very important for proper mesh!
// this is dependent on the number of teeth in the gears.
// the gear teeth are aligned on the y axis, so we have a rotation
// parameter to compute how much we must rotate to bring the next tooth into line
inner_pos = [0,0,0];
drive_pos = [pitch_radius(pitch,46)*2 + gear_slop,0];
outer_drive1_pos = [pitch_radius(pitch,46)*2 + gear_slop, pitch_radius(pitch,32)*2 + gear_slop];
outer_drive2_pos = gear_coord(inner_pos, outer_drive1_pos, 15+76, 50+16);


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
module orrery_gear(n,s,spokes=3)
{
	render() difference()
	{
		translate([0,0,gear_height/2]) gear(mm_per_tooth=pitch, number_of_teeth=n, hole_diameter=shafts[s], thickness=gear_height);
		//cylinder(r=n*teeth_rad, h=gear_height, $fn=n);
		translate([0,0,-1]) cylinder(r=n*teeth_rad - 2, h=gear_height+2, $fn=n);
	}

	render() difference()
	{
		union()
		{
			cylinder(d=shafts[s]+2, h=gear_height, $fn=32);
			for(i=[1:spokes])
				rotate([0,0,90+i*360/spokes])
				translate([-2,-gear_height/2,0])
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
// rotate so that they have a gap on the +X to line up with
// the input drive mechanism
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

	// make a fairly thick shaft that goes all the way through
	// to the top brace
	translate([0,0,-shim_height])
	shaft2(top_height + brace_height, shafts[4], shafts[2]);
}


// these are all on co-centric shafts, 8 in total.
// the gears are rotated to align with the input drive gear
// the outer planets are hand aligned
module inner_shafts()
{
	// saturn
	rotate([0,0,time*(16/50)*(15/76)])
	rotate([0,0,3.8])
	color("green") translate([0,0,6*gsh+brace_height]) {
		orrery_gear(76, 7);
		shaft(saturn_height-6*gsh-brace_height,7);
	}

	// jupiter
	rotate([0,0,time*(16/50)*(36/61)])
	rotate([0,0,5.0])
	color("purple") translate([0,0,5*gsh+brace_height]) {
		orrery_gear(61, 6);
		// add a extra shaft on the botomto ensure that the jupiter gear
		// doesn't fall down
		translate([0,0,-gsh]) shaft(jupiter_height-4*gsh-brace_height,6);
	}


	// mars
	rotate([0,0,time*32/60])
	rotate([0,0,-90+360/60/2])
	color("red") translate([0,0,3*gsh+brace_height]) {
		orrery_gear(60,5);
		shaft(mars_height-3*gsh-brace_height,5);
	}

	// fixed gear for the moon
	color("silver")
	translate([0,0,3*gsh])
	shaft(moon_height-3*gsh+gear_height,4);


	// earth
	rotate([0,0,time*46/46])
	rotate([0,0,-90+360/46/2])
	color("blue") translate([0,0,2*gsh]) {
		orrery_gear(46,2);
		shaft(earth_height-2*gsh,3);
	}

	// venus
	rotate([0,0,time*57/35])
	rotate([0,0,-90+360/35/2])
	color("pink") translate([0,0,1*gsh]) {
		orrery_gear(35,2);
		shaft(venus_height-1*gsh,2);
	}

	// mercury
	rotate([0,0,time*74/18])
	rotate([0,0,-90+360/18/2])
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

	translate([0,0,-brace_height])
	shaft2(4*gsh+brace_height*2-shim_height, shafts[4], shafts[2]);

	// a kepper to hold it in place
	translate([0,0,0*shim_height])
	shaft2(shim_height, shafts[5], shafts[2]);
}


// This reverses the main drive and provides gear reduction
// for the outer planet drive wheels.
module outer_drive1()
{
	// leave this one non-rotated for easier math
	translate([0,0,1*gsh]) orrery_gear(16,3);

	// rotate to line up with the main drive wheel
	rotate([0,0,180+360/32/2])
	translate([0,0,0*gsh]) orrery_gear(32,3);


	translate([0,0,-brace_height])
	shaft2(4*gsh+2*brace_height-shim_height, shafts[4], shafts[2]);

	// a keeper to hold it in place
	translate([0,0,4*gsh-shim_height*2])
	shaft2(shim_height, shafts[5], shafts[2]);
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

		translate([pitch_radius(pitch,146+11)+gear_slop,0,0])
		render() difference()
		{
			cylinder(h=1, d=4, $fn=64);
			cylinder(h=1, d=shafts[0]+0.5, $fn=64);
		}
		}

		// the gear and the shaft for the moon/earth combo
		translate([pitch_radius(pitch,146+11)+gear_slop,0,-gear_height-shim_height])
		{
			rotate([0,0,-time*(146/11)])
			{
				// line up with the fixed moon gear
				rotate([0,0,+90+360/11/2])
				orrery_gear(11,0);

				shaft(10,0);
				translate([0,0,10]) sphere(r=4, $fn=32);
				translate([0,3,10]) cube([1,6,1], center=true);
				translate([0,6,10]) sphere(r=1, $fn=32);

				// add a small keeper to prevent it from slipping
				translate([0,0,gsh + 1 + shim_height]) cylinder(r=2, h=shim_height, $fn=32);
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


module brace_plate()
{
render() difference()
{
	hull()
	{
		translate([0,0,0])
		cylinder(r=6,h=brace_height-shim_height);

		translate([drive_pos[0], drive_pos[1],0])
		cylinder(r=6,h=brace_height-shim_height);

		translate([outer_drive2_pos[0], outer_drive2_pos[1], 0])
		cylinder(r=6,h=brace_height-shim_height);

		translate([outer_drive1_pos[0], outer_drive1_pos[1], 0])
		cylinder(r=6,h=brace_height-shim_height);

		translate([39,11,0]) cylinder(r=2,h=brace_height-shim_height);
		translate([-10,26,0]) cylinder(r=2, h=brace_height-shim_height);
		translate([25,-13,0]) cylinder(r=2, h=brace_height-shim_height);
	}

	// cut shaftways for the three other than the center one
	// that holds the moon gear fixd.
	translate([drive_pos[0], drive_pos[1], -1])
	cylinder(d=shafts[4]+0.6, h=brace_height+2, $fn=64);

	translate([outer_drive2_pos[0], outer_drive2_pos[1], -1])
	cylinder(d=shafts[4]+0.6, h=brace_height+2, $fn=64);

	translate([outer_drive1_pos[0], outer_drive1_pos[1], -1])
	cylinder(d=shafts[4]+0.6, h=brace_height+2, $fn=64);

	// clear out some mass
	translate([15,10,-1])
	cylinder(d=25, h=brace_height+2);
}
}


module orrery()
{
color("deepskyblue")
translate([drive_pos[0], drive_pos[1]])
rotate([0,0,-time])
rotate([0,0,90]) // position each gear with a tooth facing -X
inner_drive();

inner_shafts();

// this is just to reverse the direction
// positioning it is tricky: it shouldn't impact the mars gear
color("white")
translate([outer_drive1_pos[0], outer_drive1_pos[1], 3*gsh+brace_height])
rotate([0,0,+time*(32/32)])
outer_drive1();

// the rotation angle is a hand-aligned hack
color("orange")
//translate([(30+61)*teeth_rad,0,3*gsh+brace_height])
translate([outer_drive2_pos[0], outer_drive2_pos[1], 3*gsh+brace_height])
rotate([0,0,-time*(32/32)*(16/50)+5])
rotate([0,0,5.5])
outer_drive2();

planets();

// fixed gear for the moon, on a size-4 shaft
// rotate to put a fixed tooth on the positive X axis
color("silver")
translate([0,0,moon_height])
rotate([0,0,-90])
orrery_gear(146, 4);

// sun shaft and globe
translate([0,0,-1]) {
	shaft(sun_height-8, 0);

	shaft2(1 - shim_height, shafts[4], shaft[0]);
	translate([0,0,venus_height+2+2*shim_height])
	shaft2(1 - shim_height, shafts[1], shaft[0]);
	translate([0,0,sun_height-0.8]) render() difference() {
		sphere(r=8, $fn=32);
		sphere(r=7.2, $fn=32);
		rotate([-140,0,0]) cylinder(r=1, h=10, $fn=16);
	}
		
}



// mid-plane brace
translate([0,0,3*gsh]) brace_plate();

// top plate, which needs an extra hole
translate([0,0,top_height]) render() difference()
{
	brace_plate();
	translate([0,0,-1]) cylinder(d=shafts[7]+0.6, h=brace_height+2, $fn=64);
}

// cylinders to hold the plates together
// hand aligned to clear the gears
translate([39,11,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height, $fn=32);
translate([-10,26,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height, $fn=32);
translate([25,-13,3*gsh]) cylinder(r=2, h=4*gsh+2*brace_height-shim_height, $fn=32);

}


//rotate([0,0,-time*46/46])
orrery();
