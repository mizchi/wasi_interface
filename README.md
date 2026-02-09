# wasi_posix

WASI preview-aware provider implementations and adapter contracts for `moonix` POSIX abstractions.

## Packages

- `@wasi_posix`
  - Preview-agnostic contract layer (`WasiFsProvider`, `WasiCliProvider`)
  - Adapter implementations (`WasiFs`, `WasiStreamHandler`)
- `@p2/wasi_posix`
  - WASI preview2 provider implementations and factories
- `@p3/wasi_posix`
  - Preview3 scaffold namespace (targeting `wasi:*@0.3.x` drafts)

## Dependency Direction

This module depends on:

- `mizchi/moonix` (`@fs`, `@posix` contracts)
- `mizchi/wasi` (generated WASI bindings)

`moonix` can keep core filesystem/process contracts while WASI host details evolve in this module.

## Quick Commands

```bash
just        # check + test (wasm-gc)
just check  # moon check --deny-warn --target wasm-gc
just test   # moon test --target wasm-gc
```

## Design Notes

- Layering details: `docs/wasi_posix.md`
- Current p3 references are aligned with WIT draft packages under `wasi:*@0.3.0-rc-2026-02-05`
