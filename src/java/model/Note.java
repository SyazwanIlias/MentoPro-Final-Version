package model;

import java.sql.Timestamp;

public class Note {
    private int noteID;
    private int mentorID;
    private String mentorName; // Helper for display
    private String fileName;
    private String fileType;
    private byte[] fileData;
    private Timestamp uploadDate;

    // Getters and Setters
    public int getNoteID() { return noteID; }
    public void setNoteID(int noteID) { this.noteID = noteID; }
    public int getMentorID() { return mentorID; }
    public void setMentorID(int mentorID) { this.mentorID = mentorID; }
    public String getMentorName() { return mentorName; }
    public void setMentorName(String mentorName) { this.mentorName = mentorName; }
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }
    public byte[] getFileData() { return fileData; }
    public void setFileData(byte[] fileData) { this.fileData = fileData; }
    public Timestamp getUploadDate() { return uploadDate; }
    public void setUploadDate(Timestamp uploadDate) { this.uploadDate = uploadDate; }
}