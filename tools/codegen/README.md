# wasi_interface codegen

Helper module to regenerate `wasi_interface` contract code (`src/p1`, `src/p2`, `src/p3`) from WIT.

- Run: `moon -C tools/codegen run src/codegen/main -- <output-dir> <wit-path> [wit-path ...]`
- Dependencies: `mizchi/wit`, `moonbitlang/parser`

Generated traits follow these rules:

- Return type: `Result[<WIT-return>, WasiError]`
- Default implementation: `Err(WasiError::NotImplemented(...))`

This module is generation-only and is excluded from the published API bundle of `mizchi/wasi_interface`.
