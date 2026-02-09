# MoonBit Project Commands

# Default target (WASI host bindings)
target := "wasm-gc"
p2_wit_root := "/Users/mz/ghq/github.com/mizchi/wasi.mbt/wit/deps"
p3_wit_root := "/Users/mz/ghq/github.com/WebAssembly/WASI/proposals"

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

# Generate p2 modules (wasi:*@0.2.9)
gen-p2:
    moon run src/codegen/main -- src/p2 \
      {{p2_wit_root}}/wasi-cli-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-clocks-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-filesystem-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-http-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-io-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-random-0.2.9/package.wit \
      {{p2_wit_root}}/wasi-sockets-0.2.9/package.wit

# Generate p3 modules (wasi:*@0.3.0 draft set)
gen-p3:
    moon run src/codegen/main -- src/p3 \
      {{p3_wit_root}}/cli/wit-0.3.0-draft \
      {{p3_wit_root}}/clocks/wit-0.3.0-draft \
      {{p3_wit_root}}/filesystem/wit-0.3.0-draft \
      {{p3_wit_root}}/http/wit-0.3.0-draft \
      {{p3_wit_root}}/random/wit-0.3.0-draft \
      {{p3_wit_root}}/sockets/wit-0.3.0-draft

# Generate both p2 and p3 modules
gen-all: gen-p2 gen-p3

# Clean build artifacts
clean:
    moon clean

# Pre-release check
release-check: fmt info check test
