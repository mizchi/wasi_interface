///|
fn print_usage() -> Unit {
  println("Usage: wasi-interface-gen <output-dir> <wit-path> [wit-path ...]")
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
fn output_dir_profile(output_dir : String) -> String? {
  let segments = output_dir.split("/")
  let mut last = ""
  for segment in segments {
    if segment == "" || segment == "." {
      continue
    }
    last = segment.to_string()
  }
  if last == "" {
    None
  } else {
    Some(last)
  }
}

///|
fn contract_reference_line_for_output_dir(output_dir : String) -> String? {
  match output_dir_profile(output_dir) {
    Some(profile) =>
      if profile == "p1" {
        Some(
          "///| Contract reference: WASIp1 preview1 (`wasi_snapshot_preview1`) from `wit/p1/wasi_snapshot_preview1.wit`.\n",
        )
      } else if profile == "p2" {
        Some(
          "///| Contract reference: WASIp2 (`wasi:*@0.2.9`) from `mizchi/wasi.mbt/wit/deps/wasi-*-0.2.9/package.wit`.\n",
        )
      } else if profile == "p3" {
        Some(
          "///| Contract reference: WASIp3 draft (`wasi:*@0.3.0-draft`) from `WebAssembly/WASI/proposals/*/wit-0.3.0-draft`.\n",
        )
      } else {
        None
      }
    None => None
  }
}

///|
fn annotate_generated_module_code(output_dir : String, code : String) -> String {
  match contract_reference_line_for_output_dir(output_dir) {
    Some(reference_line) => reference_line + code
    None => code
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
        let annotated_code = annotate_generated_module_code(
          output_dir,
          generated_module.code,
        )
        @fs.write_string_to_file(output_path, annotated_code) catch {
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
