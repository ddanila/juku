#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scad_file="$repo_root/juku_keycap.scad"
stl_file="$repo_root/juku_keycap.stl"

openscad-nightly -o "$stl_file" "$scad_file"
rm -f "$stl_file"
