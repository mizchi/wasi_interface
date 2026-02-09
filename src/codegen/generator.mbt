///|
pub(all) suberror GenerateError {
  WitParse(String)
  GeneratedCodeParse(String)
  PrinterFailed(String)
} derive(Show, Eq)

///|
priv struct InterfaceShape {
  name : String
  items : Array[@wit.InterfaceItem]
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
fn to_type_name(name : String) -> String {
  to_pascal_case(name)
}

///|
fn emit_type_expr(ty : @wit.TypeExpr) -> String {
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
    @wit.TypeExpr::Id(name) => to_type_name(name)
    @wit.TypeExpr::Own(name) => to_type_name(name)
    @wit.TypeExpr::Borrow(name) => to_type_name(name)
    @wit.TypeExpr::List(inner) =>
      match inner {
        @wit.TypeExpr::U8 => "Bytes"
        _ => "Array[" + emit_type_expr(inner) + "]"
      }
    @wit.TypeExpr::Option(inner) => emit_type_expr(inner) + "?"
    @wit.TypeExpr::Result(ok, err) => {
      let err_type = match err {
        Some(err_ty) => emit_type_expr(err_ty)
        None => "Unit"
      }
      "Result[" + emit_type_expr(ok) + ", " + err_type + "]"
    }
    @wit.TypeExpr::Tuple(items) =>
      if items.length() == 0 {
        "Unit"
      } else {
        "Array[Any]"
      }
  }
}

///|
fn emit_result_type(result_ty : @wit.TypeExpr?) -> String {
  match result_ty {
    Some(ty) => emit_type_expr(ty)
    None => "Unit"
  }
}

///|
fn is_collected(shapes : Array[InterfaceShape], name : String) -> Bool {
  for shape in shapes {
    if shape.name == name {
      return true
    }
  }
  false
}

///|
fn push_interface_shape(
  shapes : Array[InterfaceShape],
  name : String,
  items : Array[@wit.InterfaceItem],
) -> Unit {
  if is_collected(shapes, name) {
    return
  }
  shapes.push({ name, items })
}

///|
fn collect_interfaces(wit_file : @wit.WitFile) -> Array[InterfaceShape] {
  let shapes : Array[InterfaceShape] = []
  for iface in wit_file.interfaces {
    push_interface_shape(shapes, iface.name, iface.items)
  }
  for world in wit_file.worlds {
    for item in world.imports {
      match item {
        @wit.WorldItem::InlineInterface(iface) =>
          push_interface_shape(shapes, iface.name, iface.items)
        _ => ()
      }
    }
    for item in world.exports {
      match item {
        @wit.WorldItem::InlineInterface(iface) =>
          push_interface_shape(shapes, iface.name, iface.items)
        _ => ()
      }
    }
  }
  shapes
}

///|
fn emit_interface_trait(shape : InterfaceShape) -> String {
  let trait_name = "Wasi" + to_pascal_case(shape.name) + "Adapter"
  let buf = StringBuilder::new()
  buf.write_string("pub(open) trait ")
  buf.write_string(trait_name)
  buf.write_string(" {\n")
  for item in shape.items {
    match item {
      @wit.InterfaceItem::Function(func) => {
        buf.write_string("  ")
        buf.write_string(to_snake_case(func.name))
        buf.write_string("(Self")
        for param in func.params {
          buf.write_string(", ")
          buf.write_string(emit_type_expr(param.ty))
        }
        buf.write_string(") -> ")
        buf.write_string(emit_result_type(func.result))
        buf.write_string("\n")
      }
      _ => ()
    }
  }
  buf.write_string("}\n")
  buf.to_string()
}

///|
fn emit_raw_contract_code(wit_file : @wit.WitFile) -> String {
  let buf = StringBuilder::new()
  buf.write_string("///| Generated by wasi_posix WIT adapter generator.\n")
  buf.write_string(
    "///| This file is intended to be generated; do not edit manually.\n\n",
  )
  let shapes = collect_interfaces(wit_file)
  for shape in shapes {
    buf.write_string(emit_interface_trait(shape))
    buf.write_string("\n")
  }
  buf.to_string()
}

///|
fn format_generated_code(raw : String) -> Result[String, GenerateError] {
  let parsed = @parser.parse_string(raw)
  let (_impls, reports) = parsed
  if reports.length() > 0 {
    return Err(GenerateError::GeneratedCodeParse(reports[0].to_string()))
  }
  match @ast_printer.print_code(parsed) {
    Some(printed) => Ok(printed)
    None =>
      Err(GenerateError::PrinterFailed("ast_printer.print_code returned None"))
  }
}

///|
/// Generate trait adapter code from parsed WIT AST.
pub fn generate_trait_adapters_from_wit_file(
  wit_file : @wit.WitFile,
) -> Result[String, GenerateError] {
  let raw = emit_raw_contract_code(wit_file)
  format_generated_code(raw)
}

///|
/// Generate trait adapter code from WIT source.
pub fn generate_trait_adapters_from_wit_source(
  source : String,
) -> Result[String, GenerateError] {
  match @wit.parse(source) {
    Ok(wit_file) => generate_trait_adapters_from_wit_file(wit_file)
    Err(err) => Err(GenerateError::WitParse(parse_error_to_string(err)))
  }
}

///|
/// Generate trait adapter code from a WIT file or directory path.
pub fn generate_trait_adapters_from_wit_path(
  path : String,
) -> Result[String, GenerateError] {
  match @wit.parse_path(path) {
    Ok(wit_file) => generate_trait_adapters_from_wit_file(wit_file)
    Err(err) => Err(GenerateError::WitParse(parse_error_to_string(err)))
  }
}
