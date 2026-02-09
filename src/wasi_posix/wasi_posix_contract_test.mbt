///|
struct FakeFsProvider {
  inner : @fs.MemFs
}

///|
fn FakeFsProvider::new() -> FakeFsProvider {
  { inner: @fs.MemFs::new() }
}

///|
fn to_node_type(ft : @fs.FileType) -> WasiNodeType {
  match ft {
    @fs.FileType::File => WasiNodeType::File
    @fs.FileType::Directory => WasiNodeType::Directory
    @fs.FileType::Symlink => WasiNodeType::Symlink
  }
}

///|
pub impl WasiFsProvider for FakeFsProvider with read_file(self, path) {
  @fs.FileSystemBackend::read_file(self.inner, path)
}

///|
pub impl WasiFsProvider for FakeFsProvider with exists(self, path) {
  @fs.FileSystemBackend::exists(self.inner, path)
}

///|
pub impl WasiFsProvider for FakeFsProvider with stat(self, path) {
  let s = @fs.FileSystemBackend::stat(self.inner, path)
  { node_type: to_node_type(s.file_type), size: s.size }
}

///|
pub impl WasiFsProvider for FakeFsProvider with readdir(self, path) {
  @fs.FileSystemBackend::readdir(self.inner, path).map(fn(e) {
    { name: e.name, node_type: to_node_type(e.file_type) }
  })
}

///|
pub impl WasiFsProvider for FakeFsProvider with write_file(self, path, data) {
  @fs.FileSystemBackend::write_file(self.inner, path, data)
}

///|
pub impl WasiFsProvider for FakeFsProvider with mkdir(self, path) {
  @fs.FileSystemBackend::mkdir(self.inner, path)
}

///|
pub impl WasiFsProvider for FakeFsProvider with mkdir_p(self, path) {
  @fs.FileSystemBackend::mkdir_p(self.inner, path)
}

///|
pub impl WasiFsProvider for FakeFsProvider with remove(self, path) {
  @fs.FileSystemBackend::remove(self.inner, path)
}

///|
pub impl WasiFsProvider for FakeFsProvider with rmdir(self, path) {
  @fs.FileSystemBackend::rmdir(self.inner, path)
}

///|
pub impl WasiFsProvider for FakeFsProvider with rename(self, old_path, new_path) {
  @fs.FileSystemBackend::rename(self.inner, old_path, new_path)
}

///|
test "WasiFs adapter delegates to provider contract" {
  let provider = FakeFsProvider::new()
  let fs = WasiFs::new(provider)
  @fs.FileSystemBackend::mkdir_p(fs, "/tmp/a")
  @fs.FileSystemBackend::write_string(fs, "/tmp/a/hello.txt", "hello")
  assert_true(@fs.FileSystemBackend::exists(fs, "/tmp/a/hello.txt"))
  assert_eq(@fs.FileSystemBackend::read_string(fs, "/tmp/a/hello.txt"), "hello")
  let entries = @fs.FileSystemBackend::readdir(fs, "/tmp/a")
  assert_eq(entries.length(), 1)
  assert_eq(entries[0].name, "hello.txt")
}

///|
struct FakeCliProvider {
  stdin : Bytes
  mut stdin_pos : Int
  mut stdout : Bytes
  mut stderr : Bytes
}

///|
fn FakeCliProvider::new(input : Bytes) -> FakeCliProvider {
  { stdin: input, stdin_pos: 0, stdout: b"", stderr: b"" }
}

///|
fn FakeCliProvider::stdout(self : FakeCliProvider) -> Bytes {
  self.stdout
}

///|
fn FakeCliProvider::stderr(self : FakeCliProvider) -> Bytes {
  self.stderr
}

///|
pub impl WasiCliProvider for FakeCliProvider with read_stdin(self, len) {
  let available = self.stdin.length() - self.stdin_pos
  let to_read = if len < available { len } else { available }
  if to_read <= 0 {
    return b""
  }
  let out = Bytes::makei(to_read, fn(i) { self.stdin[self.stdin_pos + i] })
  self.stdin_pos += to_read
  out
}

///|
pub impl WasiCliProvider for FakeCliProvider with write_stdout(self, data) {
  self.stdout = self.stdout + data
  data.length()
}

///|
pub impl WasiCliProvider for FakeCliProvider with write_stderr(self, data) {
  self.stderr = self.stderr + data
  data.length()
}

///|
test "WasiStreamHandler delegates to provider contract" {
  let provider = FakeCliProvider::new(b"abc")
  let streams = WasiStreamHandler::new(provider)
  let r = @posix.StdStreamHandler::read(streams, @posix.Stdin, 2)
  assert_eq(r, b"ab")
  let n1 = @posix.StdStreamHandler::write(streams, @posix.Stdout, b"out")
  let n2 = @posix.StdStreamHandler::write(streams, @posix.Stderr, b"err")
  assert_eq(n1, 3)
  assert_eq(n2, 3)
  assert_eq(provider.stdout(), b"out")
  assert_eq(provider.stderr(), b"err")
}
