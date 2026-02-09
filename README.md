# wasi_posix

WASI Preview2/Preview3 contract definitions for host injection boundaries.

## Packages

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

## Optional generation strategy

If maintaining contracts manually becomes costly, define source WIT for p2/p3 and generate contract stubs from `wkg` outputs in a dedicated generation workflow.

## Quick Commands

```bash
just        # check + test (wasm-gc)
just check  # moon check --deny-warn --target wasm-gc
just test   # moon test --target wasm-gc
```
