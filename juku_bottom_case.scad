// Juku bottom case
// Units: millimeters

outside_width = 340;
outside_depth = 290;
outside_height = 18;
case_thickness = 3;
bottom_chamfer = 8;
top_edge_chamfer = 3;
rear_pcb_opening_width = 300;
rear_pcb_opening_height = 12;

cut_overlap = 0.01;
inner_chamfer_offset = case_thickness * sqrt(2);
inner_chamfer_end_z = bottom_chamfer + inner_chamfer_offset;
rear_pcb_opening_x = (outside_width - rear_pcb_opening_width) / 2;
rear_pcb_opening_z = outside_height - rear_pcb_opening_height;

assert(case_thickness > 0);
assert(2 * case_thickness < outside_width);
assert(2 * case_thickness < outside_depth);
assert(case_thickness < outside_height);
assert(bottom_chamfer > 0);
assert(inner_chamfer_end_z < outside_height);
assert(top_edge_chamfer > 0);
assert(top_edge_chamfer <= case_thickness);
assert(bottom_chamfer < outside_height - top_edge_chamfer);
assert(rear_pcb_opening_width > 0);
assert(rear_pcb_opening_width < outside_width);
assert(rear_pcb_opening_height > 0);
assert(rear_pcb_opening_height < outside_height);

module section(width, depth, x, y, z) {
    translate([x, y, z])
        cube([width, depth, cut_overlap]);
}

module outside_shape() {
    hull() {
        section(
            outside_width - 2 * bottom_chamfer,
            outside_depth - bottom_chamfer,
            bottom_chamfer,
            bottom_chamfer,
            0
        );

        section(outside_width, outside_depth, 0, 0, bottom_chamfer);
        section(
            outside_width,
            outside_depth,
            0,
            0,
            outside_height - top_edge_chamfer
        );
        section(
            outside_width - 2 * top_edge_chamfer,
            outside_depth - 2 * top_edge_chamfer,
            top_edge_chamfer,
            top_edge_chamfer,
            outside_height
        );
    }
}

module inside_cutout() {
    lower_inset = bottom_chamfer + inner_chamfer_offset - case_thickness;

    hull() {
        section(
            outside_width - 2 * lower_inset,
            outside_depth - lower_inset - case_thickness,
            lower_inset,
            lower_inset,
            case_thickness
        );

        section(
            outside_width - 2 * case_thickness,
            outside_depth - 2 * case_thickness,
            case_thickness,
            case_thickness,
            inner_chamfer_end_z
        );

        section(
            outside_width - 2 * case_thickness,
            outside_depth - 2 * case_thickness,
            case_thickness,
            case_thickness,
            outside_height + cut_overlap
        );
    }
}

module rear_pcb_opening() {
    translate([
        rear_pcb_opening_x,
        outside_depth - case_thickness - cut_overlap,
        rear_pcb_opening_z
    ])
        cube([
            rear_pcb_opening_width,
            case_thickness + 2 * cut_overlap,
            rear_pcb_opening_height
        ]);
}

module bottom_case() {
    difference() {
        outside_shape();
        inside_cutout();
        rear_pcb_opening();
    }
}

bottom_case();
