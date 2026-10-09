// NoteService.java
package com.gb.et.service;

import com.gb.et.data.NoteFileInfo;
import com.gb.et.data.ResourceNotFoundException;
import com.gb.et.models.FileEntity;
import com.gb.et.models.Note;
import com.gb.et.models.Organization;
import com.gb.et.repository.FileRepository;
import com.gb.et.repository.NoteRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.hibernate.Hibernate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class NoteService {

    @Autowired
    private NoteRepository noteRepository;

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private FileRepository fileRepository;

    public Note createNote(Note note) {
        Organization currentOrganization = userDetailsService.getOrganizationForCurrentUser();
        note.setOrganization(currentOrganization);
        List<NoteFileInfo> fileInfos = note.getFiles();
        List<NoteFileInfo> updatedFileInfos = fileInfos.stream()
                .map(fileInfo -> {
                    FileEntity fileEntity = fileRepository.findByFileUuid(fileInfo.getFileUuid().toString());
                    return new NoteFileInfo(fileInfo.getFileUuid(), fileEntity.getFilename());
                })
                .collect(Collectors.toList());
        note.setFiles(updatedFileInfos);
        return noteRepository.save(note);
    }

    public Note updateNote(Long id, Note updatedNote) {
        Note note = noteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));

        if (updatedNote.getText() != null) {
            note.setText(updatedNote.getText());
        }

        if (updatedNote.getFiles() != null && !updatedNote.getFiles().isEmpty()) {
            List<NoteFileInfo> updatedFileInfos = updatedNote.getFiles().stream()
                    .map(fileInfo -> {
                        FileEntity fileEntity = fileRepository.findByFileUuid(fileInfo.getFileUuid().toString());
                        if (fileEntity == null) {
                            throw new ResourceNotFoundException("File not found with UUID: " + fileInfo.getFileUuid());
                        }
                        return new NoteFileInfo(fileInfo.getFileUuid(), fileEntity.getFilename());
                    })
                    .collect(Collectors.toList());
            note.setFiles(updatedFileInfos);
        }

        return noteRepository.save(note);
    }

    public void deleteNote(Long id) {
        Note note = noteRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
        noteRepository.delete(note);
    }

// NoteService.java
// ...

    public List<Note> getNotesByDate(Date date) {
        Organization currentOrganization = userDetailsService.getOrganizationForCurrentUser();
        List<Note> notes = noteRepository.findByDateAndOrganizationOrderByIdDesc(date, currentOrganization);

        // Eager load the files for each note
        for (Note note : notes) {
            Hibernate.initialize(note.getFiles());
        }

        return notes;
    }

// ...
}