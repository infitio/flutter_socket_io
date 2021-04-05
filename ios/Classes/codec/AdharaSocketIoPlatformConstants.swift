//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

public class AdharaSocketIoMethodChannelNames {
    public static let managerMethodChannel = "adhara_socket_io";
    public static let socketMethodChannel = "adhara_socket_io:socket:";
    public static let streamsChannel = "adhara_socket_io:event_streams";
}

public class CodecTypes {
    public static let type1 = 128;
}

public class AdharaSocketIoPlatformMethod {
    public static let newInstance = "newInstance";
    public static let clearInstance = "clearInstance";
    public static let connect = "connect";
    public static let emit = "emit";
    public static let isConnected = "isConnected";
    public static let incomingAck = "incomingAck";
}

public class TxEventTypes {
    public static let connect = "connect";
    public static let disconnect = "disconnect";
    public static let connectError = "connectError";
    public static let connectTimeout = "connectTimeout";
    public static let error = "error";
    public static let connecting = "connecting";
    public static let reconnect = "reconnect";
    public static let reconnectError = "reconnectError";
    public static let reconnectFailed = "reconnectFailed";
    public static let reconnecting = "reconnecting";
    public static let ping = "ping";
    public static let pong = "pong";
}

public class TxTransportModes {
    public static let websocket = "websocket";
    public static let polling = "polling";
}

public class TxMessageDataTypes {
    public static let map = "map";
    public static let list = "list";
    public static let other = "other";
}

public class TxSocketMessage {
    public static let type = "type";
    public static let message = "message";
}
