///|
fn find_module_code(
  modules : Array[GeneratedModule],
  file_name : String,
) -> String? {
  for generated in modules {
    if generated.file_name == file_name {
      return Some(generated.code)
    }
  }
  None
}

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
  let code = match generated {
    Ok(code) => code
    Err(err) => {
      println(err.to_string())
      abort("expected generator success")
    }
  }
  assert_true(code.contains("pub(open) trait WasiSampleFilesystemAdapter"))
  assert_true(
    code.contains("read_file(Self, String) -> Result[Bytes, WasiError] = _"),
  )
  assert_true(code.contains("pub(open) trait WasiSampleClockAdapter"))
  assert_true(code.contains("now(Self) -> Result[UInt64, WasiError] = _"))
  assert_true(code.contains("pub(open) trait WasiSampleHostHttpAdapter"))
  assert_true(
    code.contains("send(Self, String, Bytes) -> Result[Bytes, WasiError] = _"),
  )
  assert_true(code.contains("pub(open) trait WasiSampleHostSocketAdapter"))
  assert_true(
    code.contains("connect(Self, String, UInt) -> Result[UInt, WasiError] = _"),
  )
  assert_true(code.contains("pub(all) suberror WasiError"))
  assert_true(code.contains("FromString(String)"))
  assert_true(code.contains("Err(WasiError::NotImplemented("))
  let (_impls, reports) = @parser.parse_string(code)
  assert_eq(reports.length(), 0)
}

///|
test "generate trait adapter modules split by interface" {
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
  let generated = generate_trait_adapter_modules_from_wit_source(source)
  guard generated is Ok(modules) else { abort("expected generator success") }
  assert_eq(modules.length(), 3)
  assert_true(find_module_code(modules, "gen_wasi_error.mbt") is Some(_))
  assert_true(find_module_code(modules, "gen_sample_filesystem.mbt") is Some(_))
  assert_true(find_module_code(modules, "gen_sample_clock.mbt") is Some(_))
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
  assert_true(
    code.contains("send_request(Self, String) -> Result[String, WasiError] = _"),
  )
  assert_true(code.contains("Err(WasiError::NotImplemented("))
}

///|
test "generate trait adapters from multiple WIT sources" {
  let filesystem_source =
    #|package wasi:filesystem;
    #|
    #|interface types {
    #|  read-file: func(path: string) -> result<list<u8>, string>;
    #|}
  let clocks_source =
    #|package wasi:clocks;
    #|
    #|interface wall-clock {
    #|  now: func() -> u64;
    #|}
  let sources : Array[String] = [filesystem_source, clocks_source]
  let generated = generate_trait_adapters_from_wit_sources(sources)
  guard generated is Ok(code) else { abort("expected generator success") }
  assert_true(code.contains("pub(open) trait WasiFilesystemTypesAdapter"))
  assert_true(code.contains("pub(open) trait WasiClocksWallClockAdapter"))
}

///|
test "generate trait adapters emit interface scoped types" {
  let source =
    #|package wasi:filesystem;
    #|
    #|interface types {
    #|  record node-stat {
    #|    size: u64,
    #|  }
    #|  get: func() -> node-stat;
    #|}
  let generated = generate_trait_adapters_from_wit_source(source)
  guard generated is Ok(code) else { abort("expected generator success") }
  assert_true(code.contains("pub(all) struct FilesystemTypesNodeStat"))
  assert_true(
    code.contains("get(Self) -> Result[FilesystemTypesNodeStat, WasiError] = _"),
  )
  assert_true(code.contains("Err(WasiError::NotImplemented("))
}

///|
test "generate trait adapters emit fallback alias for unresolved ids" {
  let source =
    #|package wasi:sample;
    #|
    #|interface api {
    #|  call: func(input: external-type) -> external-type;
    #|}
  let generated = generate_trait_adapters_from_wit_source(source)
  let code = match generated {
    Ok(code) => code
    Err(err) => {
      println(err.to_string())
      abort("expected generator success")
    }
  }
  assert_true(code.contains("pub(all) type SampleApiExternalType"))
}

///|
test "generate trait adapters emit alias for use-imported types" {
  let source =
    #|package wasi:http;
    #|
    #|interface types {
    #|  type request = string;
    #|  type response = string;
    #|  type error-code = string;
    #|}
    #|
    #|interface client {
    #|  use types.{request, response, error-code};
    #|  send: func(request: request) -> result<response, error-code>;
    #|}
  let generated = generate_trait_adapter_modules_from_wit_source(source)
  let modules = match generated {
    Ok(modules) => modules
    Err(err) => {
      println(err.to_string())
      abort("expected generator success")
    }
  }
  let client_module = match find_module_code(modules, "gen_http_client.mbt") {
    Some(code) => code
    None => abort("missing gen_http_client.mbt")
  }
  assert_true(
    client_module.contains(
      "send(Self, HttpTypesRequest) -> Result[HttpTypesResponse, WasiError] = _",
    ),
  )
  assert_true(not(client_module.contains("pub(all) type HttpClientRequest")))
  assert_true(not(client_module.contains("pub(all) type HttpClientResponse")))
  assert_true(not(client_module.contains("pub(all) type HttpClientErrorCode")))
}

///|
test "generate trait adapters reports WIT parse errors" {
  let generated = generate_trait_adapters_from_wit_source("interface broken {")
  match generated {
    Err(GenerateError::WitParse(_)) => ()
    _ => abort("expected GenerateError::WitParse")
  }
}
