///|
fn print_usage() -> Unit {
  println("Usage: wasi-posix-gen <output-dir> <wit-path> [wit-path ...]")
}

///|
fn exit_with_error(message : String) -> Unit {
  println(message)
  @sys.exit(1)
}

///|
fn join_path(dir : String, entry : String) -> String {
  if dir == "" || dir == "." {
    entry
  } else if dir.has_suffix("/") {
    dir + entry
  } else {
    dir + "/" + entry
  }
}

///|
fn ensure_output_dir(path : String) -> Unit {
  if not(@fs.path_exists(path)) {
    @fs.create_dir(path) catch {
      e => exit_with_error("create_dir failed: " + e.to_string())
    }
  }
  let is_dir = @fs.is_dir(path) catch {
    e => {
      exit_with_error("is_dir failed: " + e.to_string())
      false
    }
  }
  if not(is_dir) {
    exit_with_error("output path is not a directory: " + path)
  }
}

///|
fn clear_old_generated_files(dir : String) -> Unit {
  let entries = @fs.read_dir(dir) catch {
    e => {
      exit_with_error("read_dir failed: " + e.to_string())
      []
    }
  }
  for entry in entries {
    if not(entry.has_prefix("gen_")) || not(entry.has_suffix(".mbt")) {
      continue
    }
    let path = join_path(dir, entry)
    let is_file = @fs.is_file(path) catch { _ => false }
    if not(is_file) {
      continue
    }
    @fs.remove_file(path) catch {
      e => exit_with_error("remove_file failed: " + e.to_string())
    }
  }
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() < 3 {
    print_usage()
    exit_with_error("invalid arguments")
  }
  let output_dir = args[1]
  let wit_paths : Array[String] = []
  for i in 2..<args.length() {
    wit_paths.push(args[i])
  }
  ensure_output_dir(output_dir)
  clear_old_generated_files(output_dir)
  let generated = @codegen.generate_trait_adapter_modules_from_wit_paths(
    wit_paths,
  )
  match generated {
    Ok(modules) => {
      for generated_module in modules {
        let output_path = join_path(output_dir, generated_module.file_name)
        @fs.write_string_to_file(output_path, generated_module.code) catch {
          e => exit_with_error("write failed: " + e.to_string())
        }
        println("generated: " + output_path)
      }
      if modules.length() == 0 {
        println("warning: no module generated")
      } else {
        println("generated modules: " + modules.length().to_string())
      }
    }
    Err(err) => exit_with_error("generate failed: " + err.to_string())
  }
}
