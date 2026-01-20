package dao;

import controller.DBConn;
import java.sql.*;
import java.util.*;

public class MentorshipDAO {
    
    public List<Map<String, Object>> getPendingApplications(int mentorId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT s.studentID, s.studentName, s.courseCode, s.studentCGPA, s.profilePic " +
                     "FROM mentorship m " +
                     "JOIN student s ON m.menteeID = s.studentID " +
                     "WHERE m.mentorID = ? AND m.status = 'PENDING'";
        
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("studentID"));
                map.put("name", rs.getString("studentName"));
                map.put("course", rs.getString("courseCode"));
                map.put("cgpa", rs.getDouble("studentCGPA"));
                map.put("profilePic", rs.getString("profilePic"));
                list.add(map);
            }
        }
        return list;
    }
    
    public boolean applyForMentorship(int mentorId, int menteeId) throws Exception {
        String sql = "INSERT INTO mentorship (mentorID, menteeID, status) VALUES (?, ?, 'PENDING')";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ps.setInt(2, menteeId);
            return ps.executeUpdate() > 0;
        }
    }
    
    public boolean updateStatus(int mentorId, int menteeId, String status) throws Exception {
        String sql = "UPDATE mentorship SET status = ? WHERE mentorID = ? AND menteeID = ?";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, mentorId);
            ps.setInt(3, menteeId);
            return ps.executeUpdate() > 0;
        }
    }
}