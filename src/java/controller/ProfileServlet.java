package controller;

import dao.StudentDAO;
import model.Student;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.Base64;

@WebServlet("/ProfileServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 2) // 2MB Limit for profile pictures
public class ProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            StudentDAO dao = new StudentDAO();
            String idStr = request.getParameter("studentID");
            String action = request.getParameter("action");

            if (idStr == null) {
                response.sendRedirect("dashboard.jsp?view=profile&msg=error");
                return;
            }
            int id = Integer.parseInt(idStr);

            // Handle Account Deletion
            if ("delete".equals(action)) {
                if (dao.deleteStudent(id)) {
                    // Force session to end immediately
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        session.invalidate();
                    }
                    response.sendRedirect("login.jsp?msg=deleted");
                } else {
                    response.sendRedirect("dashboard.jsp?view=profile&msg=error");
                }
                return;
            }

            // Original Update logic follows
            Student s = dao.getStudentById(id);
            if (s != null) {
                s.setStudentName(request.getParameter("name"));
                s.setStudentEmail(request.getParameter("email"));
                s.setStudentPhone(request.getParameter("phone"));
                s.setStudentBio(request.getParameter("bio"));
                s.setStudentAchievements(request.getParameter("achievements"));
                
                String courseCode = request.getParameter("courseCode");
                if (courseCode != null && !courseCode.isEmpty()) s.setCourseCode(courseCode);

                String cgpaStr = request.getParameter("cgpa");
                if (cgpaStr != null && !cgpaStr.isEmpty()) s.setStudentCGPA(Double.parseDouble(cgpaStr));
                
                Part filePart = request.getPart("profilePicFile");
                if (filePart != null && filePart.getSize() > 0) {
                    InputStream is = filePart.getInputStream();
                    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                    byte[] data = new byte[4096];
                    int nRead;
                    while ((nRead = is.read(data, 0, data.length)) != -1) { buffer.write(data, 0, nRead); }
                    String base64Image = "data:" + filePart.getContentType() + ";base64," + 
                                         Base64.getEncoder().encodeToString(buffer.toByteArray());
                    s.setProfilePic(base64Image);
                }

                if (dao.updateProfile(s)) {
                    request.getSession().setAttribute("studentName", s.getStudentName());
                    response.sendRedirect("dashboard.jsp?view=profile&msg=success");
                } else {
                    response.sendRedirect("dashboard.jsp?view=profile&msg=error");
                }
            } else {
                response.sendRedirect("dashboard.jsp?view=profile&msg=notfound");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?view=profile&msg=error");
        }
    }
}