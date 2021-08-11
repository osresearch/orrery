all: \
	mercury_gear.stl \
	venus_gear.stl \
	earth_gear.stl \
	moon_brace.stl \
	mars_gear.stl \
	jupiter_gear.stl \
	saturn_gear.stl \
	baseplate.stl \
	topplate.stl \
	inner_stack.stl \
	outer_stack.stl \

%.stl: orrery2.scad gears.scad
	echo "rendering $@"
	echo 'include <orrery2.scad>' > tmp.scad
	echo '$(basename $@)();' >> tmp.scad
	openscad -D mode=-1 -o "$@" tmp.scad
	rm tmp.scad
