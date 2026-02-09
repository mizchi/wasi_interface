///|
pub(all) suberror GenerateError {
  WitParse(String)
  GeneratedCodeParse(String)
} derive(Show, Eq)

///|
priv struct InterfaceShape {
  key : String
  prefix : String
  pkg : @wit.PackageName?
  resolved_aliases : Map[String, String]
  items : Array[@wit.InterfaceItem]
}

///|
pub(all) struct GeneratedModule {
  file_name : String
  code : String
} derive(Show, Eq)

///|
priv struct GeneratedMethod {
  method_name : String
  param_count : Int
}

///|
priv struct ErrorVariant {
  variant_name : String
  payload_type : String?
}

///|
fn parse_error_to_string(err : @wit.ParseError) -> String {
  match err {
    @wit.ParseError::Message(message, offset) =>
      message + " (offset=" + offset.to_string() + ")"
  }
}

///|
fn is_ascii_alpha(ch : Char) -> Bool {
  let code = ch.to_int()
  (code >= 65 && code <= 90) || (code >= 97 && code <= 122)
}

///|
fn is_ascii_digit(ch : Char) -> Bool {
  let code = ch.to_int()
  code >= 48 && code <= 57
}

///|
fn is_ascii_alnum(ch : Char) -> Bool {
  is_ascii_alpha(ch) || is_ascii_digit(ch)
}

///|
fn to_ascii_lower(ch : Char) -> Char {
  let code = ch.to_int()
  if code >= 65 && code <= 90 {
    (code + 32).unsafe_to_char()
  } else {
    ch
  }
}

///|
fn to_ascii_upper(ch : Char) -> Char {
  let code = ch.to_int()
  if code >= 97 && code <= 122 {
    (code - 32).unsafe_to_char()
  } else {
    ch
  }
}

///|
fn escape_keyword(name : String) -> String {
  match name {
    "type"
    | "trait"
    | "pub"
    | "struct"
    | "enum"
    | "fn"
    | "let"
    | "mut"
    | "if"
    | "else"
    | "for"
    | "while"
    | "match"
    | "return"
    | "raise" => name + "_"
    _ => name
  }
}

///|
fn to_snake_case(name : String) -> String {
  let buf = StringBuilder::new()
  let mut wrote_any = false
  let mut pending_sep = false
  for ch in name.to_array() {
    if is_ascii_alnum(ch) {
      if pending_sep && wrote_any {
        buf.write_char('_')
      }
      buf.write_char(to_ascii_lower(ch))
      wrote_any = true
      pending_sep = false
    } else {
      pending_sep = true
    }
  }
  let normalized = if wrote_any { buf.to_string() } else { "unnamed" }
  let head = normalized[0].to_int().unsafe_to_char()
  let safe = if is_ascii_digit(head) { "n_" + normalized } else { normalized }
  escape_keyword(safe)
}

///|
fn to_pascal_case(name : String) -> String {
  let buf = StringBuilder::new()
  let mut capitalize_next = true
  for ch in name.to_array() {
    if is_ascii_alnum(ch) {
      if capitalize_next {
        buf.write_char(to_ascii_upper(ch))
        capitalize_next = false
      } else {
        buf.write_char(to_ascii_lower(ch))
      }
    } else {
      capitalize_next = true
    }
  }
  let normalized = buf.to_string()
  if normalized == "" {
    "Generated"
  } else {
    let head = normalized[0].to_int().unsafe_to_char()
    if is_ascii_digit(head) {
      "N" + normalized
    } else {
      normalized
    }
  }
}

///|
fn pascal_to_snake_case(name : String) -> String {
  let buf = StringBuilder::new()
  let mut wrote_any = false
  let mut prev_was_lower_or_digit = false
  for ch in name.to_array() {
    if is_ascii_alnum(ch) {
      let code = ch.to_int()
      let is_upper = code >= 65 && code <= 90
      if is_upper && wrote_any && prev_was_lower_or_digit {
        buf.write_char('_')
      }
      buf.write_char(to_ascii_lower(ch))
      wrote_any = true
      prev_was_lower_or_digit = not(is_upper)
    } else {
      if wrote_any {
        buf.write_char('_')
      }
      prev_was_lower_or_digit = false
    }
  }
  let normalized = buf.to_string()
  if normalized == "" {
    "generated"
  } else {
    normalized
  }
}

///|
fn contains_string(items : Array[String], value : String) -> Bool {
  for item in items {
    if item == value {
      return true
    }
  }
  false
}

///|
fn push_unique_string(items : Array[String], value : String) -> Unit {
  if not(contains_string(items, value)) {
    items.push(value)
  }
}

