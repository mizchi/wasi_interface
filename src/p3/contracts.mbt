///| WASI Preview3 contract package.
///|
///| This package defines only host/provider contracts.
///| Concrete injection/adapter implementations belong to another module.

///|
pub(all) suberror WasiError {
  NotFound(String)
  AlreadyExists(String)
  NotDirectory(String)
  IsDirectory(String)
  NotEmpty(String)
  Io(String)
  Unsupported(String)
} derive(Show, Eq)

///|
pub(all) enum WasiNodeType {
  File
  Directory
  Symlink
  Other
} derive(Show, Eq)

///|
pub(all) struct WasiNodeStat {
  node_type : WasiNodeType
  size : Int
} derive(Show, Eq)

///|
pub(all) struct WasiDirEntry {
  name : String
  node_type : WasiNodeType
} derive(Show, Eq)

///|
/// Filesystem contract for WASI Preview3 host integration.
pub(open) trait WasiFsProvider {
  read_file(Self, String) -> Bytes raise WasiError
  exists(Self, String) -> Bool
  stat(Self, String) -> WasiNodeStat raise WasiError
  readdir(Self, String) -> Array[WasiDirEntry] raise WasiError
  write_file(Self, String, Bytes) -> Unit raise WasiError
  mkdir(Self, String) -> Unit raise WasiError
  mkdir_p(Self, String) -> Unit raise WasiError
  remove(Self, String) -> Unit raise WasiError
  rmdir(Self, String) -> Unit raise WasiError
  rename(Self, String, String) -> Unit raise WasiError
}

///|
/// CLI stdio contract for WASI Preview3 host integration.
pub(open) trait WasiCliProvider {
  read_stdin(Self, Int) -> Bytes
  write_stdout(Self, Bytes) -> Int
  write_stderr(Self, Bytes) -> Int
}
