///|
test "p3 generated contracts expose fs/clock/http/socket contracts" {
  let _fs_kind = FilesystemTypesDescriptorType::Unknown
  let _clock = ClocksSystemClockInstant::{ seconds: 1L, nanoseconds: 0 }
  let _http_method = HttpTypesMethod::Get
  let _socket_error = TypesErrorCode::Io
  let _fs_trait_consumer : (&WasiFilesystemTypesAdapter) -> Unit = fn(
    _provider,
  ) {
    ()
  }
  let _http_trait_consumer : (&WasiHttpTypesAdapter) -> Unit = fn(_provider) {
    ()
  }
  let _socket_trait_consumer : (&WasiTypesAdapter) -> Unit = fn(_provider) {
    ()
  }
  assert_true(true)
}
