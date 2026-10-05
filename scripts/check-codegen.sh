#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
root="$PWD"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Exercise argument handling and file IO for every supported backend.
for target in wasm wasm-gc js native; do
  out="$work/$target"
  mkdir -p "$out"
  moon -C tools/codegen run src/codegen/main --target "$target" -- \
    "$out/p1" "$root/wit/p1/wasi_snapshot_preview1.wit"
  printf 'name = "mizchi/wasi_interface"\n' > "$out/moon.mod"
  printf '\n' > "$out/p1/moon.pkg"
  moon -C "$out" check --deny-warn --target all
  moon -C "$out" fmt
  diff -u src/p1/gen_preview1_wasi_snapshot_preview1.mbt \
    "$out/p1/gen_preview1_wasi_snapshot_preview1.mbt"
  diff -u src/p1/gen_wasi_error.mbt "$out/p1/gen_wasi_error.mbt"
done
