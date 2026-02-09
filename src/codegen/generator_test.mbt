///|
test "generate trait adapters from WIT source for fs/clock/http/socket" {
  let source =
    #|package wasi:sample;
    #|
    #|interface filesystem {
    #|  read-file: func(path: string) -> result<list<u8>, string>;
    #|}
    #|
    #|interface clock {
    #|  now: func() -> u64;
    #|}
    #|
    #|world host {
    #|  import http: interface {
    #|    send: func(url: string, body: list<u8>) -> result<list<u8>, string>;
    #|  }
    #|  import socket: interface {
    #|    connect: func(addr: string, port: u16) -> result<u32, string>;
    #|  }
    #|}
  let generated = generate_trait_adapters_from_wit_source(source)
  guard generated is Ok(code) else { abort("expected generator success") }
  assert_true(code.contains("pub(open) trait WasiFilesystemAdapter"))
  assert_true(code.contains("read_file(Self, String) -> Result[Bytes, String]"))
  assert_true(code.contains("pub(open) trait WasiClockAdapter"))
  assert_true(code.contains("now(Self) -> UInt64"))
  assert_true(code.contains("pub(open) trait WasiHttpAdapter"))
  assert_true(
    code.contains("send(Self, String, Bytes) -> Result[Bytes, String]"),
  )
  assert_true(code.contains("pub(open) trait WasiSocketAdapter"))
  assert_true(
    code.contains("connect(Self, String, UInt) -> Result[UInt, String]"),
  )
  let (_impls, reports) = @parser.parse_string(code)
  assert_eq(reports.length(), 0)
}

///|
test "generate trait adapters keeps identifier conversion stable" {
  let source =
    #|interface http-handler {
    #|  send-request: func(target-url: string) -> string;
    #|}
  let generated = generate_trait_adapters_from_wit_source(source)
  guard generated is Ok(code) else { abort("expected generator success") }
  assert_true(code.contains("pub(open) trait WasiHttpHandlerAdapter"))
  assert_true(code.contains("send_request(Self, String) -> String"))
}

///|
test "generate trait adapters reports WIT parse errors" {
  let generated = generate_trait_adapters_from_wit_source("interface broken {")
  match generated {
    Err(GenerateError::WitParse(_)) => ()
    _ => abort("expected GenerateError::WitParse")
  }
}