///|
fn starts_with_keyword(line : String, keyword : String) -> Bool {
  let trimmed = line.trim()
  trimmed.has_prefix(keyword)
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
fn sort_strings(items : Array[String]) -> Unit {
  let len = items.length()
  if len < 2 {
    return
  }
  for i in 1..<len {
    let key = items[i]
    let mut j = i - 1
    while j >= 0 && items[j].compare(key) > 0 {
      items[j + 1] = items[j]
      j = j - 1
    }
    items[j + 1] = key
  }
}

///|
fn list_wit_file_paths_in_dir(
  dir : String,
) -> Result[Array[String], GenerateError] {
  let entries = @fs.read_dir(dir) catch {
    e =>
      return Err(GenerateError::WitParse("read_dir failed: " + e.to_string()))
  }
  let files : Array[String] = []
  for entry in entries {
    if entry == "deps" {
      continue
    }
    let path = join_path(dir, entry)
    let is_file = @fs.is_file(path) catch { _ => false }
    if is_file && entry.has_suffix(".wit") {
      files.push(path)
    }
  }
  sort_strings(files)
  Ok(files)
}

///|
fn sanitize_package_version(line : String) -> String {
  if not(starts_with_keyword(line, "package ")) {
    return line
  }
  let chars = line.to_array()
  let mut at_index = -1
  let mut semi_index = -1
  for i, ch in chars {
    if ch == '@' && at_index < 0 {
      at_index = i
    }
    if ch == ';' {
      semi_index = i
      break
    }
  }
  if at_index < 0 || semi_index < 0 || at_index > semi_index {
    return line
  }
  let buf = StringBuilder::new()
  for i in 0..<at_index {
    buf.write_char(chars[i])
  }
  for i in semi_index..<chars.length() {
    buf.write_char(chars[i])
  }
  buf.to_string()
}

///|
fn should_skip_line_for_parse(line : String) -> Bool {
  let trimmed = line.trim()
  if trimmed == "" {
    return false
  }
  if trimmed.has_prefix("@") || trimmed.has_prefix("use ") {
    return true
  }
  if trimmed.has_prefix("resource ") && trimmed.has_suffix(";") {
    return true
  }
  if trimmed.contains(": static func") {
    return true
  }
  if trimmed.contains("-> result;") {
    return true
  }
  for ch in line.to_array() {
    if ch == '%' {
      return true
    }
  }
  false
}

///|
fn sanitize_wit_lines(source : String) -> Array[String] {
  let lines : Array[String] = []
  for line in source.split("\n") {
    let line_text = line.to_string()
    if should_skip_line_for_parse(line_text) {
      continue
    }
    let sanitized_line = sanitize_package_version(line_text)
    lines.push(sanitized_line)
  }
  lines
}

///|
fn join_lines(lines : Array[String]) -> String {
  let buf = StringBuilder::new()
  for line in lines {
    buf.write_string(line)
    buf.write_char('\n')
  }
  buf.to_string()
}

///|
fn line_index_from_offset(lines : Array[String], offset : Int) -> Int {
  let mut acc = 0
  for i, line in lines {
    let width = line.length() + 1
    if acc + width > offset {
      return i
    }
    acc = acc + width
  }
  -1
}

///|
fn without_line(lines : Array[String], index : Int) -> Array[String] {
  let out : Array[String] = []
  for i, line in lines {
    if i != index {
      out.push(line)
    }
  }
  out
}

///|
fn adaptive_parse_sanitized_source(
  path : String,
  source : String,
) -> Result[@wit.WitFile, GenerateError] {
  let mut lines = sanitize_wit_lines(source)
  let mut attempts = 0
  while attempts < 512 {
    let sanitized = join_lines(lines)
    match @wit.parse(sanitized) {
      Ok(wit_file) => return Ok(wit_file)
      Err(@wit.ParseError::Message(message, offset)) => {
        let line_index = line_index_from_offset(lines, offset)
        if line_index < 0 || line_index >= lines.length() {
          return Err(
            GenerateError::WitParse(
              path + ": " + message + " (offset=" + offset.to_string() + ")",
            ),
          )
        }
        let trimmed = lines[line_index].trim()
        if trimmed == "}" || trimmed == "{" || trimmed == "}," {
          return Err(
            GenerateError::WitParse(
              path + ": " + message + " (offset=" + offset.to_string() + ")",
            ),
          )
        }
        lines = without_line(lines, line_index)
      }
    }
    attempts = attempts + 1
  }
  Err(GenerateError::WitParse(path + ": failed to sanitize WIT for parser"))
}

///|
fn parse_wit_file_path_with_sanitize(
  path : String,
) -> Result[@wit.WitFile, GenerateError] {
  let source = @fs.read_file_to_string(path) catch {
    e => return Err(GenerateError::WitParse("read failed: " + e.to_string()))
  }
  adaptive_parse_sanitized_source(path, source)
}

///|
fn parse_wit_dir_path_with_sanitize(
  path : String,
) -> Result[Array[@wit.WitFile], GenerateError] {
  let files = match list_wit_file_paths_in_dir(path) {
    Ok(files) => files
    Err(err) => return Err(err)
  }
  if files.length() == 0 {
    return Err(GenerateError::WitParse("no .wit files in dir: " + path))
  }
  let out : Array[@wit.WitFile] = []
  for file in files {
    match parse_wit_file_path_with_sanitize(file) {
      Ok(wit_file) => out.push(wit_file)
      Err(err) => return Err(err)
    }
  }
  Ok(out)
}

///|
fn parse_wit_files_from_sources(
  sources : Array[String],
) -> Result[Array[@wit.WitFile], GenerateError] {
  let wit_files : Array[@wit.WitFile] = []
  for source in sources {
    match @wit.parse(source) {
      Ok(wit_file) => wit_files.push(wit_file)
      Err(err) =>
        return Err(GenerateError::WitParse(parse_error_to_string(err)))
    }
  }
  Ok(wit_files)
}

///|
fn parse_wit_files_from_paths(
  paths : Array[String],
) -> Result[Array[@wit.WitFile], GenerateError] {
  let wit_files : Array[@wit.WitFile] = []
  for path in paths {
    match @wit.parse_path(path) {
      Ok(wit_file) => wit_files.push(wit_file)
      Err(err) => {
        let is_file = @fs.is_file(path) catch { _ => false }
        if is_file {
          match parse_wit_file_path_with_sanitize(path) {
            Ok(wit_file) => wit_files.push(wit_file)
            Err(sanitized_err) => return Err(sanitized_err)
          }
          continue
        }
        let is_dir = @fs.is_dir(path) catch { _ => false }
        if is_dir {
          match parse_wit_dir_path_with_sanitize(path) {
            Ok(parsed_files) =>
              for wit_file in parsed_files {
                wit_files.push(wit_file)
              }
            Err(sanitized_err) => return Err(sanitized_err)
          }
          continue
        }
        return Err(GenerateError::WitParse(parse_error_to_string(err)))
      }
    }
  }
  Ok(wit_files)
}

///|
fn scoped_type_name(prefix : String, raw_name : String) -> String {
  prefix + to_pascal_case(raw_name)
}

///|
fn resolve_type_name(
  raw_name : String,
  prefix : String,
  imported_aliases : Map[String, String],
) -> String {
  match imported_aliases.get(raw_name) {
    Some(resolved) => resolved
    None => scoped_type_name(prefix, raw_name)
  }
}

///|
fn emit_type_expr(
  ty : @wit.TypeExpr,
  prefix : String,
  imported_aliases : Map[String, String],
) -> String {
  match ty {
    @wit.TypeExpr::Bool => "Bool"
    @wit.TypeExpr::U8 => "Byte"
    @wit.TypeExpr::U16 => "UInt"
    @wit.TypeExpr::U32 => "UInt"
    @wit.TypeExpr::U64 => "UInt64"
    @wit.TypeExpr::S8 => "Int"
    @wit.TypeExpr::S16 => "Int"
    @wit.TypeExpr::S32 => "Int"
    @wit.TypeExpr::S64 => "Int64"
    @wit.TypeExpr::F32 => "Float"
    @wit.TypeExpr::F64 => "Double"
    @wit.TypeExpr::Char => "Char"
    @wit.TypeExpr::String_ => "String"
    @wit.TypeExpr::Id(name) => resolve_type_name(name, prefix, imported_aliases)
    @wit.TypeExpr::Own(name) =>
      resolve_type_name(name, prefix, imported_aliases)
    @wit.TypeExpr::Borrow(name) =>
      resolve_type_name(name, prefix, imported_aliases)
    @wit.TypeExpr::List(inner) =>
      match inner {
        @wit.TypeExpr::U8 => "Bytes"
        _ => "Array[" + emit_type_expr(inner, prefix, imported_aliases) + "]"
      }
    @wit.TypeExpr::Option(inner) =>
      emit_type_expr(inner, prefix, imported_aliases) + "?"
    @wit.TypeExpr::Future(inner) =>
      emit_type_expr(inner, prefix, imported_aliases)
    @wit.TypeExpr::Stream(inner) =>
      match inner {
        @wit.TypeExpr::U8 => "Bytes"
        _ => "Array[" + emit_type_expr(inner, prefix, imported_aliases) + "]"
      }
    @wit.TypeExpr::Result(ok, err) => {
      let err_type = match err {
        Some(err_ty) => emit_type_expr(err_ty, prefix, imported_aliases)
        None => "Unit"
      }
      "Result[" +
      emit_type_expr(ok, prefix, imported_aliases) +
      ", " +
      err_type +
      "]"
    }
    @wit.TypeExpr::Tuple(items) =>
      if items.length() == 0 {
        "Unit"
      } else if items.length() == 1 {
        emit_type_expr(items[0], prefix, imported_aliases)
      } else {
        "Bytes"
      }
  }
}

///|
fn emit_result_type(
  result_ty : @wit.TypeExpr?,
  prefix : String,
  imported_aliases : Map[String, String],
) -> String {
  match result_ty {
    Some(ty) => emit_type_expr(ty, prefix, imported_aliases)
    None => "Unit"
  }
}

///|
fn emit_contract_result_type(
  result_ty : @wit.TypeExpr?,
  prefix : String,
  imported_aliases : Map[String, String],
) -> String {
  match result_ty {
    Some(@wit.TypeExpr::Result(ok_ty, _)) =>
      "Result[" +
      emit_type_expr(ok_ty, prefix, imported_aliases) +
      ", WasiError]"
    _ =>
      "Result[" +
      emit_result_type(result_ty, prefix, imported_aliases) +
      ", WasiError]"
  }
}

///|
fn collect_type_refs_from_type_expr(
  ty : @wit.TypeExpr,
  refs : Array[String],
  prefix : String,
  imported_aliases : Map[String, String],
) -> Unit {
  match ty {
    @wit.TypeExpr::Id(name)
    | @wit.TypeExpr::Own(name)
    | @wit.TypeExpr::Borrow(name) =>
      push_unique_string(
        refs,
        resolve_type_name(name, prefix, imported_aliases),
      )
    @wit.TypeExpr::List(inner)
    | @wit.TypeExpr::Option(inner)
    | @wit.TypeExpr::Future(inner)
    | @wit.TypeExpr::Stream(inner) =>
      collect_type_refs_from_type_expr(inner, refs, prefix, imported_aliases)
    @wit.TypeExpr::Result(ok, err) => {
      collect_type_refs_from_type_expr(ok, refs, prefix, imported_aliases)
      match err {
        Some(err_ty) =>
          collect_type_refs_from_type_expr(
            err_ty, refs, prefix, imported_aliases,
          )
        None => ()
      }
    }
    @wit.TypeExpr::Tuple(items) =>
      for item in items {
        collect_type_refs_from_type_expr(item, refs, prefix, imported_aliases)
      }
    _ => ()
  }
}

///|
fn collect_type_refs_from_function(
  func : @wit.Function,
  refs : Array[String],
  prefix : String,
  imported_aliases : Map[String, String],
) -> Unit {
  for param in func.params {
    collect_type_refs_from_type_expr(param.ty, refs, prefix, imported_aliases)
  }
  match func.result {
    Some(result_ty) =>
      collect_type_refs_from_type_expr(
        result_ty, refs, prefix, imported_aliases,
      )
    None => ()
  }
}

///|
fn collect_type_refs_from_typedef_kind(
  kind : @wit.TypeDefKind,
  refs : Array[String],
  prefix : String,
  imported_aliases : Map[String, String],
) -> Unit {
  match kind {
    @wit.TypeDefKind::Record(fields) =>
      for field in fields {
        collect_type_refs_from_type_expr(
          field.ty,
          refs,
          prefix,
          imported_aliases,
        )
      }
    @wit.TypeDefKind::Variant(cases) =>
      for c in cases {
        match c.ty {
          Some(case_ty) =>
            collect_type_refs_from_type_expr(
              case_ty, refs, prefix, imported_aliases,
            )
          None => ()
        }
      }
    @wit.TypeDefKind::Alias(alias_ty) =>
      collect_type_refs_from_type_expr(alias_ty, refs, prefix, imported_aliases)
    @wit.TypeDefKind::Resource(resource) =>
      for func in resource.funcs {
        collect_type_refs_from_function(func, refs, prefix, imported_aliases)
      }
    @wit.TypeDefKind::Enum(_) | @wit.TypeDefKind::Flags(_) => ()
  }
}

///|
fn emit_record_typedef(
  name : String,
  fields : Array[@wit.Field],
  prefix : String,
  imported_aliases : Map[String, String],
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("pub(all) struct ")
  buf.write_string(name)
  buf.write_string(" {\n")
  for field in fields {
    buf.write_string("  ")
    buf.write_string(to_snake_case(field.name))
    buf.write_string(" : ")
    buf.write_string(emit_type_expr(field.ty, prefix, imported_aliases))
    buf.write_string("\n")
  }
  buf.write_string("}\n")
  buf.to_string()
}

///|
fn emit_enum_typedef(name : String, cases : Array[String]) -> String {
  let buf = StringBuilder::new()
  buf.write_string("pub(all) enum ")
  buf.write_string(name)
  buf.write_string(" {\n")
  for c in cases {
    buf.write_string("  ")
    buf.write_string(to_pascal_case(c))
    buf.write_string("\n")
  }
  buf.write_string("}\n")
  buf.to_string()
}

///|
fn emit_variant_typedef(
  name : String,
  cases : Array[@wit.VariantCase],
  prefix : String,
  imported_aliases : Map[String, String],
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("pub(all) enum ")
  buf.write_string(name)
  buf.write_string(" {\n")
  for c in cases {
    buf.write_string("  ")
    buf.write_string(to_pascal_case(c.name))
    match c.ty {
      Some(case_ty) => {
        buf.write_char('(')
        buf.write_string(emit_type_expr(case_ty, prefix, imported_aliases))
        buf.write_char(')')
      }
      None => ()
    }
    buf.write_string("\n")
  }
  buf.write_string("}\n")
  buf.to_string()
}

///|
fn emit_typedef(
  type_def : @wit.TypeDef,
  prefix : String,
  imported_aliases : Map[String, String],
) -> String {
  let name = scoped_type_name(prefix, type_def.name)
  match type_def.kind {
    @wit.TypeDefKind::Record(fields) =>
      emit_record_typedef(name, fields, prefix, imported_aliases)
    @wit.TypeDefKind::Enum(cases) => emit_enum_typedef(name, cases)
    @wit.TypeDefKind::Flags(_) => "pub(all) type " + name + "\n"
    @wit.TypeDefKind::Variant(cases) =>
      emit_variant_typedef(name, cases, prefix, imported_aliases)
    @wit.TypeDefKind::Alias(_alias_ty) => "pub(all) type " + name + "\n"
    @wit.TypeDefKind::Resource(_) => "pub(all) struct " + name + "(Int)\n"
  }
}

///|
fn method_name_from_function(func : @wit.Function) -> String {
  match func.kind {
    @wit.FunctionKind::Freestanding => to_snake_case(func.name)
    @wit.FunctionKind::Constructor(resource_name)
    | @wit.FunctionKind::Method(resource_name)
    | @wit.FunctionKind::Static(resource_name) =>
      to_snake_case(resource_name + "_" + func.name)
  }
}

///|
fn unique_method_name(base : String, used : Array[String]) -> String {
  if not(contains_string(used, base)) {
    used.push(base)
    return base
  }
  let mut i = 2
  while true {
    let candidate = base + "_" + i.to_string()
    if not(contains_string(used, candidate)) {
      used.push(candidate)
      return candidate
    }
    i = i + 1
  }
  base
}

///|
fn emit_trait_method(
  buf : StringBuilder,
  method_name : String,
  func : @wit.Function,
  prefix : String,
  imported_aliases : Map[String, String],
) -> Unit {
  buf.write_string("  ")
  buf.write_string(method_name)
  buf.write_string("(Self")
  for param in func.params {
    buf.write_string(", ")
    buf.write_string(emit_type_expr(param.ty, prefix, imported_aliases))
  }
  buf.write_string(") -> ")
  buf.write_string(
    emit_contract_result_type(func.result, prefix, imported_aliases),
  )
  buf.write_string(" = _\n")
}

///|
fn emit_default_trait_impl(
  buf : StringBuilder,
  trait_name : String,
  generated_method : GeneratedMethod,
  prefix : String,
) -> Unit {
  buf.write_string("impl ")
  buf.write_string(trait_name)
  buf.write_string(" with ")
  buf.write_string(generated_method.method_name)
  buf.write_string("(_self")
  for i in 0..<generated_method.param_count {
    buf.write_string(", _arg")
    buf.write_string(i.to_string())
  }
  buf.write_string(") {\n")
  buf.write_string("  Err(WasiError::NotImplemented(\"")
  buf.write_string(prefix)
  buf.write_string(".")
  buf.write_string(generated_method.method_name)
  buf.write_string("\"))\n")
  buf.write_string("}\n")
}

///|
fn use_decl_target_prefix(
  shape : InterfaceShape,
  decl : @wit.UseDecl,
) -> String {
  let target_pkg = match decl.from.pkg {
    Some(pkg) => Some(pkg)
    None => shape.pkg
  }
  interface_prefix(target_pkg, None, decl.from.interface)
}

///|
fn resolved_interface_prefix(
  pkg : @wit.RPackageName?,
  interface_name : String,
) -> String {
  let buf = StringBuilder::new()
  match pkg {
    Some(pkg_name) => buf.write_string(to_pascal_case(pkg_name.name))
    None => ()
  }
  buf.write_string(to_pascal_case(interface_name))
  buf.to_string()
}

///|
fn collect_resolved_aliases_by_prefix(
  infos : Array[@wit.ResolvedInterfaceInfo],
) -> Map[String, Map[String, String]] {
  let aliases_by_prefix : Map[String, Map[String, String]] = {}
  for info in infos {
    let interface_name = match info.name {
      Some(name) => name
      None => continue
    }
    let prefix = resolved_interface_prefix(info.package_name, interface_name)
    let aliases = match aliases_by_prefix.get(prefix) {
      Some(existing) => existing
      None => {}
    }
    for local_name, type_info in info.types {
      match type_info.owner {
        @wit.RTypeOwner::Interface(owner_id) =>
          if owner_id == info.interface_id {
            continue
          }
        _ => continue
      }
      let owner_interface = match type_info.owner_interface {
        Some(name) => name
        None => continue
      }
      let owner_prefix = resolved_interface_prefix(
        type_info.owner_package,
        owner_interface,
      )
      let type_name = match type_info.type_name {
        Some(name) => name
        None => local_name
      }
      aliases.set(local_name, scoped_type_name(owner_prefix, type_name))
    }
    aliases_by_prefix.set(prefix, aliases)
  }
  aliases_by_prefix
}

///|
fn collect_resolved_interface_infos_from_sources(
  sources : Array[String],
) -> Array[@wit.ResolvedInterfaceInfo] {
  let infos : Array[@wit.ResolvedInterfaceInfo] = []
  for source in sources {
    match @wit.resolve_interface_infos(source) {
      Ok(resolved_infos) =>
        for info in resolved_infos {
          infos.push(info)
        }
      Err(_) => ()
    }
  }
  infos
}

///|
fn collect_resolved_interface_infos_from_paths(
  paths : Array[String],
) -> Array[@wit.ResolvedInterfaceInfo] {
  let infos : Array[@wit.ResolvedInterfaceInfo] = []
  for path in paths {
    match @wit.resolve_path_interface_infos(path) {
      Ok(resolved_infos) =>
        for info in resolved_infos {
          infos.push(info)
        }
      Err(_) => ()
    }
  }
  infos
}

///|
fn build_import_aliases(shape : InterfaceShape) -> Map[String, String] {
  let imported_aliases : Map[String, String] = {}
  for source_type, target_type in shape.resolved_aliases {
    imported_aliases.set(source_type, target_type)
  }
  for item in shape.items {
    match item {
      @wit.InterfaceItem::Use(decl) => {
        let target_prefix = use_decl_target_prefix(shape, decl)
        for name in decl.names {
          let source_type = name
          let target_type = scoped_type_name(target_prefix, name)
          match imported_aliases.get(source_type) {
            Some(_) => ()
            None => imported_aliases.set(source_type, target_type)
          }
        }
      }
      _ => ()
    }
  }
  imported_aliases
}

///|
fn emit_interface_contract(shape : InterfaceShape) -> String {
  let imported_aliases = build_import_aliases(shape)
  let imported_target_types : Array[String] = []
  for _name, resolved in imported_aliases {
    push_unique_string(imported_target_types, resolved)
  }
  let defined_types : Array[String] = []
  let referenced_types : Array[String] = []
  for item in shape.items {
    match item {
      @wit.InterfaceItem::TypeDef(type_def) => {
        push_unique_string(
          defined_types,
          scoped_type_name(shape.prefix, type_def.name),
        )
        collect_type_refs_from_typedef_kind(
          type_def.kind,
          referenced_types,
          shape.prefix,
          imported_aliases,
        )
      }
      @wit.InterfaceItem::Function(func) =>
        collect_type_refs_from_function(
          func,
          referenced_types,
          shape.prefix,
          imported_aliases,
        )
      @wit.InterfaceItem::Use(_) => ()
    }
  }
  let buf = StringBuilder::new()
  for item in shape.items {
    match item {
      @wit.InterfaceItem::TypeDef(type_def) => {
        buf.write_string(emit_typedef(type_def, shape.prefix, imported_aliases))
        buf.write_string("\n")
      }
      _ => ()
    }
  }
  let fallback_types : Array[String] = []
  for ref_name in referenced_types {
    if not(contains_string(defined_types, ref_name)) {
      push_unique_string(fallback_types, ref_name)
    }
  }
  for fallback in fallback_types {
    if contains_string(imported_target_types, fallback) {
      continue
    }
    buf.write_string("pub(all) type ")
    buf.write_string(fallback)
    buf.write_string("\n")
  }
  if fallback_types.length() > 0 {
    buf.write_string("\n")
  }
  let trait_name = "Wasi" + shape.prefix + "Adapter"
  buf.write_string("pub(open) trait ")
  buf.write_string(trait_name)
  buf.write_string(" {\n")
  let used_method_names : Array[String] = []
  let generated_methods : Array[GeneratedMethod] = []
  for item in shape.items {
    match item {
      @wit.InterfaceItem::Function(func) => {
        let method_name = unique_method_name(
          method_name_from_function(func),
          used_method_names,
        )
        emit_trait_method(
          buf,
          method_name,
          func,
          shape.prefix,
          imported_aliases,
        )
        generated_methods.push({
          method_name,
          param_count: func.params.length(),
        })
      }
      @wit.InterfaceItem::TypeDef(type_def) =>
        match type_def.kind {
          @wit.TypeDefKind::Resource(resource) =>
            for func in resource.funcs {
              let method_name = unique_method_name(
                method_name_from_function(func),
                used_method_names,
              )
              emit_trait_method(
                buf,
                method_name,
                func,
                shape.prefix,
                imported_aliases,
              )
              generated_methods.push({
                method_name,
                param_count: func.params.length(),
              })
            }
          _ => ()
        }
      @wit.InterfaceItem::Use(_) => ()
    }
  }
  buf.write_string("}\n")
  buf.write_string("\n")
  for generated_method in generated_methods {
    emit_default_trait_impl(buf, trait_name, generated_method, shape.prefix)
    buf.write_string("\n")
  }
  buf.to_string()
}

///|
fn collect_error_type_from_result(
  result_ty : @wit.TypeExpr?,
  prefix : String,
  imported_aliases : Map[String, String],
  error_types : Array[String],
) -> Unit {
  match result_ty {
    Some(@wit.TypeExpr::Result(_, Some(err_ty))) => {
      let ty = emit_type_expr(err_ty, prefix, imported_aliases)
      push_unique_string(error_types, ty)
    }
    _ => ()
  }
}

///|
fn collect_error_types_from_shape(
  shape : InterfaceShape,
  error_types : Array[String],
) -> Unit {
  let imported_aliases = build_import_aliases(shape)
  for item in shape.items {
    match item {
      @wit.InterfaceItem::Function(func) =>
        collect_error_type_from_result(
          func.result,
          shape.prefix,
          imported_aliases,
          error_types,
        )
      @wit.InterfaceItem::TypeDef(type_def) =>
        match type_def.kind {
          @wit.TypeDefKind::Resource(resource) =>
            for func in resource.funcs {
              collect_error_type_from_result(
                func.result,
                shape.prefix,
                imported_aliases,
                error_types,
              )
            }
          _ => ()
        }
      @wit.InterfaceItem::Use(_) => ()
    }
  }
}

///|
fn build_error_variants(shapes : Array[InterfaceShape]) -> Array[ErrorVariant] {
  let error_types : Array[String] = []
  for shape in shapes {
    collect_error_types_from_shape(shape, error_types)
  }
  let used_names : Array[String] = []
  let variants : Array[ErrorVariant] = []
  for ty in error_types {
    let base = "From" + to_pascal_case(ty)
    let variant_name = unique_method_name(base, used_names)
    variants.push({ variant_name, payload_type: Some(ty) })
  }
  variants
}

///|
fn emit_wasi_error_module(variants : Array[ErrorVariant]) -> String {
  let buf = StringBuilder::new()
  buf.write_string("///| Generated by wasi_posix WIT adapter generator.\n")
  buf.write_string(
    "///| This file is intended to be generated; do not edit manually.\n\n",
  )
  buf.write_string("///|\n")
  buf.write_string("pub(all) suberror WasiError {\n")
  buf.write_string("  NotImplemented(String)\n")
  buf.write_string("  CapabilityDenied(String)\n")
  for variant in variants {
    buf.write_string("  ")
    buf.write_string(variant.variant_name)
    match variant.payload_type {
      Some(payload_type) => {
        buf.write_char('(')
        buf.write_string(payload_type)
        buf.write_char(')')
      }
      None => ()
    }
    buf.write_string("\n")
  }
  buf.write_string("}\n")
  buf.to_string()
}

///|
fn interface_prefix(
  pkg : @wit.PackageName?,
  world_name : String?,
  interface_name : String,
) -> String {
  let buf = StringBuilder::new()
  match pkg {
    Some(pkg_name) => buf.write_string(to_pascal_case(pkg_name.name))
    None => ()
  }
  match world_name {
    Some(name) => buf.write_string(to_pascal_case(name))
    None => ()
  }
  buf.write_string(to_pascal_case(interface_name))
  buf.to_string()
}

///|
fn has_shape(shapes : Array[InterfaceShape], key : String) -> Bool {
  for shape in shapes {
    if shape.key == key {
      return true
    }
  }
  false
}

///|
fn push_interface_shape(
  shapes : Array[InterfaceShape],
  pkg : @wit.PackageName?,
  world_name : String?,
  interface_name : String,
  items : Array[@wit.InterfaceItem],
  resolved_aliases_by_prefix : Map[String, Map[String, String]],
) -> Unit {
  let prefix = interface_prefix(pkg, world_name, interface_name)
  let key = prefix
  if has_shape(shapes, key) {
    return
  }
  let resolved_aliases = match resolved_aliases_by_prefix.get(prefix) {
    Some(aliases) => aliases
    None => {}
  }
  shapes.push({ key, prefix, pkg, resolved_aliases, items })
}

///|
fn collect_interfaces(
  wit_files : Array[@wit.WitFile],
  resolved_aliases_by_prefix : Map[String, Map[String, String]],
) -> Array[InterfaceShape] {
  let shapes : Array[InterfaceShape] = []
  for wit_file in wit_files {
    for iface in wit_file.interfaces {
      push_interface_shape(
        shapes,
        wit_file.pkg,
        None,
        iface.name,
        iface.items,
        resolved_aliases_by_prefix,
      )
    }
    for world in wit_file.worlds {
      for item in world.imports {
        match item {
          @wit.WorldItem::InlineInterface(iface) =>
            push_interface_shape(
              shapes,
              wit_file.pkg,
              Some(world.name),
              iface.name,
              iface.items,
              resolved_aliases_by_prefix,
            )
          _ => ()
        }
      }
      for item in world.exports {
        match item {
          @wit.WorldItem::InlineInterface(iface) =>
            push_interface_shape(
              shapes,
              wit_file.pkg,
              Some(world.name),
              iface.name,
              iface.items,
              resolved_aliases_by_prefix,
            )
          _ => ()
        }
      }
    }
  }
  shapes
}

///|
fn module_file_name(shape : InterfaceShape) -> String {
  "gen_" + pascal_to_snake_case(shape.prefix) + ".mbt"
}

///|
fn emit_raw_module_code(shape : InterfaceShape) -> String {
  let buf = StringBuilder::new()
  buf.write_string("///| Generated by wasi_posix WIT adapter generator.\n")
  buf.write_string(
    "///| This file is intended to be generated; do not edit manually.\n",
  )
  buf.write_string("///| Module key: ")
  buf.write_string(shape.key)
  buf.write_string("\n\n")
  buf.write_string(emit_interface_contract(shape))
  buf.write_string("\n")
  buf.to_string()
}

///|
fn format_generated_code(raw : String) -> Result[String, GenerateError] {
  let parsed = @parser.parse_string(raw)
  let (_impls, reports) = parsed
  if reports.length() > 0 {
    return Err(GenerateError::GeneratedCodeParse(reports[0].to_string()))
  }
  Ok(raw)
}

///|
fn generate_modules_from_shapes(
  shapes : Array[InterfaceShape],
) -> Result[Array[GeneratedModule], GenerateError] {
  let modules : Array[GeneratedModule] = []
  let error_variants = build_error_variants(shapes)
  let error_raw = emit_wasi_error_module(error_variants)
  match format_generated_code(error_raw) {
    Ok(code) => modules.push({ file_name: "gen_wasi_error.mbt", code })
    Err(err) => return Err(err)
  }
  for shape in shapes {
    let raw = emit_raw_module_code(shape)
    match format_generated_code(raw) {
      Ok(code) => modules.push({ file_name: module_file_name(shape), code })
      Err(err) => return Err(err)
    }
  }
  Ok(modules)
}

///|
fn combine_modules(modules : Array[GeneratedModule]) -> String {
  let buf = StringBuilder::new()
  for generated in modules {
    buf.write_string(generated.code)
    if not(generated.code.has_suffix("\n")) {
      buf.write_char('\n')
    }
    buf.write_char('\n')
  }
  buf.to_string()
}

///|
fn generate_trait_adapter_modules_from_wit_files_with_aliases(
  wit_files : Array[@wit.WitFile],
  resolved_aliases_by_prefix : Map[String, Map[String, String]],
) -> Result[Array[GeneratedModule], GenerateError] {
  let shapes = collect_interfaces(wit_files, resolved_aliases_by_prefix)
  generate_modules_from_shapes(shapes)
}

///|
/// Generate trait adapter modules from parsed WIT AST files.
pub fn generate_trait_adapter_modules_from_wit_files(
  wit_files : Array[@wit.WitFile],
) -> Result[Array[GeneratedModule], GenerateError] {
  let empty_aliases : Map[String, Map[String, String]] = {}
  generate_trait_adapter_modules_from_wit_files_with_aliases(
    wit_files, empty_aliases,
  )
}

///|
/// Generate trait adapter code from parsed WIT AST files.
pub fn generate_trait_adapters_from_wit_files(
  wit_files : Array[@wit.WitFile],
) -> Result[String, GenerateError] {
  match generate_trait_adapter_modules_from_wit_files(wit_files) {
    Ok(modules) => Ok(combine_modules(modules))
    Err(err) => Err(err)
  }
}

///|
/// Generate trait adapter code from parsed WIT AST.
pub fn generate_trait_adapters_from_wit_file(
  wit_file : @wit.WitFile,
) -> Result[String, GenerateError] {
  generate_trait_adapters_from_wit_files([wit_file])
}

///|
/// Generate trait adapter modules from parsed WIT AST.
pub fn generate_trait_adapter_modules_from_wit_file(
  wit_file : @wit.WitFile,
) -> Result[Array[GeneratedModule], GenerateError] {
  generate_trait_adapter_modules_from_wit_files([wit_file])
}

///|
/// Generate trait adapter modules from multiple WIT sources.
pub fn generate_trait_adapter_modules_from_wit_sources(
  sources : Array[String],
) -> Result[Array[GeneratedModule], GenerateError] {
  match parse_wit_files_from_sources(sources) {
    Ok(wit_files) => {
      let resolved_infos = collect_resolved_interface_infos_from_sources(
        sources,
      )
      let resolved_aliases_by_prefix = collect_resolved_aliases_by_prefix(
        resolved_infos,
      )
      generate_trait_adapter_modules_from_wit_files_with_aliases(
        wit_files, resolved_aliases_by_prefix,
      )
    }
    Err(err) => Err(err)
  }
}

///|
/// Generate trait adapter code from multiple WIT sources.
pub fn generate_trait_adapters_from_wit_sources(
  sources : Array[String],
) -> Result[String, GenerateError] {
  match generate_trait_adapter_modules_from_wit_sources(sources) {
    Ok(modules) => Ok(combine_modules(modules))
    Err(err) => Err(err)
  }
}

///|
/// Generate trait adapter code from WIT source.
pub fn generate_trait_adapters_from_wit_source(
  source : String,
) -> Result[String, GenerateError] {
  generate_trait_adapters_from_wit_sources([source])
}

///|
/// Generate trait adapter modules from WIT source.
pub fn generate_trait_adapter_modules_from_wit_source(
  source : String,
) -> Result[Array[GeneratedModule], GenerateError] {
  generate_trait_adapter_modules_from_wit_sources([source])
}

///|
/// Generate trait adapter modules from multiple WIT file or directory paths.
pub fn generate_trait_adapter_modules_from_wit_paths(
  paths : Array[String],
) -> Result[Array[GeneratedModule], GenerateError] {
  match parse_wit_files_from_paths(paths) {
    Ok(wit_files) => {
      let resolved_infos = collect_resolved_interface_infos_from_paths(paths)
      let resolved_aliases_by_prefix = collect_resolved_aliases_by_prefix(
        resolved_infos,
      )
      generate_trait_adapter_modules_from_wit_files_with_aliases(
        wit_files, resolved_aliases_by_prefix,
      )
    }
    Err(err) => Err(err)
  }
}

///|
/// Generate trait adapter code from multiple WIT file or directory paths.
pub fn generate_trait_adapters_from_wit_paths(
  paths : Array[String],
) -> Result[String, GenerateError] {
  match generate_trait_adapter_modules_from_wit_paths(paths) {
    Ok(modules) => Ok(combine_modules(modules))
    Err(err) => Err(err)
  }
}

///|
/// Generate trait adapter code from a WIT file or directory path.
pub fn generate_trait_adapters_from_wit_path(
  path : String,
) -> Result[String, GenerateError] {
  generate_trait_adapters_from_wit_paths([path])
}

///|
/// Generate trait adapter modules from a WIT file or directory path.
pub fn generate_trait_adapter_modules_from_wit_path(
  path : String,
) -> Result[Array[GeneratedModule], GenerateError] {
  generate_trait_adapter_modules_from_wit_paths([path])
}
