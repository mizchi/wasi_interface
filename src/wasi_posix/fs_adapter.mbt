///|
/// FileSystemBackend adapter over `WasiFsProvider` contract.
pub struct WasiFs {
  provider : &WasiFsProvider
}

///|
pub fn WasiFs::new(provider : &WasiFsProvider) -> WasiFs {
  { provider, }
}

///|
fn node_type_to_file_type(t : WasiNodeType) -> @fs.FileType {
  match t {
    File => @fs.FileType::File
    Directory => @fs.FileType::Directory
    Symlink => @fs.FileType::Symlink
    Other => @fs.FileType::File
  }
}

///|
fn bytes_to_string(data : Bytes) -> String {
  let buf = StringBuilder::new()
  for byte in data {
    buf.write_char(byte.to_int().unsafe_to_char())
  }
  buf.to_string()
}

///|
fn string_to_bytes(s : String) -> Bytes {
  Bytes::makei(s.length(), fn(i) { s[i].to_int().to_byte() })
}

///|
fn rm_rf_provider(
  provider : &WasiFsProvider,
  path : String,
) -> Unit raise @fs.FsError {
  if not(provider.exists(path)) {
    return
  }
  let s = provider.stat(path)
  if s.node_type == Directory {
    let entries = provider.readdir(path)
    for entry in entries {
      let child = if path == "/" {
        "/" + entry.name
      } else {
        path + "/" + entry.name
      }
      rm_rf_provider(provider, child)
    }
    if path != "/" {
      provider.rmdir(path)
    }
  } else {
    provider.remove(path)
  }
}

///|
pub impl @fs.FileSystemBackend for WasiFs with read_file(self, path) {
  self.provider.read_file(path)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with read_string(self, path) {
  let data = self.provider.read_file(path)
  bytes_to_string(data)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with exists(self, path) {
  self.provider.exists(path)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with is_file(self, path) {
  let st = self.provider.stat(path) catch { _ => return false }
  st.node_type == File
}

///|
pub impl @fs.FileSystemBackend for WasiFs with is_dir(self, path) {
  let st = self.provider.stat(path) catch { _ => return false }
  st.node_type == Directory
}

///|
pub impl @fs.FileSystemBackend for WasiFs with stat(self, path) {
  let s = self.provider.stat(path)
  { file_type: node_type_to_file_type(s.node_type), size: s.size }
}

///|
pub impl @fs.FileSystemBackend for WasiFs with readdir(self, path) {
  self.provider
  .readdir(path)
  .map(fn(entry) {
    { name: entry.name, file_type: node_type_to_file_type(entry.node_type) }
  })
}

///|
pub impl @fs.FileSystemBackend for WasiFs with write_file(self, path, data) {
  self.provider.write_file(path, data)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with write_string(self, path, content) {
  self.provider.write_file(path, string_to_bytes(content))
}

///|
pub impl @fs.FileSystemBackend for WasiFs with mkdir(self, path) {
  self.provider.mkdir(path)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with mkdir_p(self, path) {
  self.provider.mkdir_p(path)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with remove(self, path) {
  self.provider.remove(path)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with rmdir(self, path) {
  self.provider.rmdir(path)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with rename(self, old_path, new_path) {
  self.provider.rename(old_path, new_path)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with copy_file(self, src, dst) {
  let data = self.provider.read_file(src)
  self.provider.write_file(dst, data)
}

///|
pub impl @fs.FileSystemBackend for WasiFs with rm_rf(self, path) {
  rm_rf_provider(self.provider, path)
}
