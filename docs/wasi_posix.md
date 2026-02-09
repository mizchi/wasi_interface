# wasi_posix contract policy

`mizchi/wasi_posix` is a contract-only module for WASI preview boundaries.

## Layering

1. Contract layer (`src/p2`, `src/p3`)
2. Concrete implementation layer (separate module)
3. Injection/adapter composition (separate module)

## Rules

- `src/p2` and `src/p3` expose only `pub(open) trait` and contract data types
- No provider implementation, no adapter implementation, no runtime injection logic
- Consumers implement these traits and compose with their own runtime adapters

## Notes on p3

Current p3 contracts intentionally mirror p2 for migration ease.
As `wasi:*@0.3.x` stabilizes, update p3 contracts first and migrate implementations independently.

## Optional workflow with `wkg`

When needed, use `wkg` to fetch p2/p3 WIT definitions and generate/update contract scaffolding, then keep this repository as the reviewed contract surface.
