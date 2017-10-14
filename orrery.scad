/*
 * Six planet orrery with earth moon
 */

time = $t*360;

// gear pitch in mm
pitch = 2;

// thickness of the gear material, in mm
gear_height = 3;

// thickness of the brace and bottom plates
brace_height = 3;

// thickness of the shim washers
shim_height = 0.5;

// thickness of a gear + shim
gsh = gear_height + shim_height;

// conversion from N teeth to radius
teeth_rad = pitch / (2*PI);

// height of the top plate
top_height = 7 * gsh + 2 * brace_height;

// height of the inner planet ring
inner_height = top_height + gsh;


// height for each of the planets
moon_height = top_height + brace_height;
earth_height = moon_height + gsh + 1;
venus_height = earth_height + 1;
mercury_height = venus_height + 1;
sun_height = mercury_height + 10;

mars_height = top_height + brace_height - 2;
jupiter_height = mars_height - 1;
saturn_height = jupiter_height - 1;



// Create an h mm high gear with n teeth and a shaft of s mm 
module gear(n,s)
{
	render() difference()
	{
		cylinder(r=n*teeth_rad, h=gear_height, $fn=n);
		translate([0,0,-1]) cylinder(r=n*teeth_rad - 2, h=gear_height+2, $fn=n);
	}

	render() difference()
	{
		union()
		{
			cylinder(d=s+1, h=gear_height, $fn=16);
			for(i=[0:2])
				rotate([0,0,i*360/3])
				translate([-2,0,0])
				cube([n*teeth_rad,gear_height,gear_height]);
		}
			
		translate([0,0,-1]) cylinder(d=s, h=gear_height+2, $fn=16);
	}
}


// create a hollow shaft
module shaft(h,s)
{
	render() difference()
	{
		cylinder(d=s,h=h, $fn=16);
		translate([0,0,-1]) cylinder(d=s-0.05,h=h+2, $fn=16);
	}
}

module inner_drive()
{
	// mars
	translate([0,0,3*gsh+brace_height]) gear(32,3.0);

	// skip the brace

	// earth
	translate([0,0,2*gsh]) gear(46,3.0);

	// venus
	translate([0,0,1*gsh]) gear(57,3.0);

	// mercury
	translate([0,0,0*gsh]) gear(74,3.0);

	translate([0,0,-shim_height]) shaft(5*gsh+brace_height+shim_height, 3.0);
}


module inner_shafts()
{
	// saturn
	rotate([0,0,time*(16/60)*(36/61)*(61/30)*(15/76)])
	color("green") translate([0,0,6*gsh+brace_height]) {
		gear(76, 3.6);
		shaft(saturn_height-6*gsh-brace_height,3.6);
	}

	// jupiter
	rotate([0,0,time*(16/60)*(36/61)])
	color("purple") translate([0,0,5*gsh+brace_height]) {
		gear(61, 3.4);
		shaft(jupiter_height-5*gsh-brace_height,3.4);
	}


	// mars
	rotate([0,0,time*32/60])
	color("red") translate([0,0,3*gsh+brace_height]) {
		gear(60,3.2);
		shaft(mars_height-3*gsh-brace_height,3.2);
	}

	// fixed gear for the moon
	color("silver") translate([0,0,3*gsh]) shaft(moon_height-3*gsh,3.0);


	// earth
	rotate([0,0,time*46/46])
	color("blue") translate([0,0,2*gsh]) {
		gear(46,2.8);
		shaft(earth_height-2*gsh,2.8);
	}

	// venus
	rotate([0,0,time*57/35])
	color("pink") translate([0,0,1*gsh]) {
		gear(35,2.6);
		shaft(venus_height-1*gsh,2.6);
	}

	// mercury
	rotate([0,0,time*74/18])
	color("gray") translate([0,0,0*gsh]) {
		gear(18,2.4);
		shaft(mercury_height-0*gsh,2.4);
	}
}


module outer_drive2()
{
	// saturn
	translate([0,0,3*gsh]) gear(15,3);

	// jupiter output
	translate([0,0,2*gsh]) gear(30,3);

	// jupiter input
	translate([0,0,1*gsh]) gear(50,3);
	translate([0,0,-shim_height]) shaft(4*gsh+1*shim_height, 3);
}


module outer_drive1()
{
	translate([0,0,1*gsh]) gear(16,3);
	translate([0,0,0*gsh]) gear(32,3);
	translate([0,0,-shim_height]) shaft(4*gsh+shim_height,3);
}



module planets()
{
	rotate([0,0,time*74/18])
	color("gray") translate([0,-0.5,mercury_height-1]) cube([20,1,1]);

	rotate([0,0,time*57/35])
	color("pink") translate([0,-0.5,venus_height-1]) cube([30,1,1]);

	rotate([0,0,time*46/46])
	translate([0,0,earth_height-1])
	{
	color("blue") translate([0,-0.5,0]) cube([146*teeth_rad+5,1,1]);

	translate([(146+11)*teeth_rad,0,-3])
	rotate([0,0,-time*(146/11)])
	{
		gear(11,2);
		shaft(10,2);
		translate([0,0,10]) sphere(r=4);
		translate([5,0,10]) sphere(r=1);
	}
	}

	rotate([0,0,time*(32/60)])
	translate([0,0,mars_height-1])
	color("red") translate([0,-0.5,0]) cube([80,1,1]);

	rotate([0,0,time*(16/60)*(36/61)])
	translate([0,0,jupiter_height-1])
	color("purple") translate([0,-0.5,0]) cube([100,1,1]);

	rotate([0,0,time*(16/60)*(36/61)*(61/30)*(15/76)])
	translate([0,0,saturn_height-1])
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
rotate([0,0,+time*(32/32)])
outer_drive1();

rotate([0,0,70])
translate([(30+61)*teeth_rad,0,3*gsh+brace_height])
rotate([0,0,-time*(32/32)*(16/50)])
outer_drive2();

planets();


// fixed gear for the moon
color("silver") translate([0,0,moon_height]) gear(146, 3);

translate([0,0,-shim_height]) shaft(sun_height, 2.2); // sun shaft
