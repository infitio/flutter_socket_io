package com.infitio.adharasocketio;

import java.net.URISyntaxException;

import io.socket.client.IO;
import io.socket.emitter.Emitter;
import io.socket.client.Socket;


class AdharaSocket {

    public final Socket socket;

    AdharaSocket(String uri) throws URISyntaxException {
        socket = IO.socket("http://localhost");
    }

}
