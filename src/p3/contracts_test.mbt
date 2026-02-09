///|
struct FakeFsProvider {}

///|
fn FakeFsProvider::new() -> FakeFsProvider {
  FakeFsProvider::{  }
}

///|
pub impl WasiFsProvider for FakeFsProvider with read_file(_self, path) {
  if path == "/p3" {
    b"p3"
  } else {
    raise WasiError::NotFound(path)
  }
}

///|
pub impl WasiFsProvider for FakeFsProvider with exists(_self, path) {
  path == "/p3"
}

///|
pub impl WasiFsProvider for FakeFsProvider with stat(_self, path) {
  if path == "/p3" {
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
struct FakeCliProvider {}

///|
fn FakeCliProvider::new() -> FakeCliProvider {
  FakeCliProvider::{  }
}

///|
pub impl WasiCliProvider for FakeCliProvider with read_stdin(_self, _len) {
  b""
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
test "p3 contract: filesystem provider signatures" {
  let provider = FakeFsProvider::new()
  assert_true(provider.exists("/p3"))
  assert_eq(provider.read_file("/p3"), b"p3")
  inspect(
    try? provider.read_file("/missing"),
    content="Err(NotFound(\"/missing\"))",
  )
}

///|
test "p3 contract: cli provider signatures" {
  let cli = FakeCliProvider::new()
  assert_eq(cli.read_stdin(4), b"")
  assert_eq(cli.write_stdout(b"out"), 3)
  assert_eq(cli.write_stderr(b"err"), 3)
}
