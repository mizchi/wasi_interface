// Keep the deprecated accessors exported by earlier MoonBit compilers.
// Tuple-struct fields no longer receive an automatic inner() method.

///|
#deprecated
pub fn FilesystemTypesDescriptor::inner(
  self : FilesystemTypesDescriptor,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesFields::inner(self : HttpTypesFields) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesRequest::inner(self : HttpTypesRequest) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesRequestOptions::inner(self : HttpTypesRequestOptions) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesResponse::inner(self : HttpTypesResponse) -> Int {
  self.0
}
