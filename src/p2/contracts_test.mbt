///|
struct FakeFsProvider {}

///|
fn FakeFsProvider::new() -> FakeFsProvider {
  FakeFsProvider::{  }
}

///|
pub impl WasiFsProvider for FakeFsProvider with read_file(_self, path) {
  if path == "/ok" {
    b"ok"
  } else {
    raise WasiError::NotFound(path)
  }
}

///|
pub impl WasiFsProvider for FakeFsProvider with exists(_self, path) {
  path == "/ok"
}

///|
pub impl WasiFsProvider for FakeFsProvider with stat(_self, path) {
  if path == "/ok" {
    { node_type: WasiNodeType::File, size: 2 }
  } else {
    raise WasiError::NotFound(path)
  }
}

///|
pub impl WasiFsProvider for FakeFsProvider with readdir(_self, _path) {
  []
}

///|
pub impl WasiFsProvider for FakeFsProvider with write_file(_self, _path, _data) {
  ()
}

///|
pub impl WasiFsProvider for FakeFsProvider with mkdir(_self, _path) {
  ()
}

///|
pub impl WasiFsProvider for FakeFsProvider with mkdir_p(_self, _path) {
  ()
}

///|
pub impl WasiFsProvider for FakeFsProvider with remove(_self, _path) {
  ()
}

///|
pub impl WasiFsProvider for FakeFsProvider with rmdir(_self, _path) {
  ()
}

///|
pub impl WasiFsProvider for FakeFsProvider with rename(
  _self,
  _old_path,
  _new_path,
) {
  ()
}

///|
struct FakeCliProvider {
  input : Bytes
}

///|
fn FakeCliProvider::new(input : Bytes) -> FakeCliProvider {
  { input, }
}

///|
pub impl WasiCliProvider for FakeCliProvider with read_stdin(self, len) {
  let n = if len < self.input.length() { len } else { self.input.length() }
  Bytes::makei(n, fn(i) { self.input[i] })
}

///|
pub impl WasiCliProvider for FakeCliProvider with write_stdout(_self, data) {
  data.length()
}

///|
pub impl WasiCliProvider for FakeCliProvider with write_stderr(_self, data) {
  data.length()
}

///|
fn read_ok(provider : &WasiFsProvider) -> Bytes raise WasiError {
  provider.read_file("/ok")
}

///|
test "p2 contract: filesystem provider can be consumed via trait" {
  let provider = FakeFsProvider::new()
  assert_true(provider.exists("/ok"))
  assert_eq(read_ok(provider), b"ok")
  inspect(
    try? provider.read_file("/missing"),
    content="Err(NotFound(\"/missing\"))",
  )
}

///|
test "p2 contract: cli provider signatures" {
  let cli = FakeCliProvider::new(b"abc")
  assert_eq(cli.read_stdin(2), b"ab")
  assert_eq(cli.write_stdout(b"out"), 3)
  assert_eq(cli.write_stderr(b"err"), 3)
}
