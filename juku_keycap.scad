// Juku keycap
// Units: millimeters

outside_width = 17.5;
outside_depth = 17.5;
height = 11;
top_chamfer = 3;
wall_thickness = 1;
top_thickness = 3;
chamfer_steps = 18;
spring_rod_diameter = 2.25;
spring_rod_length = 2;
spring_rod_end_chamfer = 0.5;
spring_rod_base_width = 2.25;
spring_rod_base_depth = 8;
spring_rod_base_height = 2;
spring_rod_base_xy_chamfer = 1;

inner_width = outside_width - 2 * wall_thickness;
inner_depth = outside_depth - 2 * wall_thickness;

$fn = 48;

function rounded_chamfer_inset(z, radius) =
    radius - sqrt(radius * radius - z * z);

module thin_box(width, depth, z) {
    translate([0, 0, z])
        cube([width, depth, 0.01], center = true);
}

module rounded_chamfered_box(width, depth, total_height, chamfer) {
    body_z = total_height - chamfer;

    hull() {
        thin_box(width, depth, 0);
        thin_box(width, depth, body_z);
    }

    for (step = [0 : chamfer_steps - 1]) {
        z1 = chamfer * step / chamfer_steps;
        z2 = chamfer * (step + 1) / chamfer_steps;
        inset1 = rounded_chamfer_inset(z1, chamfer);
        inset2 = rounded_chamfer_inset(z2, chamfer);

        hull() {
            thin_box(width - 2 * inset1, depth - 2 * inset1, body_z + z1);
            thin_box(width - 2 * inset2, depth - 2 * inset2, body_z + z2);
        }
    }
}

module keycap_shell() {
    difference() {
        rounded_chamfered_box(outside_width, outside_depth, height, top_chamfer);

        translate([0, 0, (height - top_thickness) / 2 - 0.02])
            cube(
                [
                    inner_width,
                    inner_depth,
                    height - top_thickness + 0.04
                ],
                center = true
            );
    }
}

module spring_rod() {
    radius = spring_rod_diameter / 2;
    tip_radius = radius - spring_rod_end_chamfer;
    rod_top_z = height - top_thickness;
    straight_length = rod_top_z + spring_rod_length - spring_rod_end_chamfer;

    translate([0, 0, -spring_rod_length + spring_rod_end_chamfer])
        cylinder(h = straight_length, r = radius);

    translate([0, 0, -spring_rod_length])
        cylinder(h = spring_rod_end_chamfer, r1 = tip_radius, r2 = radius);
}

module rounded_xy_box(width, depth, z_height, xy_radius) {
    linear_extrude(height = z_height)
        offset(r = xy_radius)
            square([width - 2 * xy_radius, depth - 2 * xy_radius], center = true);
}

module spring_rod_base() {
    translate([0, 0, height - top_thickness - spring_rod_base_height])
        rounded_xy_box(
            spring_rod_base_width,
            spring_rod_base_depth,
            spring_rod_base_height,
            spring_rod_base_xy_chamfer
        );
}

union() {
    keycap_shell();
    spring_rod_base();
    spring_rod();
}
