# Juku Keycap Notes

## OpenSCAD command

OpenSCAD is installed through Snap as `openscad-nightly`, not `openscad`.

```bash
openscad-nightly --version
```

If a plain `openscad` command is useful, add this alias to `~/.bashrc`:

```bash
alias openscad=openscad-nightly
```

On macOS the binary is inside the app bundle: `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`.

## Generated artifacts

`juku_keycap.scad` is the only source file. Everything else is generated from it and must not be edited by hand:

| File | Regenerate with |
| --- | --- |
| `juku_keycap.stl` | `openscad -o juku_keycap.stl --export-format binstl juku_keycap.scad` |
| `preview_top.png`, `preview_bottom.png` | `./scripts/render-previews.sh` |

The preview script renders at 8x the target size and downscales to 1600x1200, because OpenSCAD's CLI renders without antialiasing. It uses the `JukuUniform` color scheme (`scripts/juku-uniform.json`, installed into OpenSCAD's user scheme directory automatically) so that subtraction-cut surfaces don't get the distinct "back face" color.

`3d_printed_top.jpeg` and `3d_printed_bottom.jpeg` are photos of a real print on a resin (photopolymer) printer, with metadata stripped.

## Iteration workflow

After each modeling change:

1. Render the SCAD file to an STL to catch syntax and geometry errors.

   ```bash
   ./scripts/check-render.sh
   ```

2. Confirm OpenSCAD reports a manifold 3D object with `Status: NoError`.

3. Open the SCAD file in OpenSCAD for manual review from a normal desktop terminal or the application launcher.

   ```bash
   ./scripts/open-openscad.sh
   ```

Codex can run the automated render check reliably. It can also attempt to launch the OpenSCAD UI, but Snap/desktop session handling may make that window flash briefly or disappear, so manual review is best started from the user's desktop session.

## Modeling notes

Large spheres used for shallow cuts need a high local segment count. A large-radius sphere with the global `$fn = 48` can technically intersect the model but look flat in OpenSCAD because the visible patch is a low-resolution facet. Use a local `$fn`, for example:

```scad
sphere(r = top_dish_radius, $fn = top_dish_segments);
```

## Bottom case dimensions

All dimensions are in millimeters.

| Dimension | Value |
| --- | ---: |
| Outer width (X) | 340 |
| Outer depth (Y) | 290 |
| Outer height (Z) | 18 |
| Case thickness | 3 |
| Front and side bottom chamfer | 8 at 45 degrees |
| Top rim chamfer | 3 at 45 degrees, downward toward outside |
| Rear PCB opening | 300 wide x 12 high, centered horizontally and open at top |
| Rear outer guide rail | 312 long x 4 deep x 15 high |
| Rear guide channel | 2 deep, with the case floor at its bottom |
| Rear inner guide rail | 306 long x 3 deep x 15 high |
| Leg hole centers | 15 from each adjacent outer edge |
| Leg through-hole | 3.5 diameter |
| Leg exterior counterbore | 5.5 diameter x 1.5 deep |
| Leg interior reinforcement | 5.5 diameter x 1.5 high |
| Leg hole cylinder segments | 128 |

The case is an open-top shell with 3 mm walls and floor. The front and both
sides have an 8 mm external bottom chamfer; the rear remains square. The
inner chamfer is offset to keep the sloped material 3 mm thick. The top rim
slopes from the inside lip downward and outward across the full wall
thickness. A rectangular PCB opening is centered horizontally in the rear
wall and extends downward from the top edge. The maximum outer envelope
starts at the origin.

The experimental PCB guide aligns vertically with the rear opening. Its
outer face aligns with the exterior rear face. Moving inward, the
arrangement is a 4 mm rail, a 2 mm channel, and a 3 mm rail. Both rails are
centered; the outer rail extends 3 mm farther at each end, where square
mirrored bridges close the channel. The 300 mm opening is cut through the
rear wall and the complete guide depth from Z=6 to Z=18. The guide extends
down to the inner floor at Z=3, leaving a continuous 3 mm-high base beneath
the opening. Its exterior top edge has the same 3 mm, 45-degree chamfer as
the case rim.

Four leg mounting holes are positioned symmetrically near the corners. Each
has a through-hole, a concentric counterbore entering from the exterior
underside, and a concentric reinforcement boss rising from the inner floor.
