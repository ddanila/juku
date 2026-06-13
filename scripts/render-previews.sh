#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Find the OpenSCAD binary (Snap on Linux, app bundle on macOS).
if command -v openscad-nightly >/dev/null; then
    openscad=openscad-nightly
elif command -v openscad >/dev/null; then
    openscad=openscad
elif [ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]; then
    openscad=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
else
    echo "OpenSCAD not found" >&2
    exit 1
fi

# Render at 8x the target size, then downscale to 1600x1200 for antialiasing
# (OpenSCAD's CLI renders without antialiasing).
render() {
    local scad_file="$1" out="$2" camera="$3" width="$4" height="$5"
    "$openscad" -o "$out" --render --imgsize="$width,$height" --autocenter --viewall \
        --camera="$camera" --colorscheme=Monotone -D '$fn=256' "$scad_file"
    if command -v sips >/dev/null; then
        sips -z 1200 1600 "$out" >/dev/null
    elif command -v magick >/dev/null; then
        magick "$out" -resize 1600x1200 "$out"
    else
        echo "no downscaler found, leaving $out at full size" >&2
    fi
}

render \
    "$repo_root/keycap/juku-keycap.scad" \
    "$repo_root/keycap/preview-top.png" \
    0,0,0,55,0,25,140 \
    12800 9600

render \
    "$repo_root/keycap/juku-keycap.scad" \
    "$repo_root/keycap/preview-bottom.png" \
    0,0,0,235,0,205,140 \
    12800 9600

render \
    "$repo_root/bottom-case/juku-bottom-case.scad" \
    "$repo_root/bottom-case/preview.png" \
    0,0,0,55,0,25,160 \
    3200 2400
