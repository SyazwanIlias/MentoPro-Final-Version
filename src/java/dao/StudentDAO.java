package dao;

import controller.DBConn;
import model.Student;
import java.sql.*;
import java.util.*;

/**
 * StudentDAO handles all database operations related to the Student and Mentorship tables.
 */
public class StudentDAO {

    public Student authenticate(String username, String password) throws Exception {
        String sql = "SELECT * FROM student WHERE studentUsername = ? AND studentPassword = ?";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStudent(rs);
                }
            }
        }
        return null;
    }

    /**
     * Register a new student into the database
     */
    public boolean register(Student s) throws Exception {
        String sql = "INSERT INTO student (studentID, studentName, studentUsername, studentPassword, " +
                     "studentRole, studentEmail, studentCGPA, courseCode, studentAchievements, " +
                     "profilePic, studentBio, studentPhone) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, s.getStudentID());
            ps.setString(2, s.getStudentName());
            ps.setString(3, s.getStudentUsername());
            ps.setString(4, s.getStudentPassword());
            ps.setString(5, s.getStudentRole());
            ps.setString(6, s.getStudentEmail());
            ps.setDouble(7, s.getStudentCGPA());
            ps.setString(8, s.getCourseCode());
            ps.setString(9, s.getStudentAchievements());
            ps.setString(10, s.getProfilePic());
            ps.setString(11, s.getStudentBio());
            ps.setString(12, s.getStudentPhone());
            return ps.executeUpdate() > 0;
        }
    }

    // --- MENTORSHIP LOGIC (MENTEE PERSPECTIVE) ---

    /**
     * Get list of mentors with their specific request status for a mentee.
     * Excludes mentors where the status is already 'APPROVED'.
     */
    public List<Map<String, Object>> getMentorsForMenteeOverview(int menteeId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        // Logic: Get all mentors and LEFT JOIN mentorship to see if this mentee has a relationship with them
        String sql = "SELECT s.*, m.status "
                + "FROM student s "
                + "LEFT JOIN mentorship m ON s.studentID = m.mentorID AND m.menteeID = ? "
                + "WHERE s.studentRole = 'Mentor' "
                + "AND (m.status IS NULL OR m.status != 'APPROVED')";

        try (Connection con = DBConn.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, menteeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("student", mapStudent(rs));
                    map.put("requestStatus", rs.getString("status")); // NULL, PENDING, or REJECTED
                    list.add(map);
                }
            }
        }
        return list;
    }

    /**
     * Get the current mentorship status between a specific mentor and mentee
     */
    public String getRequestStatus(int mentorId, int menteeId) throws Exception {
        String sql = "SELECT status FROM mentorship WHERE mentorID = ? AND menteeID = ?";
        try (Connection con = DBConn.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ps.setInt(2, menteeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        }
        return null;
    }

    /**
     * Check if any request exists regardless of status
     */
    public boolean hasExistingRequest(int mentorId, int menteeId) throws Exception {
        return getRequestStatus(mentorId, menteeId) != null;
    }

    /**
     * Submit a new mentorship application
     */
    public boolean applyForMentorship(int mentorId, int menteeId) throws Exception {
        String sql = "INSERT INTO mentorship (mentorID, menteeID, status, requestDate) VALUES (?, ?, 'PENDING', CURRENT_TIMESTAMP)";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ps.setInt(2, menteeId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Reset a rejected request back to PENDING
     */
    public boolean reapplyForMentorship(int mentorId, int menteeId) throws Exception {
        String deleteSql = "DELETE FROM mentorship WHERE mentorID = ? AND menteeID = ? AND status = 'REJECTED'";
        String insertSql = "INSERT INTO mentorship (mentorID, menteeID, status, requestDate) VALUES (?, ?, 'PENDING', CURRENT_TIMESTAMP)";
        
        Connection con = null;
        try {
            con = DBConn.getConnection();
            con.setAutoCommit(false);
            
            try (PreparedStatement psDel = con.prepareStatement(deleteSql)) {
                psDel.setInt(1, mentorId);
                psDel.setInt(2, menteeId);
                psDel.executeUpdate();
            }
            
            try (PreparedStatement psIns = con.prepareStatement(insertSql)) {
                psIns.setInt(1, mentorId);
                psIns.setInt(2, menteeId);
                psIns.executeUpdate();
            }
            
            con.commit();
            return true;
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    // --- MENTORSHIP LOGIC (MENTOR PERSPECTIVE) ---

    /**
     * Get list of mentees who have sent a pending request
     */
    public List<Map<String, Object>> getPendingRequests(int mentorId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT s.studentID, s.studentName, s.courseCode, s.studentCGPA, s.profilePic " +
                     "FROM mentorship m " +
                     "JOIN student s ON m.menteeID = s.studentID " +
                     "WHERE m.mentorID = ? AND m.status = 'PENDING'";
        
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("menteeId", rs.getInt("studentID"));
                    map.put("menteeName", rs.getString("studentName"));
                    map.put("courseCode", rs.getString("courseCode"));
                    map.put("cgpa", rs.getDouble("studentCGPA"));
                    map.put("profilePic", rs.getString("profilePic"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    /**
     * Approve or Reject a request
     */
    public boolean updateRequestStatus(int mentorId, int menteeId, String status) throws Exception {
        String sql = "UPDATE mentorship SET status = ? WHERE mentorID = ? AND menteeID = ?";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, mentorId);
            ps.setInt(3, menteeId);
            return ps.executeUpdate() > 0;
        }
    }

    // --- PROFILE & GENERAL QUERIES ---

    public Student getStudentById(int id) throws Exception {
        String sql = "SELECT * FROM student WHERE studentID = ?";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapStudent(rs);
            }
        }
        return null;
    }

    public List<Student> getAllMentorsExcludingSelf(int currentUserId) throws Exception {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM student WHERE studentRole = 'Mentor' AND studentID != ?";
        try (Connection con = DBConn.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapStudent(rs));
            }
        }
        return list;
    }

    public List<Student> getApprovedMenteesForMentor(int mentorId) throws Exception {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT s.* FROM mentorship m JOIN student s ON m.menteeID = s.studentID " +
                     "WHERE m.mentorID = ? AND m.status = 'APPROVED'";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapStudent(rs));
            }
        }
        return list;
    }

    public List<Student> getApprovedMentorsForStudent(int menteeId) throws Exception {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT s.* FROM mentorship m JOIN student s ON m.mentorID = s.studentID " +
                     "WHERE m.menteeID = ? AND m.status = 'APPROVED'";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, menteeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapStudent(rs));
            }
        }
        return list;
    }

    public boolean updateProfile(Student s) throws Exception {
        String sql = "UPDATE student SET studentName = ?, studentEmail = ?, studentPhone = ?, " +
                     "studentCGPA = ?, courseCode = ?, studentBio = ?, studentAchievements = ?, " +
                     "profilePic = ? WHERE studentID = ?";
        try (Connection con = DBConn.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getStudentName());
            ps.setString(2, s.getStudentEmail());
            ps.setString(3, s.getStudentPhone());
            ps.setDouble(4, s.getStudentCGPA());
            ps.setString(5, s.getCourseCode());
            ps.setString(6, s.getStudentBio());
            ps.setString(7, s.getStudentAchievements());
            ps.setString(8, s.getProfilePic());
            ps.setInt(9, s.getStudentID());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteStudent(int studentId) throws Exception {
        Connection con = null;
        try {
            con = DBConn.getConnection();
            con.setAutoCommit(false);
            
            // Delete mentorship records first
            String deleteMentorship = "DELETE FROM mentorship WHERE mentorID = ? OR menteeID = ?";
            try (PreparedStatement ps = con.prepareStatement(deleteMentorship)) {
                ps.setInt(1, studentId);
                ps.setInt(2, studentId);
                ps.executeUpdate();
            }
            
            String deleteStudent = "DELETE FROM student WHERE studentID = ?";
            try (PreparedStatement ps = con.prepareStatement(deleteStudent)) {
                ps.setInt(1, studentId);
                ps.executeUpdate();
            }
            
            con.commit();
            return true;
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    public List<Map<String, String>> getAllCourses() throws Exception {
        List<Map<String, String>> courses = new ArrayList<>();
        String sql = "SELECT courseCode, courseName FROM course";
        try (Connection con = DBConn.getConnection(); 
             Statement stmt = con.createStatement(); 
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, String> course = new HashMap<>();
                course.put("code", rs.getString("courseCode"));
                course.put("name", rs.getString("courseName"));
                courses.add(course);
            }
        }
        return courses;
    }

    // --- HELPER METHOD ---

    private Student mapStudent(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setStudentID(rs.getInt("studentID"));
        s.setStudentName(rs.getString("studentName"));
        s.setStudentUsername(rs.getString("studentUsername"));
        s.setStudentPassword(rs.getString("studentPassword"));
        s.setStudentRole(rs.getString("studentRole"));
        s.setStudentEmail(rs.getString("studentEmail"));
        s.setStudentPhone(rs.getString("studentPhone"));
        s.setStudentCGPA(rs.getDouble("studentCGPA"));
        s.setCourseCode(rs.getString("courseCode"));
        s.setStudentBio(rs.getString("studentBio"));
        s.setStudentAchievements(rs.getString("studentAchievements"));
        s.setProfilePic(rs.getString("profilePic"));
        return s;
    }
}