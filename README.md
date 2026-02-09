# wasi_posix

WASI Preview2/Preview3 contract definitions for host injection boundaries.

## Packages

- `@p2`
  - Preview2 contracts (`pub(open) trait`) and shared contract types
- `@p3`
  - Preview3 contracts (`pub(open) trait`) and shared contract types
- `@codegen`
  - WIT AST (`mizchi/wit`) から trait adapter の MoonBit コード文字列を生成する補助 API
  - `moonbitlang/parser` + `mizchi/ast_printer` で構文検証と整形を行う
  - CLI (`src/codegen/main`) から `src/p2`, `src/p3` に `gen_*.mbt` を出力可能

## Scope

This module is contract-only.

- Define contracts for WASI host integration
- Keep API/type boundary stable across implementations
- Do not include concrete injection/provider/adapter implementations

Concrete host injection should live in a separate module that depends on this one.

## Optional generation strategy

Use `wkg` + codegen when updating p2/p3 contract surfaces from upstream WIT.

Coverage tracking is maintained in `docs/coverage_checklist.md`.

## Generate Contracts

```bash
# usage: moon run src/codegen/main -- <output-dir> <wit-path> [wit-path ...]
moon run src/codegen/main -- src/p2 /path/to/p2/a.wit /path/to/p2/b.wit
moon run src/codegen/main -- src/p3 /path/to/p3/a.wit /path/to/p3/b.wit

# project presets
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
