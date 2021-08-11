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
	echo 'include <orrery2.scad>' > $@.scad
	echo '$(basename $@)();' >> $@.scad
	openscad -D mode=-1 -o "$@" $@.scad
	rm $@.scad
