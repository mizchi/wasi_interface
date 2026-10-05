///|
test "p3 generated contracts expose fs/clock/http/socket contracts" {
  let _fs_kind = @p3.FilesystemTypesDescriptorType::Unknown
  let _clock = @p3.ClocksSystemClockInstant::{ seconds: 1L, nanoseconds: 0, }
  let _http_method = @p3.HttpTypesMethod::Get
  let _socket_error = @p3.TypesErrorCode::Io
  let _fs_trait_consumer : (&@p3.WasiFilesystemTypesAdapter) -> Unit = fn(
    _provider,
  ) {
    ()
  }
  let _http_trait_consumer : (&@p3.WasiHttpTypesAdapter) -> Unit = fn(
    _provider,
  ) {
    ()
  }
  let _socket_trait_consumer : (&@p3.WasiTypesAdapter) -> Unit = fn(_provider) {
    ()
  }
  assert_true(true)
}
