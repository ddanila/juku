// Juku keycap
// Units: millimeters

outside_width = 17.5;
outside_depth = 17.5;
height = 11;
top_chamfer = 3;
wall_thickness = 1;
top_thickness = 3;
chamfer_steps = 18;

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

keycap_shell();
