package com.gb.et.others;

public class FileSizeUtil {

    public static double getFileSizeInMB(byte[] data) {
        if (data == null) {
            return 0;
        }
        return data.length / (1024.0 * 1024.0);  // Convert bytes to MB
    }
}

