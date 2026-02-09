# wasi_interface codegen

`wasi_interface` の契約コード（`src/p1`, `src/p2`, `src/p3`）を WIT から再生成するための補助モジュール。

- 実行: `moon -C tools/codegen run src/codegen/main -- <output-dir> <wit-path> [wit-path ...]`
- 依存: `mizchi/wit`, `moonbitlang/parser`

生成される trait は以下の方針で出力されます。

- 返り値: `Result[<WIT-return>, WasiError]`
- default 実装: `Err(WasiError::NotImplemented(...))`

このモジュールは生成専用で、`mizchi/wasi_interface` 本体の公開 API バンドルには含めません。
