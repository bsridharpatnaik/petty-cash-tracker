// NoteFileInfo.java
package com.gb.et.data;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Embeddable;

@Embeddable
@Data
@AllArgsConstructor
@NoArgsConstructor
public class NoteFileInfo implements Serializable {

    @Column(name = "file_uuid", length = 36)
    private UUID fileUuid;

    @Column(name = "filename", columnDefinition = "TEXT")
    private String filename;
}
