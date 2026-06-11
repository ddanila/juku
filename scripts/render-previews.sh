#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scad_file="$repo_root/juku_keycap.scad"

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

# Install the uniform color scheme into OpenSCAD's user scheme directory.
if [ "$(uname)" = Darwin ]; then
    scheme_dir="$HOME/Library/Application Support/OpenSCAD/color-schemes/render"
else
    scheme_dir="${XDG_DATA_HOME:-$HOME/.local/share}/OpenSCAD/color-schemes/render"
fi
mkdir -p "$scheme_dir"
cp "$repo_root/scripts/juku-uniform.json" "$scheme_dir/"

# Render at 8x the target size, then downscale to 1600x1200 for antialiasing
# (OpenSCAD's CLI renders without antialiasing).
render() {
    local out="$1" camera="$2"
    "$openscad" -o "$out" --render --imgsize=12800,9600 --autocenter --viewall \
        --camera="$camera" --colorscheme=JukuUniform -D '$fn=256' "$scad_file"
    if command -v sips >/dev/null; then
        sips -z 1200 1600 "$out" >/dev/null
    elif command -v magick >/dev/null; then
        magick "$out" -resize 1600x1200 "$out"
    else
        echo "no downscaler found, leaving $out at full size" >&2
    fi
}

render "$repo_root/preview_top.png" 0,0,0,55,0,25,140
render "$repo_root/preview_bottom.png" 0,0,0,235,0,205,140
