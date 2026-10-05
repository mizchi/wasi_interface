// Keep the deprecated accessors exported by earlier MoonBit compilers.
// Tuple-struct fields no longer receive an automatic inner() method.

///|
#deprecated
pub fn CliStderrOutputStream::inner(self : CliStderrOutputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn CliStdinInputStream::inner(self : CliStdinInputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn CliStdoutOutputStream::inner(self : CliStdoutOutputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn CliTerminalStderrTerminalOutput::inner(
  self : CliTerminalStderrTerminalOutput,
) -> Int {
  self.0
}

///|
#deprecated
pub fn CliTerminalStdinTerminalInput::inner(
  self : CliTerminalStdinTerminalInput,
) -> Int {
  self.0
}

///|
#deprecated
pub fn CliTerminalStdoutTerminalOutput::inner(
  self : CliTerminalStdoutTerminalOutput,
) -> Int {
  self.0
}

///|
#deprecated
pub fn ClocksMonotonicClockDuration::inner(
  self : ClocksMonotonicClockDuration,
) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn ClocksMonotonicClockInstant::inner(
  self : ClocksMonotonicClockInstant,
) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn ClocksMonotonicClockPollable::inner(
  self : ClocksMonotonicClockPollable,
) -> Int {
  self.0
}

///|
#deprecated
pub fn ClocksTimezoneDatetime::inner(self : ClocksTimezoneDatetime) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn FilesystemPreopensDescriptor::inner(
  self : FilesystemPreopensDescriptor,
) -> Int {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesDatetime::inner(self : FilesystemTypesDatetime) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesDescriptor::inner(
  self : FilesystemTypesDescriptor,
) -> Int {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesDescriptorFlags::inner(
  self : FilesystemTypesDescriptorFlags,
) -> UInt {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesDirectoryEntryStream::inner(
  self : FilesystemTypesDirectoryEntryStream,
) -> Int {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesError::inner(self : FilesystemTypesError) -> Int {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesFilesize::inner(self : FilesystemTypesFilesize) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesInputStream::inner(
  self : FilesystemTypesInputStream,
) -> Int {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesLinkCount::inner(
  self : FilesystemTypesLinkCount,
) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesOpenFlags::inner(self : FilesystemTypesOpenFlags) -> Int {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesOutputStream::inner(
  self : FilesystemTypesOutputStream,
) -> Int {
  self.0
}

///|
#deprecated
pub fn FilesystemTypesPathFlags::inner(self : FilesystemTypesPathFlags) -> UInt {
  self.0
}

///|
#deprecated
pub fn HttpIncomingHandlerIncomingRequest::inner(
  self : HttpIncomingHandlerIncomingRequest,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpIncomingHandlerResponseOutparam::inner(
  self : HttpIncomingHandlerResponseOutparam,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpOutgoingHandlerErrorCode::inner(
  self : HttpOutgoingHandlerErrorCode,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpOutgoingHandlerFutureIncomingResponse::inner(
  self : HttpOutgoingHandlerFutureIncomingResponse,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpOutgoingHandlerOutgoingRequest::inner(
  self : HttpOutgoingHandlerOutgoingRequest,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpOutgoingHandlerRequestOptions::inner(
  self : HttpOutgoingHandlerRequestOptions,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesDuration::inner(self : HttpTypesDuration) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn HttpTypesFieldKey::inner(self : HttpTypesFieldKey) -> String {
  self.0
}

///|
#deprecated
pub fn HttpTypesFieldName::inner(self : HttpTypesFieldName) -> String {
  self.0
}

///|
#deprecated
pub fn HttpTypesFieldValue::inner(self : HttpTypesFieldValue) -> Bytes {
  self.0
}

///|
#deprecated
pub fn HttpTypesFields::inner(self : HttpTypesFields) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesFutureIncomingResponse::inner(
  self : HttpTypesFutureIncomingResponse,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesFutureTrailers::inner(self : HttpTypesFutureTrailers) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesHeaders::inner(self : HttpTypesHeaders) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesIncomingBody::inner(self : HttpTypesIncomingBody) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesIncomingRequest::inner(self : HttpTypesIncomingRequest) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesIncomingResponse::inner(
  self : HttpTypesIncomingResponse,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesIoError::inner(self : HttpTypesIoError) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesOutgoingBody::inner(self : HttpTypesOutgoingBody) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesOutgoingRequest::inner(self : HttpTypesOutgoingRequest) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesOutgoingResponse::inner(
  self : HttpTypesOutgoingResponse,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesOutputStream::inner(self : HttpTypesOutputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesPollable::inner(self : HttpTypesPollable) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesRequestOptions::inner(self : HttpTypesRequestOptions) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesResponseOutparam::inner(
  self : HttpTypesResponseOutparam,
) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesStatusCode::inner(self : HttpTypesStatusCode) -> Int {
  self.0
}

///|
#deprecated
pub fn HttpTypesTrailers::inner(self : HttpTypesTrailers) -> Int {
  self.0
}

///|
#deprecated
pub fn IoErrorError::inner(self : IoErrorError) -> Int {
  self.0
}

///|
#deprecated
pub fn IoPollPollable::inner(self : IoPollPollable) -> Int {
  self.0
}

///|
#deprecated
pub fn IoStreamsInputStream::inner(self : IoStreamsInputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn IoStreamsOutputStream::inner(self : IoStreamsOutputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsInstanceNetworkNetwork::inner(
  self : SocketsInstanceNetworkNetwork,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsIpNameLookupErrorCode::inner(
  self : SocketsIpNameLookupErrorCode,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsIpNameLookupIpAddress::inner(
  self : SocketsIpNameLookupIpAddress,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsIpNameLookupNetwork::inner(
  self : SocketsIpNameLookupNetwork,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsIpNameLookupPollable::inner(
  self : SocketsIpNameLookupPollable,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsIpNameLookupResolveAddressStream::inner(
  self : SocketsIpNameLookupResolveAddressStream,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsNetworkError::inner(self : SocketsNetworkError) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsNetworkIpv4Address::inner(
  self : SocketsNetworkIpv4Address,
) -> UInt {
  self.0
}

///|
#deprecated
pub fn SocketsNetworkIpv6Address::inner(
  self : SocketsNetworkIpv6Address,
) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn SocketsTcpCreateSocketErrorCode::inner(
  self : SocketsTcpCreateSocketErrorCode,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpCreateSocketIpAddressFamily::inner(
  self : SocketsTcpCreateSocketIpAddressFamily,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpCreateSocketTcpSocket::inner(
  self : SocketsTcpCreateSocketTcpSocket,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpDuration::inner(self : SocketsTcpDuration) -> UInt64 {
  self.0
}

///|
#deprecated
pub fn SocketsTcpErrorCode::inner(self : SocketsTcpErrorCode) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpInputStream::inner(self : SocketsTcpInputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpIpAddressFamily::inner(
  self : SocketsTcpIpAddressFamily,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpIpSocketAddress::inner(
  self : SocketsTcpIpSocketAddress,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpNetwork::inner(self : SocketsTcpNetwork) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpOutputStream::inner(self : SocketsTcpOutputStream) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpPollable::inner(self : SocketsTcpPollable) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsTcpTcpSocket::inner(self : SocketsTcpTcpSocket) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpCreateSocketErrorCode::inner(
  self : SocketsUdpCreateSocketErrorCode,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpCreateSocketIpAddressFamily::inner(
  self : SocketsUdpCreateSocketIpAddressFamily,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpCreateSocketUdpSocket::inner(
  self : SocketsUdpCreateSocketUdpSocket,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpErrorCode::inner(self : SocketsUdpErrorCode) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpIncomingDatagramStream::inner(
  self : SocketsUdpIncomingDatagramStream,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpIpAddressFamily::inner(
  self : SocketsUdpIpAddressFamily,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpIpSocketAddress::inner(
  self : SocketsUdpIpSocketAddress,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpNetwork::inner(self : SocketsUdpNetwork) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpOutgoingDatagramStream::inner(
  self : SocketsUdpOutgoingDatagramStream,
) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpPollable::inner(self : SocketsUdpPollable) -> Int {
  self.0
}

///|
#deprecated
pub fn SocketsUdpUdpSocket::inner(self : SocketsUdpUdpSocket) -> Int {
  self.0
}
