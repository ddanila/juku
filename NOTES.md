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
