/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

/**
 *
 * @author NASHU
 */

import controller.DBConn;
import java.io.InputStream;
import java.sql.*;
import java.util.*;

public class NotesDAO {

    // Mentor uploads a file
    public boolean uploadNote(int mentorId, String fileName, InputStream fileStream) throws Exception {
        String sql = "INSERT INTO notes (mentorID, fileName, fileData) VALUES (?, ?, ?)";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ps.setString(2, fileName);
            ps.setBlob(3, fileStream);
            return ps.executeUpdate() > 0;
        }
    }

    // Mentee only sees notes from mentors with 'APPROVED' status
    public List<Map<String, Object>> getNotesForMentee(int menteeId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        // Logic: Join notes with mentorship table filtered by APPROVED status
        String sql = "SELECT n.noteID, n.fileName, n.uploadDate " +
                     "FROM notes n " +
                     "JOIN mentorship m ON n.mentorID = m.mentorID " +
                     "WHERE m.menteeID = ? AND m.status = 'APPROVED'";
        
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, menteeId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("noteID", rs.getInt("noteID"));
                map.put("fileName", rs.getString("fileName"));
                map.put("uploadDate", rs.getTimestamp("uploadDate"));
                list.add(map);
            }
        }
        return list;
    }

    // Download logic
    public Map<String, Object> getNoteFile(int noteId) throws Exception {
        String sql = "SELECT fileName, fileData FROM notes WHERE noteID = ?";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, noteId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> fileMap = new HashMap<>();
                fileMap.put("name", rs.getString("fileName"));
                fileMap.put("data", rs.getBlob("fileData").getBinaryStream());
                return fileMap;
            }
        }
        return null;
    }
    
    // Add this to your NotesDAO.java
    public List<Map<String, Object>> getNotesByMentor(int mentorId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT noteID, fileName, uploadDate FROM notes WHERE mentorID = ?";

        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("noteID", rs.getInt("noteID"));
                map.put("fileName", rs.getString("fileName"));
                map.put("uploadDate", rs.getTimestamp("uploadDate"));
                list.add(map);
            }
        }
        return list;
    }
}
