///|
/// StdStreamHandler adapter over `WasiCliProvider` contract.
pub struct WasiStreamHandler {
  provider : &WasiCliProvider
}

///|
pub fn WasiStreamHandler::new(provider : &WasiCliProvider) -> WasiStreamHandler {
  { provider, }
}

///|
pub impl @posix.StdStreamHandler for WasiStreamHandler with read(
  self,
  stream,
  len,
) {
  match stream {
    @posix.Stdin => self.provider.read_stdin(len)
    @posix.Stdout | @posix.Stderr => b""
  }
}

///|
pub impl @posix.StdStreamHandler for WasiStreamHandler with write(
  self,
  stream,
  data,
) {
  match stream {
    @posix.Stdout => self.provider.write_stdout(data)
    @posix.Stderr => self.provider.write_stderr(data)
    @posix.Stdin => 0
  }
}
