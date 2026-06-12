#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scad_file="$repo_root/juku_bottom_case.scad"

exec openscad-nightly "$scad_file"
