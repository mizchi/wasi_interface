///|
test "p1 generated contracts expose preview1 core contracts" {
  let _trait_consumer : (&@p1.WasiPreview1WasiSnapshotPreview1Adapter) -> Unit = fn(
    _provider,
  ) {
    ()
  }
  let _fd_consumer : (@p1.Preview1WasiSnapshotPreview1Fd) -> Unit = fn(_fd) {
    ignore(_fd)
  }
  let _errno_consumer : (@p1.Preview1WasiSnapshotPreview1Errno) -> Unit = fn(
    _errno,
  ) {
    ignore(_errno)
  }
  assert_true(true)
}
