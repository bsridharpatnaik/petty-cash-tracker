package com.gb.et.service;

import com.gb.et.data.*;
import com.gb.et.models.*;
import com.gb.et.others.FileSizeUtil;
import com.gb.et.repository.FolderRepository;
import com.gb.et.repository.HistoryRepo;
import com.gb.et.repository.VaultFileRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
public class FolderService {

    @Autowired
    private FolderRepository folderRepository;

    @Autowired
    VaultFileRepository fileRepository;

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    @Autowired
    HistoryRepo historyRepo;

    public FolderContentsResponse getFolderContentsWithSummary(Long folderId) {
        FolderEntity folder = (folderId == null) ? getOrCreateRootFolderWithContents() : getFolderContents(folderId);

        // Generate breadcrumb path
        List<FolderPathDto> breadcrumb = new ArrayList<>();
        FolderEntity currentFolder = folder;
        while (currentFolder != null) {
            breadcrumb.add(0, new FolderPathDto(currentFolder.getId(), currentFolder.getName()));
            currentFolder = currentFolder.getParentFolder();
        }

        // Map subfolders with item counts
        List<FolderContentsResponse.FolderSummary> subFolders = folder.getSubFolders().stream()
                .map(subFolder -> new FolderContentsResponse.FolderSummary(
                        subFolder.getId(),
                        subFolder.getName(),
                        subFolder.getItemCount(),
                        getLastUpdateDate(subFolder)))  // Calculate item count
                .collect(Collectors.toList());

        // Map files with sizes in MB
        List<FolderContentsResponse.FileSummary> files = folder.getFiles().stream()
                .map(file -> new FolderContentsResponse.FileSummary(
                        file.getId(),
                        file.getFilename(),
                        FileSizeUtil.getFileSizeInMB(file.getData()),
                        file.getUploadDate()))  // Calculate file size in MB
                .collect(Collectors.toList());

        // Return folder contents along with breadcrumb path
        return new FolderContentsResponse(
                folder.getId(),
                folder.getName(),
                (folder.getParentFolder() != null) ? folder.getParentFolder().getId() : null,
                subFolders,
                files,
                breadcrumb,
                userDetailsService.getCurrentUser()// Include breadcrumb path
        );
    }

    public FolderEntity getOrCreateRootFolderWithContents() {
        Organization organization = userDetailsService.getOrganizationForCurrentUser();
        return folderRepository.findRootFolderByOrganizationId(organization.getId())
                .orElseGet(() -> {
                    FolderEntity rootFolder = new FolderEntity();
                    rootFolder.setName("root");
                    rootFolder.setOrganization(organization);
                    return folderRepository.save(rootFolder);
                });
    }

    // Create a folder
    public FolderEntity createFolder(String name, Long parentId) {
        Organization organization = userDetailsService.getOrganizationForCurrentUser();

        // If creating a root folder, ensure there's no existing root folder
        if (parentId == null) {
            Optional<FolderEntity> existingRootFolder = folderRepository.findRootFolderByOrganizationId(organization.getId());
            if (existingRootFolder.isPresent()) {
                throw new InvalidOperationException("Root folder already exists for this organization.");
            }
        } else {
            // Check if a folder with the same name already exists in the specified parent folder
            boolean folderExists = folderRepository.existsByNameAndParentFolderId(name, parentId);
            if (folderExists) {
                throw new InvalidOperationException("A folder with the same name already exists in this location.");
            }
        }

        FolderEntity folder = new FolderEntity();
        folder.setName(name);
        folder.setOrganization(organization);

        if (parentId != null) {
            FolderEntity parentFolder = folderRepository.findById(parentId)
                    .orElseThrow(() -> new ResourceNotFoundException("Parent folder not found with ID: " + parentId));
            folder.setParentFolder(parentFolder);
        }

        return folderRepository.save(folder);
    }

