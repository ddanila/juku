// Juku top case
// Units: millimeters

outside_width = 352;
outside_depth = 295;
rear_height = 50;
front_height = 9;
wall_thickness = 3;
slope_starts_from_back = 143;

slope_start_y = outside_depth - slope_starts_from_back;

assert(wall_thickness > 0);
assert(2 * wall_thickness < outside_width);
assert(2 * wall_thickness < outside_depth);
assert(wall_thickness < front_height);
assert(front_height < rear_height);
assert(slope_starts_from_back > 0);
assert(slope_starts_from_back < outside_depth);

function top_height_at(y) =
    y < slope_start_y
        ? front_height
            + (rear_height - front_height) * y / slope_start_y
        : rear_height;

module x_prism(width, yz_points) {
    point_count = len(yz_points);

    polyhedron(
        points = concat(
            [
                for (p = yz_points)
                    [0, p[0], p[1]]
            ],
            [
                for (p = yz_points)
                    [width, p[0], p[1]]
            ]
        ),
        faces = concat(
            [[for (i = [point_count - 1 : -1 : 0]) i]],
            [[for (i = [0 : point_count - 1]) i + point_count]],
            [
                for (i = [0 : point_count - 1])
                    [
                        i,
                        (i + 1) % point_count,
                        (i + 1) % point_count + point_count,
                        i + point_count
                    ]
            ]
        )
    );
}

module top_skin() {
    x_prism(
        outside_width,
        [
            [0, top_height_at(0) - wall_thickness],
            [
                slope_start_y,
                top_height_at(slope_start_y) - wall_thickness
            ],
            [
                outside_depth,
                top_height_at(outside_depth) - wall_thickness
            ],
            [outside_depth, top_height_at(outside_depth)],
            [slope_start_y, top_height_at(slope_start_y)],
            [0, top_height_at(0)]
        ]
    );
}

module side_wall(x) {
    translate([x, 0, 0])
        x_prism(
            wall_thickness,
            [
                [0, 0],
                [outside_depth, 0],
                [outside_depth, top_height_at(outside_depth)],
                [slope_start_y, top_height_at(slope_start_y)],
                [0, top_height_at(0)]
            ]
        );
}

module front_wall() {
    x_prism(
        outside_width,
        [
            [0, 0],
            [wall_thickness, 0],
            [wall_thickness, top_height_at(wall_thickness)],
            [0, top_height_at(0)]
        ]
    );
}

module rear_wall() {
    x_prism(
        outside_width,
        [
            [outside_depth - wall_thickness, 0],
            [outside_depth, 0],
            [outside_depth, top_height_at(outside_depth)],
            [
                outside_depth - wall_thickness,
                top_height_at(outside_depth - wall_thickness)
            ]
        ]
    );
}

module top_case() {
    union() {
        top_skin();
        side_wall(0);
        side_wall(outside_width - wall_thickness);
        front_wall();
        rear_wall();
    }
}

top_case();
