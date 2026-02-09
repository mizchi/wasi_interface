# wasi_posix

WASI Preview2/Preview3 contract definitions for host injection boundaries.

## Packages

- `@p1`
  - Preview1 compatibility contracts generated from local WIT scaffold
- `@p2`
  - Preview2 contracts (`pub(open) trait`) and shared contract types
- `@p3`
  - Preview3 contracts (`pub(open) trait`) and shared contract types

## Scope

This module is contract-only.

- Define contracts for WASI host integration
- Keep API/type boundary stable across implementations
- Do not include concrete injection/provider/adapter implementations

Concrete host injection should live in a separate module that depends on this one.
Code generation tooling is split into `tools/codegen` and excluded from this module's published source bundle.
Preview1 is currently generated from `wit/p1/wasi_snapshot_preview1.wit` (WITX direct parse is out of scope).

## Default Error Contract

Each package (`@p1`, `@p2`, `@p3`) defines:

- `suberror WasiError { NotImplemented(String), CapabilityDenied(String) }`

Generated trait methods return `Result[<WIT-return>, WasiError]` and are marked `= _`.
Default implementations return `Err(WasiError::NotImplemented(...))`.

## Optional generation strategy

Use `wkg` + codegen when updating p2/p3 contract surfaces from upstream WIT.

Coverage tracking is maintained in `docs/coverage_checklist.md`.

## Generate Contracts

```bash
# usage: moon -C tools/codegen run src/codegen/main -- <output-dir> <wit-path> [wit-path ...]
moon -C tools/codegen run src/codegen/main -- src/p1 wit/p1/wasi_snapshot_preview1.wit
moon -C tools/codegen run src/codegen/main -- src/p2 /path/to/p2/a.wit /path/to/p2/b.wit
moon -C tools/codegen run src/codegen/main -- src/p3 /path/to/p3/a.wit /path/to/p3/b.wit

# project presets
just gen-p1
just gen-p2
just gen-p3
just gen-all
```

## Quick Commands

```bash
just        # check + test (wasm-gc)
just check  # moon check --deny-warn --target wasm-gc
just test   # moon test --target wasm-gc
```
