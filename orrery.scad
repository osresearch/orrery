/*
 * Six planet orrery with earth moon
 */

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
	translate([0,0,3*gsh+brace_height]) gear(32,3.0);
	translate([0,0,2*gsh]) gear(46,3.0);
	translate([0,0,1*gsh]) gear(57,3.0);
	translate([0,0,0*gsh]) gear(74,3.0);

	translate([0,0,-shim_height]) shaft(4*gsh+brace_height+shim_height, 3.0);
}


module inner_shafts()
{
	// saturn
	color("green") translate([0,0,6*gsh+brace_height]) {
		gear(76, 3.6);
		shaft(top_height-6*gsh-brace_height-1.2,3.6);
	}

	// jupiter
	color("purple") translate([0,0,5*gsh+brace_height]) {
		gear(61, 3.4);
		shaft(top_height-5*gsh-brace_height-0.8,3.4);
	}


	// mars
	color("red") translate([0,0,3*gsh+brace_height]) {
		gear(60,3.2);
		shaft(top_height-3*gsh-brace_height-0.4,3.2);
	}

	// fixed gear for the moon
	color("silver") translate([0,0,3*gsh]) shaft(top_height+gsh-3*gsh,3.0);


	// earth
	color("blue") translate([0,0,2*gsh]) {
		gear(46,2.8);
		shaft(inner_height+10-2*gsh-2,2.8);
	}

	// venus
	color("pink") translate([0,0,1*gsh]) {
		gear(35,2.6);
		shaft(inner_height+10-1*gsh-1,2.6);
	}

	// mercury
	color("gray") translate([0,0,0*gsh]) {
		gear(18,2.4);
		shaft(inner_height+10-0*gsh-0,2.4);
	}
}


module outer_drive()
{
	// saturn
	translate([0,0,2*gsh]) gear(15,3);

	// jupiter
	translate([0,0,1*gsh]) gear(30,3);
	translate([0,0,-gsh-shim_height]) shaft(4*gsh+1*shim_height, 3);
}



module outer_reduction()
{
	translate([0,0,2*gsh]) gear(40,2.8);
	translate([0,0,1*gsh]) gear(16,3);
	translate([0,0,0*gsh]) gear(40,3);

	translate([(40+16)*teeth_rad,0,2*gsh]) gear(16,3);
	translate([(40+16)*teeth_rad,0,1*gsh]) gear(40,3);
}





translate([(74+18)*teeth_rad,0,0])
inner_drive();

inner_shafts();

rotate([0,0,120])
translate([(30+61)*teeth_rad,0,4*gsh+brace_height])
outer_drive();

%rotate([0,0,-120])
translate([(40+60)*teeth_rad,0,3*gsh+brace_height])
rotate([0,0,90])
outer_reduction();



// fixed gear for the moon
color("silver") translate([0,0,top_height]) gear(146, 3);

translate([0,0,-shim_height]) shaft(50, 2.2); // sun shaft
