package dao;

import controller.DBConn;
import model.Student;
import java.sql.*;
import java.util.*;

public class StudentDAO {

    // 1. Register a new student
    public boolean register(Student s) throws Exception {
        String sql = "INSERT INTO student (studentID, studentName, studentPhone, studentCGPA, studentRole, studentEmail, studentUsername, studentPassword, courseCode, studentBio, studentAchievements, profilePic) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, s.getStudentID());
            ps.setString(2, s.getStudentName());
            ps.setString(3, (s.getStudentPhone() != null) ? s.getStudentPhone() : "");
            ps.setDouble(4, s.getStudentCGPA());
            ps.setString(5, s.getStudentRole());
            ps.setString(6, (s.getStudentEmail() != null) ? s.getStudentEmail() : "");
            ps.setString(7, s.getStudentUsername());
            ps.setString(8, s.getStudentPassword());
            ps.setString(9, s.getCourseCode());
            ps.setString(10, ""); 
            ps.setString(11, (s.getStudentAchievements() != null) ? s.getStudentAchievements() : "");
            ps.setString(12, ""); 
            return ps.executeUpdate() > 0;
        }
    }

    // 2. Authenticate user for Login
    public Student authenticate(String u, String p) throws Exception {
        String sql = "SELECT * FROM student WHERE studentUsername=? AND studentPassword=?";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u); 
            ps.setString(2, p);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapStudent(rs);
            }
        }
        return null;
    }

    // 3. Get Student by ID
    public Student getStudentById(int id) throws Exception {
        String sql = "SELECT * FROM student WHERE studentID=?";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapStudent(rs);
            }
        }
        return null;
    }

    // 4. Get Accepted Connections
    public List<Map<String, Object>> getAcceptedConnections(Integer userId, String role) throws Exception {
        List<Map<String, Object>> connections = new ArrayList<>();
        String sql;
        if ("Mentor".equals(role)) {
            sql = "SELECT s.studentID, s.studentName, s.profilePic, s.courseCode FROM mentorship m JOIN student s ON m.menteeID = s.studentID WHERE m.mentorID = ? AND m.status = 'APPROVED'";
        } else {
            sql = "SELECT s.studentID, s.studentName, s.profilePic, s.courseCode FROM mentorship m JOIN student s ON m.mentorID = s.studentID WHERE m.menteeID = ? AND m.status = 'APPROVED'";
        }
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("studentID"));
                map.put("name", rs.getString("studentName"));
                map.put("profilePic", rs.getString("profilePic"));
                map.put("courseCode", rs.getString("courseCode"));
                connections.add(map);
            }
        }
        return connections;
    }

    // 5. Apply for Mentorship
    public boolean applyForMentorship(int mentorId, int menteeId) throws Exception {
        String sql = "INSERT INTO mentorship (mentorID, menteeID, status) VALUES (?, ?, 'PENDING')";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ps.setInt(2, menteeId);
            return ps.executeUpdate() > 0;
        }
    }

    // 6. Update Request Status
    public boolean updateRequestStatus(int mentorId, int menteeId, String status) throws Exception {
        String sql = "UPDATE mentorship SET status = ? WHERE mentorID = ? AND menteeID = ?";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, mentorId);
            ps.setInt(3, menteeId);
            return ps.executeUpdate() > 0;
        }
    }

    // 7. Get Pending Requests
    public List<Map<String, Object>> getPendingRequests(int mentorId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT s.studentID, s.studentName, s.courseCode, s.profilePic, m.status FROM mentorship m JOIN student s ON m.menteeID = s.studentID WHERE m.mentorID = ? AND m.status = 'PENDING'";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("menteeId", rs.getInt("studentID"));
                map.put("menteeName", rs.getString("studentName"));
                map.put("courseCode", rs.getString("courseCode"));
                map.put("profilePic", rs.getString("profilePic"));
                map.put("status", rs.getString("status"));
                list.add(map);
            }
        }
        return list;
    }

    // 8. Get All Mentors
    public List<Student> getAllMentors() throws Exception {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM student WHERE studentRole='Mentor'";
        try (Connection con = DBConn.getConnection(); Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapStudent(rs));
            }
        }
        return list;
    }

    // 9. Update Profile
    public boolean updateProfile(Student s) throws Exception {
        String sql = "UPDATE student SET studentName=?, studentPhone=?, studentEmail=?, studentBio=?, studentAchievements=?, profilePic=?, studentCGPA=?, courseCode=? WHERE studentID=?";
        try (Connection con = DBConn.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getStudentName());
            ps.setString(2, s.getStudentPhone());
            ps.setString(3, s.getStudentEmail());
            ps.setString(4, s.getStudentBio());
            ps.setString(5, s.getStudentAchievements());
            ps.setString(6, s.getProfilePic());
            ps.setDouble(7, s.getStudentCGPA());
            ps.setString(8, s.getCourseCode());
            ps.setInt(9, s.getStudentID());
            return ps.executeUpdate() > 0;
        }
    }

    // 10. Get All Courses
    public List<Map<String, String>> getAllCourses() throws Exception {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT * FROM course ORDER BY courseCode ASC";
        try (Connection con = DBConn.getConnection(); Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("code", rs.getString("courseCode"));
                map.put("name", rs.getString("courseName"));
                list.add(map);
            }
        }
        return list;
    }

    /**
     * FULL DELETE: Removes student and all related foreign key data.
     */
    public boolean deleteStudent(int id) throws Exception {
        Connection con = null;
        PreparedStatement psRelated = null;
        PreparedStatement psUser = null;
        try {
            con = DBConn.getConnection();
            con.setAutoCommit(false); // Transaction start

            // First: delete child records to avoid Foreign Key violations
            String sql1 = "DELETE FROM mentorship WHERE mentorID = ? OR menteeID = ?";
            psRelated = con.prepareStatement(sql1);
            psRelated.setInt(1, id);
            psRelated.setInt(2, id);
            psRelated.executeUpdate();

            // Second: delete parent record (the student)
            String sqlFinal = "DELETE FROM student WHERE studentID = ?";
            psUser = con.prepareStatement(sqlFinal);
            psUser.setInt(1, id);
            int rowsDeleted = psUser.executeUpdate();

            con.commit(); // Push to DB
            return rowsDeleted > 0;
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (psRelated != null) psRelated.close();
            if (psUser != null) psUser.close();
            if (con != null) con.close();
        }
    }

    private Student mapStudent(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setStudentID(rs.getInt("studentID"));
        s.setStudentName(rs.getString("studentName"));
        s.setStudentPhone(rs.getString("studentPhone"));
        s.setStudentRole(rs.getString("studentRole"));
        s.setStudentEmail(rs.getString("studentEmail"));
        s.setStudentUsername(rs.getString("studentUsername"));
        s.setStudentPassword(rs.getString("studentPassword"));
        s.setCourseCode(rs.getString("courseCode"));
        s.setStudentBio(rs.getString("studentBio"));
        s.setStudentAchievements(rs.getString("studentAchievements"));
        s.setProfilePic(rs.getString("profilePic"));
        s.setStudentCGPA(rs.getDouble("studentCGPA"));
        return s;
    }
    
    // Method to get a student's approved mentors
    public List<Student> getApprovedMentorsForStudent(int studentId) {
        String sql = "SELECT s.* FROM student s JOIN mentorship m ON s.studentID = m.mentorID "
                + "WHERE m.menteeID = ? AND m.status = 'APPROVED'";
        return getStudentsByQuery(sql, studentId);
    }

// Method to get a mentor's approved mentees
    public List<Student> getApprovedMenteesForMentor(int mentorId) {
        String sql = "SELECT s.* FROM student s JOIN mentorship m ON s.studentID = m.menteeID "
                + "WHERE m.mentorID = ? AND m.status = 'APPROVED'";
        return getStudentsByQuery(sql, mentorId);
    }
    // Helper method to run a query and return a list of Student objects
private List<Student> getStudentsByQuery(String sql, int parameterId) {
    List<Student> list = new ArrayList<>();
    try (Connection conn = DBConn.getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, parameterId);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Student s = new Student();
            s.setStudentID(rs.getInt("studentID"));
            s.setStudentName(rs.getString("studentName"));
            s.setStudentEmail(rs.getString("studentEmail"));
            s.setCourseCode(rs.getString("courseCode"));
            s.setProfilePic(rs.getString("profilePic"));
            // Add any other setters you have in your Student model
            list.add(s);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
}