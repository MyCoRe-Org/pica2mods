package org.mycore.pica2mods;

import java.io.IOException;

public class Pica2ModsException extends IOException {
    private static final long serialVersionUID = 1L;

    public Pica2ModsException(String msg) {
        super(msg);
    }

    public Pica2ModsException(Throwable t) {
        super(t);
    }

    public Pica2ModsException(String msg, Throwable t) {
        super(msg, t);
    }
}
