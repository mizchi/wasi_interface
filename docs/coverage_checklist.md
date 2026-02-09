# WASI Contract Coverage Checklist

Last updated: 2026-02-09

This file tracks generated contract modules in `src/p2/gen_*.mbt` and `src/p3/gen_*.mbt`.

Status:

- `Done`: module is generated and reviewed as expected
- `Partial`: module is generated, but parser fallback currently drops part of the WIT surface

## p2 (`wasi:*@0.2.9`)

| Domain | Interface | Status | Module |
|---|---|---|---|
| cli | `wasi:cli/environment` | Done | `gen_cli_environment.mbt` |
| cli | `wasi:cli/exit` | Done | `gen_cli_exit.mbt` |
| cli | `wasi:cli/run` | Done | `gen_cli_run.mbt` |
| cli | `wasi:cli/stdin` | Done | `gen_cli_stdin.mbt` |
| cli | `wasi:cli/stdout` | Done | `gen_cli_stdout.mbt` |
| cli | `wasi:cli/stderr` | Done | `gen_cli_stderr.mbt` |
| cli | `wasi:cli/terminal-input` | Done | `gen_cli_terminal_input.mbt` |
| cli | `wasi:cli/terminal-output` | Done | `gen_cli_terminal_output.mbt` |
| cli | `wasi:cli/terminal-stdin` | Done | `gen_cli_terminal_stdin.mbt` |
| cli | `wasi:cli/terminal-stdout` | Done | `gen_cli_terminal_stdout.mbt` |
| cli | `wasi:cli/terminal-stderr` | Done | `gen_cli_terminal_stderr.mbt` |
| clocks | `wasi:clocks/monotonic-clock` | Done | `gen_clocks_monotonic_clock.mbt` |
| clocks | `wasi:clocks/wall-clock` | Done | `gen_clocks_wall_clock.mbt` |
| clocks | `wasi:clocks/timezone` | Done | `gen_clocks_timezone.mbt` |
| filesystem | `wasi:filesystem/types` | Partial | `gen_filesystem_types.mbt` |
| filesystem | `wasi:filesystem/preopens` | Done | `gen_filesystem_preopens.mbt` |
| http | `wasi:http/types` | Partial | `gen_http_types.mbt` |
| http | `wasi:http/incoming-handler` | Done | `gen_http_incoming_handler.mbt` |
| http | `wasi:http/outgoing-handler` | Done | `gen_http_outgoing_handler.mbt` |
| io | `wasi:io/error` | Done | `gen_io_error.mbt` |
| io | `wasi:io/poll` | Done | `gen_io_poll.mbt` |
| io | `wasi:io/streams` | Done | `gen_io_streams.mbt` |
| random | `wasi:random/random` | Done | `gen_random_random.mbt` |
| random | `wasi:random/insecure` | Done | `gen_random_insecure.mbt` |
| random | `wasi:random/insecure-seed` | Done | `gen_random_insecure_seed.mbt` |
| sockets | `wasi:sockets/network` | Done | `gen_sockets_network.mbt` |
| sockets | `wasi:sockets/instance-network` | Done | `gen_sockets_instance_network.mbt` |
| sockets | `wasi:sockets/udp` | Done | `gen_sockets_udp.mbt` |
| sockets | `wasi:sockets/udp-create-socket` | Done | `gen_sockets_udp_create_socket.mbt` |
| sockets | `wasi:sockets/tcp` | Done | `gen_sockets_tcp.mbt` |
| sockets | `wasi:sockets/tcp-create-socket` | Done | `gen_sockets_tcp_create_socket.mbt` |
| sockets | `wasi:sockets/ip-name-lookup` | Done | `gen_sockets_ip_name_lookup.mbt` |

## p3 (`WebAssembly/WASI/proposals/*/wit-0.3.0-draft`)

| Domain | Interface | Status | Module |
|---|---|---|---|
| cli | `wasi:cli/run` | Done | `gen_run.mbt` |
| cli | `wasi:cli/exit` | Done | `gen_exit.mbt` |
| cli | `wasi:cli/stdin` | Done | `gen_stdin.mbt` |
| cli | `wasi:cli/stdout` | Done | `gen_stdout.mbt` |
| cli | `wasi:cli/stderr` | Done | `gen_stderr.mbt` |
| cli | `wasi:cli/terminal-input` | Done | `gen_terminal_input.mbt` |
| cli | `wasi:cli/terminal-output` | Done | `gen_terminal_output.mbt` |
| cli | `wasi:cli/terminal-stdin` | Done | `gen_terminal_stdin.mbt` |
| cli | `wasi:cli/terminal-stdout` | Done | `gen_terminal_stdout.mbt` |
| cli | `wasi:cli/terminal-stderr` | Done | `gen_terminal_stderr.mbt` |
| cli | `wasi:cli/environment` | Done | `gen_environment.mbt` |
| clocks | `wasi:clocks/types` | Done | `gen_clocks_types.mbt` |
| clocks | `wasi:clocks/system-clock` | Done | `gen_clocks_system_clock.mbt` |
| clocks | `wasi:clocks/monotonic-clock` | Done | `gen_clocks_monotonic_clock.mbt` |
| clocks | `wasi:clocks/timezone` | Done | `gen_clocks_timezone.mbt` |
| filesystem | `wasi:filesystem/types` | Partial | `gen_filesystem_types.mbt` |
| filesystem | `wasi:filesystem/preopens` | Done | `gen_filesystem_preopens.mbt` |
| http | `wasi:http/types` | Partial | `gen_http_types.mbt` |
| http | `wasi:http/handler` | Done | `gen_http_handler.mbt` |
| http | `wasi:http/client` | Done | `gen_http_client.mbt` |
| random | `wasi:random/random` | Done | `gen_random_random.mbt` |
| random | `wasi:random/insecure` | Done | `gen_random_insecure.mbt` |
| random | `wasi:random/insecure-seed` | Done | `gen_random_insecure_seed.mbt` |
| sockets | `wasi:sockets/types` | Partial | `gen_types.mbt` |
| sockets | `wasi:sockets/ip-name-lookup` | Partial | `gen_ip_name_lookup.mbt` |

## Known partial points

| Area | Reason |
|---|---|
| `p2/filesystem/types`, `p3/filesystem/types` | escaped identifiers such as `%flags` / `%type` are currently sanitized out in fallback parsing |
| `p2/http/types`, `p3/http/types` | some static/resource constructor style entries are dropped by current parser fallback |
| `p3/sockets/types`, `p3/sockets/ip-name-lookup` | draft syntax still causes method drops and empty-trait fallbacks in parts of the surface |

## Next checkpoints

- [ ] Reduce sanitize-based drops by extending parser compatibility in `src/codegen/generator.mbt`
- [ ] Add snapshot checks for trait/method counts to detect generation regressions
- [ ] Re-run `just gen-all` when upstream WIT drafts are updated
