# MoonBit Project Commands

# Default target (WASI host bindings)
target := "wasm-gc"
p2_wit_root := "/Users/mz/ghq/github.com/mizchi/wasi.mbt/wit/deps"
p3_wit_root := "/Users/mz/ghq/github.com/WebAssembly/WASI/proposals"
p1_wit_path := "/Users/mz/ghq/github.com/mizchi/wasi_posix/wit/p1/wasi_snapshot_preview1.wit"
codegen_dir := "tools/codegen"

# Default task: check and test
default: check test

# Format code
fmt:
    moon fmt

# Type check
check:
    moon check --deny-warn --target {{target}}

# Run tests
test:
    moon test --target {{target}}

# Update snapshot tests
test-update:
    moon test --update --target {{target}}

# Generate type definition files
info:
    moon info

# Generate type definition files for codegen module
codegen-info:
    moon -C {{codegen_dir}} info

# Generate p1 compatibility module (wasi_snapshot_preview1 scaffold)
gen-p1:
    moon -C {{codegen_dir}} run src/codegen/main -- src/p1 \
      {{p1_wit_path}}

# Generate p2 modules (wasi:*@0.2.9)
gen-p2:
    moon -C {{codegen_dir}} run src/codegen/main -- src/p2 \
      {{p2_wit_root}}/wasi-cli-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-clocks-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-filesystem-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-http-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-io-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-random-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-sockets-0.2.9/package.wit

# Generate p3 modules (wasi:*@0.3.0 draft set)
gen-p3:
    moon -C {{codegen_dir}} run src/codegen/main -- src/p3 \
      {{p3_wit_root}}/cli/wit-0.3.0-draft \
      {{p3_wit_root}}/clocks/wit-0.3.0-draft \
      {{p3_wit_root}}/filesystem/wit-0.3.0-draft \
      {{p3_wit_root}}/http/wit-0.3.0-draft \
      {{p3_wit_root}}/random/wit-0.3.0-draft \
      {{p3_wit_root}}/sockets/wit-0.3.0-draft

# Generate all p1/p2/p3 modules
gen-all: gen-p1 gen-p2 gen-p3

# Build generated contracts and refresh all public interfaces
build: gen-all info codegen-info

# Check/test the standalone codegen module
codegen-release-check:
    moon -C {{codegen_dir}} fmt
    moon -C {{codegen_dir}} info
    moon -C {{codegen_dir}} check --deny-warn --target {{target}}
    moon -C {{codegen_dir}} test --target {{target}}

# Clean build artifacts
clean:
    moon clean

# Pre-release check
release-check: fmt info check test codegen-release-check
