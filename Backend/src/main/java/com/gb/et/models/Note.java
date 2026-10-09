// Note.java
package com.gb.et.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.gb.et.data.NoteFileInfo;
import lombok.Data;
import javax.persistence.*;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Entity
@Data
public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "The 'date' field is required.")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date date;

    @Size(max = 300, message = "The 'text' field cannot exceed 300 characters.")
    private String text;

    @ElementCollection
    @CollectionTable(name = "note_file_mapping", joinColumns = @JoinColumn(name = "note_id"))
    private List<NoteFileInfo> files = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organization_id")
    private Organization organization;
}