    // Upload a file into a folder or the root folder if folderId is null
    @Transactional
    public FileUploadResponse uploadFile(String filename, byte[] data, Long folderId) {
        Organization organization = userDetailsService.getOrganizationForCurrentUser();

        FolderEntity folder;
        if (folderId == null) {
            folder = folderRepository.findRootFolderByOrganizationId(organization.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Root folder not found for organization: " + organization.getName()));
        } else {
            folder = folderRepository.findById(folderId)
                    .orElseThrow(() -> new ResourceNotFoundException("Folder not found with ID: " + folderId));
        }

        if (data == null || data.length == 0) {
            throw new FileStorageException("File data is empty or invalid.");
        }

        // Check if a file with the same name already exists in the folder
        boolean fileExists = fileRepository.existsByFilenameAndFolder(filename, folder);
        if (fileExists) {
            throw new FileStorageException("A file with the same name already exists in this folder.");
        }

        FileEntityForVault file = new FileEntityForVault();
        file.setFilename(filename);
        file.setData(data);
        file.setOrganization(organization);
        file.setFolder(folder);
        file.setUploadDate(new Date());
        fileRepository.save(file);
        historyRepo.save(new History(file));
        return new FileUploadResponse(
                file.getFilename(),
                file.getUploadDate(),
                file.getFolder().getId(),
                file.getId(),
                FileSizeUtil.getFileSizeInMB(file.getData()));
    }

    // Retrieve folder contents
    public FolderEntity getFolderContents(Long folderId) {
        return folderRepository.findById(folderId)
                .orElseThrow(() -> new ResourceNotFoundException("Folder not found with ID: " + folderId));
    }

    // Retrieve a file by its id
    public FileEntityForVault getFileById(Long id) {
        FileEntityForVault file = fileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("File not found with id: " + id));
        Organization currentUserOrganization = userDetailsService.getOrganizationForCurrentUser();
        if (!file.getOrganization().getId().equals(currentUserOrganization.getId())) {
            throw new AccessDeniedException("You do not have permission to access this file.");
        }
        return file;
    }

    /**
     * Delete a file by its UUID.
     *
     * @param FileId the id of the file to delete
     */
    public void deleteFile(Long id) {
        FileEntityForVault file = fileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("File not found with id: " + id));
        fileRepository.delete(file);
    }

    public void deleteFolder(Long folderId) {
        FolderEntity folder = folderRepository.findById(folderId)
                .orElseThrow(() -> new ResourceNotFoundException("Folder not found with ID: " + folderId));

        // Recursively delete all subfolders and files
        deleteFolderRecursive(folder);

        // Finally, delete the folder itself
        folderRepository.delete(folder);
    }

    /**
     * Recursively delete all subfolders and files within a folder.
     *
     * @param folder the folder to delete recursively
     */
    private void deleteFolderRecursive(FolderEntity folder) {
        // Delete all files in the folder
        for (FileEntityForVault file : folder.getFiles()) {
            fileRepository.delete(file);
        }

        // Recursively delete all subfolders
        for (FolderEntity subFolder : folder.getSubFolders()) {
            deleteFolderRecursive(subFolder);
            folderRepository.delete(subFolder);
        }
    }

    public Date getLastUpdateDate(FolderEntity folder) {
        // Get the most recent file update date in the current folder
        Optional<Date> lastFileUpdate = folder.getFiles().stream()
                .map(FileEntityForVault::getUploadDate)
                .max(Comparator.naturalOrder());

        // Get the most recent update date from the subfolders recursively
        Optional<Date> lastSubfolderUpdate = folder.getSubFolders().stream()
                .map(this::getLastUpdateDate)
                .filter(Objects::nonNull)
                .max(Comparator.naturalOrder());

        // Combine the two Optional<Date> results
        return Stream.of(lastFileUpdate, lastSubfolderUpdate)
                .filter(Optional::isPresent)
                .map(Optional::get)
                .max(Comparator.naturalOrder())
                .orElse(null);
    }
}

