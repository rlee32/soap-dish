// Units are mm.
// Outside dimensions are specified, and thickness goes inward.

function i2mm(x) = x * 0.0254 * 1000;
x_axis = [1, 0, 0];
y_axis = [0, 1, 0];
z_axis = [0, 0, 1];

width = i2mm(4.5);
plate_thickness = 1.5;
plate_length = i2mm(4.5);
cross_offset = i2mm(1.5); // shifts the grates lower.

grate_thickness = 1.5;
grate_depth = 10;
grate_length = i2mm(1.5);

standing = i2mm(0.5);  // spacing between flat plate and soap.
grate_spacing = 20;
grate_span = i2mm(3) + grate_depth; // length of grate that holds the major axis of soap.

// minimum plate thickness that allows for quality prints.
min_thickness = 1.5;

side_support_width = i2mm(0.5);
side_support_dim = 0.5 * plate_length;

bottom_support_width = i2mm(0.25);

drainage_length = i2mm(1.5);
drainage_height = i2mm(0.5);

// derived params
rep_width = grate_thickness + grate_spacing;
repetitions = floor((width - grate_thickness) / rep_width);
margin = 0.5 * (width - (repetitions * rep_width + grate_thickness));
side_support_length = 0.5 * plate_length;
bottom_support_length = sqrt(2) * side_support_length;

module side_support() {
    shift = 0.5 * plate_length / sqrt(2) - 0.5 * side_support_dim;
    difference() {
        translate([0, -shift, -shift])
            cube(size = [min_thickness, side_support_dim, side_support_dim], center = true);
        cutter_dim = 2 * side_support_dim;
        rotate([45, 0, 0])
            translate([0, 0, 0.5 * cutter_dim])
                cube([cutter_dim, cutter_dim, cutter_dim], center = true);
    }
}

module flange() {
    union() {
        cube(size = [grate_thickness, grate_depth, grate_length], center = true);
        translate([0, 0.5 * grate_span - 0.5 * grate_depth, -0.5 * grate_length + 0.5 * standing])
            cube(size = [grate_thickness, grate_span, standing], center = true);
    }
}

difference() {
    union() {
        difference() {
            rotate([45, 0, 0]) {
                union() {
                    cube(size = [width, plate_length, plate_thickness], center = true);
                    x_base = 0.5 * grate_thickness - 0.5 * width + margin;
                    z_base = 0.5 * grate_length;
                    for (i = [0 : repetitions]) {
                        translate([x_base + i * rep_width, -cross_offset, z_base])
                            flange();
                    }
                }
            }
            translate([0, 0, -0.5 * width - side_support_length / sqrt(2)])
                cube(size = [2 * width, 2 * width, width], center = true);
        }
        side_support();
        translate([-0.5 * (width - min_thickness), 0, 0])
            side_support();
        translate([0.5 * (width - min_thickness), 0, 0])
            side_support();
    }
    translate([0, 0.5 * bottom_support_length + bottom_support_width, -0.5 * bottom_support_length + 0.5 * bottom_support_width])
        cube(size = [2 * width, 2 * bottom_support_width, 2 * bottom_support_width], center = true);
}

center_distance = 0.5 * plate_length / sqrt(2);
drainage_plate_shift = min_thickness; // so that plate is fused into rest of soap holder.

// base drainage plate.
translate([0, drainage_plate_shift - center_distance - 0.5 * drainage_length, 0.5 * min_thickness - center_distance]) {
    cube(size = [width, drainage_length, min_thickness], center = true);
}

// drainage plate sides.
drainage_side_length = 2 * drainage_length; // long enough to fuse into side supports.
translate([0, -center_distance + min_thickness, -center_distance + 0.5 * drainage_height]) {
    translate([0.5 * width - 0.5 * min_thickness, 0, 0])
        cube(size = [min_thickness, drainage_side_length, drainage_height], center = true);
    translate([-(0.5 * width - 0.5 * min_thickness), 0, 0])
        cube(size = [min_thickness, drainage_side_length, drainage_height], center = true);
}



