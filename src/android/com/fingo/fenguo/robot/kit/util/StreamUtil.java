package com.fingo.fenguo.robot.kit.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Created by wuyifan on 2018/2/5.
 */

public class StreamUtil {

    public static long StreamTransfer(InputStream is, OutputStream os) throws IOException {
        long size = 0;
        byte[] buffer = new byte[1024 * 4];
        while (true) {
            int len = is.read(buffer);
            if (len <= 0) break;
            os.write(buffer, 0, len);
            size += len;
        }
        return size;
    }
}

