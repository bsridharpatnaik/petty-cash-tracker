package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

@JsonFormat(shape = JsonFormat.Shape.STRING)
public enum HistoryTypeEnum {
    TRANSACTION,
    FILE;

    public HistoryTypeEnum setFromString(String name) {
        return HistoryTypeEnum.valueOf(name);
    }

    public static List<String> getValidTypes() {
        List<String> validHistoryType = new ArrayList<String>();
        EnumSet.allOf(HistoryTypeEnum.class).forEach(type -> validHistoryType.add(type.toString()));
        return validHistoryType;
    }
}
