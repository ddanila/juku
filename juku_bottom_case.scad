// Juku bottom case
// Units: millimeters

outside_width = 340;
outside_depth = 290;
outside_height = 18;
case_thickness = 3;

cut_overlap = 0.01;

assert(case_thickness > 0);
assert(2 * case_thickness < outside_width);
assert(2 * case_thickness < outside_depth);
assert(case_thickness < outside_height);

module bottom_case() {
    difference() {
        cube([outside_width, outside_depth, outside_height]);

        translate([
            case_thickness,
            case_thickness,
            case_thickness
        ])
            cube([
                outside_width - 2 * case_thickness,
                outside_depth - 2 * case_thickness,
                outside_height - case_thickness + cut_overlap
            ]);
    }
}

bottom_case();
