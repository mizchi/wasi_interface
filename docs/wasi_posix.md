# wasi_posix layering

`@wasi_posix` separates moonix core contracts (`@fs`, `@posix`) from WASI preview-specific details.

## Layering

1. `WasiFsProvider` / `WasiCliProvider` (`src/wasi_posix/contracts.mbt`)
2. `WasiFs` / `WasiStreamHandler` adapters (`src/wasi_posix/fs_adapter.mbt`, `src/wasi_posix/cli_adapter.mbt`)
3. Preview-specific namespaces
   - p2: `src/p2/wasi_posix/` (preview2 provider implementations and constructors)
   - p3: `src/p3/wasi_posix/` (scaffolded)

## Why this boundary

WASI preview2 and preview3 differ in low-level API shape.

- Filesystem
  - p2: direct read/write and mostly sync calls
  - p3 draft (`wasi:filesystem@0.3.0-rc-2026-02-05`): expanded descriptor flags/stat metadata and ongoing 0.3 stream/future alignment
- CLI stdio
  - p2: `get-stdin/get-stdout/get-stderr` + `wasi:io/streams`
  - p3 draft (`wasi:cli@0.3.0-rc-2026-02-05`): world-level imports reorganized under 0.3 package set
- Clocks used by filesystem metadata
  - p2 uses `wasi:clocks/wall-clock`
  - p3 draft references `wasi:clocks/system-clock`

The contract layer keeps these changes local to provider implementations.

## Preview3 migration plan

1. Implement `WasiPreview3FsProvider` / `WasiPreview3CliProvider` with `WasiFsProvider` / `WasiCliProvider`.
2. Expose p3 factory functions parallel to `src/p2/wasi_posix/factory.mbt`.
3. Switch call sites by namespace (`@p2/wasi_posix` -> `@p3/wasi_posix`) without changing shared adapters.
