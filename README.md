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
  - このモジュール内ではファイル生成を実行しない（生成実行は別ワークフロー）

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
