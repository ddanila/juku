// Juku top case
// Units: millimeters

outside_width = 352;
outside_depth = 295;
rear_height = 50;
front_height = 9;
wall_thickness = 3;
slope_starts_from_back = 143;
keyboard_row_front_offset = 27;
keyboard_row_left_offset = 50;
keyboard_row_width = 252;
keyboard_row_depth = 18;
keyboard_row_side_step = 9;
keyboard_row_4_left_shift = 4;
keyboard_row_6_right_shift = 18;
keyboard_row_6_width = 144;
side_wall_chamfer_height = 3;
side_wall_chamfer_width = 2;
side_wall_chamfer_z_overlap = 1;

slope_start_y = outside_depth - slope_starts_from_back;
cut_overlap = 0.01;

assert(wall_thickness > 0);
assert(2 * wall_thickness < outside_width);
assert(2 * wall_thickness < outside_depth);
assert(wall_thickness < front_height);
assert(front_height < rear_height);
assert(slope_starts_from_back > 0);
assert(slope_starts_from_back < outside_depth);
assert(keyboard_row_front_offset > 0);
assert(keyboard_row_left_offset > wall_thickness);
assert(keyboard_row_width > 0);
assert(keyboard_row_depth > 0);
assert(keyboard_row_side_step > 0);
assert(keyboard_row_6_width > 0);
assert(side_wall_chamfer_height > 0);
assert(side_wall_chamfer_width > 0);
assert(side_wall_chamfer_height < front_height);
assert(side_wall_chamfer_width < wall_thickness);
assert(side_wall_chamfer_z_overlap >= 0);

function top_height_at(y) =
    y < slope_start_y
        ? front_height
            + (rear_height - front_height) * y / slope_start_y
        : rear_height;

function inner_top_height_at(y) = top_height_at(y) - wall_thickness;

module shell_profile_2d() {
    polygon([
        [0, 0],
        [wall_thickness, 0],
        [wall_thickness, inner_top_height_at(wall_thickness)],
        [slope_start_y, inner_top_height_at(slope_start_y)],
        [
            outside_depth - wall_thickness,
            inner_top_height_at(outside_depth - wall_thickness)
        ],
        [outside_depth - wall_thickness, 0],
        [outside_depth, 0],
        [outside_depth, rear_height],
        [slope_start_y, rear_height],
        [0, front_height]
    ]);
}

module shell(width) {
    multmatrix([
        [0, 0, 1, 0],
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 1]
    ])
        linear_extrude(height = width)
            shell_profile_2d();
}

module side_wall_profile_2d() {
    polygon([
        [0, 0],
        [outside_depth, 0],
        [outside_depth, inner_top_height_at(outside_depth)],
        [slope_start_y, inner_top_height_at(slope_start_y)],
        [0, inner_top_height_at(0)]
    ]);
}

module side_wall(x) {
    translate([x, 0, 0])
        multmatrix([
            [0, 0, 1, 0],
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 0, 1]
        ])
            linear_extrude(height = wall_thickness)
                side_wall_profile_2d();
}

module side_top_chamfer_fill_segment(x_outer, x_inner, y0, y1) {
    z0 = top_height_at(y0);
    z1 = top_height_at(y1);

    polyhedron(
        points = [
            [x_outer, y0, z0 - side_wall_chamfer_height],
            [x_inner, y0, z0 - side_wall_chamfer_height],
            [x_inner, y0, z0],

            [x_outer, y1, z1 - side_wall_chamfer_height],
            [x_inner, y1, z1 - side_wall_chamfer_height],
            [x_inner, y1, z1]
        ],
        faces = [
            [0, 2, 1],
            [3, 4, 5],
            [0, 3, 5, 2],
            [0, 1, 4, 3],
            [1, 2, 5, 4]
        ]
    );
}

module front_side_chamfer_cut(x_outer, x_inner) {
    translate([0, 0, -cut_overlap])
        linear_extrude(
            height =
                front_height
                + side_wall_chamfer_z_overlap
                + 2 * cut_overlap
        )
            polygon([
                [x_outer, -cut_overlap],
                [x_inner, -cut_overlap],
                [x_outer, side_wall_chamfer_height]
            ]);
}

module side_top_chamfers() {
    side_top_chamfer_fill_segment(
        0,
        side_wall_chamfer_width,
        0,
        slope_start_y
    );
    side_top_chamfer_fill_segment(
        0,
        side_wall_chamfer_width,
        slope_start_y,
        outside_depth
    );
    side_top_chamfer_fill_segment(
        outside_width,
        outside_width - side_wall_chamfer_width,
        0,
        slope_start_y
    );
    side_top_chamfer_fill_segment(
        outside_width,
        outside_width - side_wall_chamfer_width,
        slope_start_y,
        outside_depth
    );
}

module side_wall_chamfer_cuts() {
    front_side_chamfer_cut(
        -cut_overlap,
        side_wall_chamfer_width
    );
    front_side_chamfer_cut(
        outside_width + cut_overlap,
        outside_width - side_wall_chamfer_width
    );
}

module keyboard_row_cut(x, y, width) {
    translate([x, y, -cut_overlap])
        cube([
            width,
            keyboard_row_depth,
            rear_height + 2 * cut_overlap
        ]);
}

module keyboard_cutout() {
    row_1_x = keyboard_row_left_offset;
    row_1_y = keyboard_row_front_offset;
    row_1_width = keyboard_row_width;

    row_2_x = row_1_x - keyboard_row_side_step;
    row_2_y = row_1_y + keyboard_row_depth;
    row_2_width = row_1_width + 2 * keyboard_row_side_step;

    row_3_x = row_2_x - keyboard_row_side_step;
    row_3_y = row_2_y + keyboard_row_depth;
    row_3_width = row_2_width + 2 * keyboard_row_side_step;

    row_4_x = row_3_x - keyboard_row_4_left_shift;
    row_4_y = row_3_y + keyboard_row_depth;
    row_4_width = row_3_width;

    row_5_x = row_4_x + keyboard_row_side_step;
    row_5_y = row_4_y + keyboard_row_depth;
    row_5_width = row_4_width - 2 * keyboard_row_side_step;

    row_6_x = row_5_x + keyboard_row_6_right_shift;
    row_6_y = row_5_y + keyboard_row_depth;

    keyboard_row_cut(row_1_x, row_1_y, row_1_width);
    keyboard_row_cut(row_2_x, row_2_y, row_2_width);
    keyboard_row_cut(row_3_x, row_3_y, row_3_width);
    keyboard_row_cut(row_4_x, row_4_y, row_4_width);
    keyboard_row_cut(row_5_x, row_5_y, row_5_width);
    keyboard_row_cut(row_6_x, row_6_y, keyboard_row_6_width);
}

module top_case() {
    difference() {
        union() {
            translate([side_wall_chamfer_width, 0, 0])
                shell(outside_width - 2 * side_wall_chamfer_width);
            side_wall(0);
            side_wall(outside_width - wall_thickness);
            side_top_chamfers();
        }

        side_wall_chamfer_cuts();
        keyboard_cutout();
    }
}

top_case();
