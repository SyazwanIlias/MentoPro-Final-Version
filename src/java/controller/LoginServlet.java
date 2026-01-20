package controller;
import dao.StudentDAO;
import model.Student;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String attemptedRole = request.getParameter("role"); // "Mentee" or "Mentor"
            
            StudentDAO dao = new StudentDAO();
            Student s = dao.authenticate(username, password);
            
            if(s != null) {
                // ROLE VALIDATION: Check if account role matches the login panel used
                if(!s.getStudentRole().equals(attemptedRole)) {
                    // Wrong role! User tried to login with wrong panel
                    String errorMsg = "This account is registered as " + s.getStudentRole() + 
                                    ". Please use the " + s.getStudentRole() + " login panel.";
                    response.sendRedirect("login.jsp?error=" + URLEncoder.encode(errorMsg, "UTF-8") + 
                                        "&role=" + attemptedRole);
                    return;
                }
                
                // Correct role - proceed with login
                HttpSession session = request.getSession();
                session.setAttribute("studentID", s.getStudentID());
                session.setAttribute("studentName", s.getStudentName());
                session.setAttribute("studentRole", s.getStudentRole());
                response.sendRedirect("dashboard.jsp");
            } else {
                // Invalid credentials
                response.sendRedirect("login.jsp?error=" + URLEncoder.encode("Invalid username or password", "UTF-8") + 
                                    "&role=" + attemptedRole);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=" + URLEncoder.encode("An error occurred. Please try again.", "UTF-8"));
        }
    }
}