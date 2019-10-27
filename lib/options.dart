enum Transports { WEB_SOCKET, POLLING }

class SocketOptions {
  final String uri;
  final Map<String, String> query;

  ///Enable debug logging
  final bool enableLogging;

  ///List of transport names.
  List<Transports> transports;

  ///Connection timeout (ms). Set -1 to disable.
  int timeout = 20000;

  ///Namespace parameter
  String nameSpace;

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

  SocketOptions(this.uri,
      {this.query: const {},
      this.enableLogging: false,
      this.transports: const [Transports.WEB_SOCKET, Transports.POLLING],
      this.nameSpace = "/",
      this.path = '/socket.io'})
      : assert(nameSpace.startsWith("/"),
            "Namespace must be a non null string and should start with a '/'");

  Map asMap() {
    return {
      "uri": uri,
      "query": query,
      "path": path,
      "enableLogging": enableLogging,
      "namespace": nameSpace,
      "transports": transports.map((Transports t) {
        return {
          Transports.WEB_SOCKET: "websocket",
          Transports.POLLING: "polling"
        }[t];
      }).toList(),
      "timeout": timeout
    };
  }
}
