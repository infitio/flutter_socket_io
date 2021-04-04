//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

package com.infitio.adharasocketio;


final public class PlatformConstants {

    static final public class MethodChannelNames {
        public static final String managerMethodChannel = "adhara_socket_io";
        public static final String socketMethodChannel = "adhara_socket_io:socket:";
        public static final String streamsChannel = "adhara_socket_io:event_streams";
    }

    static final public class CodecTypes {
        public static final byte type1 = (byte) 128;
    }

    static final public class PlatformMethod {
        public static final String newInstance = "newInstance";
        public static final String clearInstance = "clearInstance";
        public static final String connect = "connect";
        public static final String emit = "emit";
        public static final String isConnected = "isConnected";
        public static final String incomingAck = "incomingAck";
    }

    static final public class TxEventTypes {
        public static final String connect = "connect";
        public static final String disconnect = "disconnect";
        public static final String connectError = "connectError";
        public static final String connectTimeout = "connectTimeout";
        public static final String error = "error";
        public static final String connecting = "connecting";
        public static final String reconnect = "reconnect";
        public static final String reconnectError = "reconnectError";
        public static final String reconnectFailed = "reconnectFailed";
        public static final String reconnecting = "reconnecting";
        public static final String ping = "ping";
        public static final String pong = "pong";
    }

    static final public class TxTransportModes {
        public static final String websocket = "websocket";
        public static final String polling = "polling";
    }

    static final public class TxMessageDataTypes {
        public static final String map = "map";
        public static final String list = "list";
        public static final String other = "other";
    }

    static final public class TxSocketMessage {
        public static final String type = "type";
        public static final String message = "message";
    }

}
