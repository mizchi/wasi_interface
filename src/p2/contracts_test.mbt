///|
test "p2 generated contracts expose fs/clock/http/socket contracts" {
  let _fs_kind = @p2.FilesystemTypesDescriptorType::Unknown
  let _clock = @p2.ClocksWallClockDatetime::{ seconds: 1UL, nanoseconds: 0, }
  let _http_method = @p2.HttpTypesMethod::Get
  let _socket_error = @p2.SocketsNetworkErrorCode::Unknown
  let _fs_trait_consumer : (&@p2.WasiFilesystemTypesAdapter) -> Unit = fn(
    _provider,
  ) {
    ()
  }
  let _http_trait_consumer : (&@p2.WasiHttpTypesAdapter) -> Unit = fn(
    _provider,
  ) {
    ()
  }
  let _socket_trait_consumer : (&@p2.WasiSocketsTcpAdapter) -> Unit = fn(
    _provider,
  ) {
    ()
  }
  assert_true(true)
}
