/* Test the orrery gear mesh and couplers */
include <gears.scad>

teeth1=18;
teeth2=30;
dist=(teeth1+teeth2)*pitch / (2*PI) + 0.5;

module planet1_gear()
{
	bore=5;
	color("red") {
		orrery_gear(teeth1, height=5-washer, bore_diameter=bore, direction=+1);
		washer(bore);
		shaft_top(25, bore, 1);
	}
}

module planet2_gear()
{
	bore=7;
	color("blue") {
		orrery_gear(teeth2, height=5-washer, bore_diameter=bore, direction=+1);
		shaft_top(15, bore, 1);
		washer(bore);
	}
}

module drive_gear()
{
	bore=5;
	orrery_gear(teeth2, 5, pitch=pitch, direction=-1, bore_diameter=bore);
	translate([0,0,5])
	orrery_gear(teeth1, 5-washer, pitch=pitch, direction=-1, bore_diameter=bore);

	// no washer, since it has a physical one
	//translate([0,0,5]) washer(bore);
}

module hexnut(d)
{
	cylinder(d=1.8*d, h=3.5, $fn=6);
}

module base_plate()
{
	render() difference()
	{
		hull() {
			cylinder(d=20, h=10-washer);
			translate([dist,0,0]) cylinder(d=20, h=10-washer);
		}

		translate([0,0,0])
		{
			translate([0,0,-1]) cylinder(d=5,$fn=32,h=10+2);

			hexnut(5);
			translate([0,0,10-3.5]) hexnut(5);
		}

		translate([dist,0,0]) {
			translate([0,0,-1]) cylinder(d=5,$fn=32,h=10+2);

			hexnut(5);
			translate([0,0,10-3.5]) hexnut(5);
		}

		translate([dist/2,0,-1]) cylinder(d=18,h=12);
	}

	//washer(5);
	//%cylinder(d=5,h=50);

	translate([dist,0,0]) {
		//washer(5);
		//%cylinder(d=5,h=50);
	}
}

module top_plate()
{
	render() difference() {
		hull() {
			cylinder(d=20, h=5);
			translate([dist,0,0]) cylinder(d=20, h=5);
		}

		// for the output shaft, inner 7, outer 8
		translate([0,0,-1]) cylinder(d=9, h=5+2, $fn=32);

		// for the input shaft
		translate([dist,0,-1]) cylinder(d=5, h=5+2, $fn=32);
		translate([dist,0,2]) hexnut(5);

		translate([dist/2,0,-1]) cylinder(d=18,h=12);
	}
}

module assembly()
{
	translate([0,0,0*height]) base_plate();
	translate([0,0,4*height]) top_plate();

	rotate([0,0,180/teeth1])
	translate([0,0,2*height]) planet1_gear();

	rotate([0,0,180/teeth2])
	translate([0,0,3*height]) planet2_gear();

	translate([dist,0,2*height]) drive_gear();
}


module plate()
{
	translate([0,0,0]) top_plate();
	translate([0,30,0]) base_plate();

	translate([0,60,0]) planet1_gear();
	translate([50,60,0]) planet2_gear();

	translate([70,10,0]) drive_gear();
}


//assembly();
plate();
