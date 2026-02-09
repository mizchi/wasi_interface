# wasi_posix contract policy

`mizchi/wasi_posix` is a contract-only module for WASI preview boundaries.

## Layering

1. Contract layer (`src/p1`, `src/p2`, `src/p3`)
2. Concrete implementation layer (separate module)
3. Injection/adapter composition (separate module)

## Rules

- `src/p1`, `src/p2`, and `src/p3` expose only `pub(open) trait` and contract data types
- trait methods return `Result[..., WasiError]` and default to `Err(WasiError::NotImplemented(...))`
- No provider implementation, no adapter implementation, no runtime injection logic
- Consumers implement these traits and compose with their own runtime adapters

## Notes on p3

`src/p3` is generated from `WebAssembly/WASI/proposals/*/wit-0.3.0-draft`.
`src/p1` is generated from `wit/p1/wasi_snapshot_preview1.wit` as a compatibility scaffold.
`src/p1`, `src/p2`, and `src/p3` are managed independently as contract namespaces (`gen_*.mbt` per interface).

Coverage and remaining gaps are tracked in `docs/coverage_checklist.md`.

## Optional workflow with `wkg`

When needed, use `wkg` to fetch p2/p3 WIT definitions and generate/update contract scaffolding, then keep this repository as the reviewed contract surface.
