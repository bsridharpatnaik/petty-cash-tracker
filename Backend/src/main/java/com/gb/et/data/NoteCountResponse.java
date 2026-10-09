// NoteCountResponse.java
package com.gb.et.data;

import com.gb.et.models.Note;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class NoteCountResponse {
    private List<Note> notes;
    private long count;
}