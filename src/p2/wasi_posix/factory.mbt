///|
/// Preview2 constructors for shared `@wasi_posix` adapters.
pub fn new_fs(root : @wasi_fs.Descriptor) -> @wasi_posix_core.WasiFs {
  let provider = WasiPreview2FsProvider::new(root)
  @wasi_posix_core.WasiFs::new(provider)
}

///|
pub fn new_stream_handler() -> @wasi_posix_core.WasiStreamHandler {
  let provider = WasiPreview2CliProvider::new()
  @wasi_posix_core.WasiStreamHandler::new(provider)
}
