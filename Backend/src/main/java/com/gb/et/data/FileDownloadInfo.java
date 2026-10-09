package com.gb.et.data;

public class FileDownloadInfo {
    private String filename;
    private byte[] fileData;

    public FileDownloadInfo(String filename, byte[] fileData) {
        this.filename = filename;
        this.fileData = fileData;
    }

    public String getFilename() {
        return filename;
    }

    public byte[] getFileData() {
        return fileData;
    }
}
