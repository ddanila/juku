#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

openscad-nightly \
    -o "$repo_root/keycap/juku-keycap.stl" \
    --export-format binstl \
    "$repo_root/keycap/juku-keycap.scad"

openscad-nightly \
    -o "$repo_root/bottom-case/juku-bottom-case.stl" \
    --export-format binstl \
    "$repo_root/bottom-case/juku-bottom-case.scad"
