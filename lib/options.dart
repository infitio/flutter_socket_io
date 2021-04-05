import 'generated/platform_constants.dart';

/// transport modes
enum Transports {
  /// to use web socket transport mode
  webSocket,

  /// use http polling as transport mode
  polling
}

/// options to create a socket instance
class SocketOptions {
  /// socket URI
  final String uri;

  /// Query params for socket URI
  final Map<String, String> query;

  ///Enable debug logging
  final bool enableLogging;

  ///List of transport names.
  List<Transports> transports;

  ///Connection timeout (ms). Set -1 to disable.
  int timeout = 20000;

  ///Namespace parameter
  String namespace;

  ///Path parameter if socket.io runs on a different endpoint
  String path;

//  public boolean forceNew;
//          /**
//         * Whether to enable multiplexing. Default is true.
//         */
//  public boolean multiplex = true;
//  public boolean reconnection = true;
//  public int reconnectionAttempts;
//  public long reconnectionDelay;
//  public long reconnectionDelayMax;
//  public double randomizationFactor;

//        /**
//         * Whether to upgrade the transport. Defaults to `true`.
//         */
//        public boolean upgrade = true;
//
//        public boolean rememberUpgrade;
//        public String host;

//        public String hostname;
//        public String path;
//        public String timestampParam;
//        public boolean secure;
//        public boolean timestampRequests;
//        public int port = -1;
//        public int policyPort = -1;

  /// constructor
  SocketOptions(
    this.uri, {
    this.query = const {},
    this.enableLogging = false,
    this.transports = const [Transports.webSocket, Transports.polling],
    this.namespace = '/',
    this.path = '/socket.io',
  }) : assert(namespace.startsWith('/'),
            "Namespace must be a non null string and should start with a '/'");

  /// convert options to a Map
  Map<String, dynamic> asMap() => {
        'uri': uri,
        'query': query,
        'path': path,
        'enableLogging': enableLogging,
        'namespace': namespace,
        'transports': transports
            .map((t) => {
                  Transports.webSocket: TxTransportModes.websocket,
                  Transports.polling: TxTransportModes.polling,
                }[t])
            .toList(),
        'timeout': timeout
      };
}
