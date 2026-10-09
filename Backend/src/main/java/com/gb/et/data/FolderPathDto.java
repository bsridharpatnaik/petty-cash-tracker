package com.gb.et.data;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;

@Data
@NoArgsConstructor
public class FolderPathDto {
    private Long id;
    private String name;

    public FolderPathDto(Long id, String name) {
        this.id = id;
        this.name = name;
    }
}

