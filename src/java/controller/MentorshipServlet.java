package controller;

import dao.StudentDAO;
import model.Student;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/MentorshipServlet")
public class MentorshipServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
        // 1. Get current user info from session
        Integer currentId = (Integer) session.getAttribute("studentID");
        String currentRole = (String) session.getAttribute("studentRole");
        
        // Safety check: if session is lost, redirect to login
        if (currentId == null) {
            response.sendRedirect("login.jsp?msg=session_expired");
            return;
        }

        StudentDAO dao = new StudentDAO();

        try {
            // ACTION: Request Mentorship (Applied by Mentee)
            if ("apply".equals(action) || "request".equals(action)) {
                int mentorId = Integer.parseInt(request.getParameter("mentorId"));
                dao.applyForMentorship(mentorId, currentId);
                response.sendRedirect("dashboard.jsp?view=mentors&status=applied");
            } 
            
            // ACTION: Approve Request (Done by Mentor)
            else if ("approve".equals(action)) {
                int menteeId = Integer.parseInt(request.getParameter("menteeId"));
                dao.updateRequestStatus(currentId, menteeId, "APPROVED");
                response.sendRedirect("dashboard.jsp?view=requests&status=success");
            } 
            
            // ACTION: Reject Request (Done by Mentor)
            else if ("reject".equals(action)) {
                int menteeId = Integer.parseInt(request.getParameter("menteeId"));
                dao.updateRequestStatus(currentId, menteeId, "REJECTED");
                response.sendRedirect("dashboard.jsp?view=requests&status=removed");
            }

            // ACTION: View My Mentors or My Mentees (Approved Connections)
            else if ("viewConnections".equals(action)) {
                List<Student> connections;
                
                if ("Mentor".equals(currentRole)) {
                    // If user is a Mentor, they see their approved Mentees
                    connections = dao.getApprovedMenteesForMentor(currentId);
                    request.setAttribute("connectionTitle", "My Mentees");
                } else {
                    // If user is a Mentee, they see their approved Mentors
                    connections = dao.getApprovedMentorsForStudent(currentId);
                    request.setAttribute("connectionTitle", "My Mentors");
                }
                
                request.setAttribute("connectionList", connections);
                // Forwarding to the display page
                request.getRequestDispatcher("myConnections.jsp").forward(request, response);
            }
            
            else {
                response.sendRedirect("dashboard.jsp");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?msg=error");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}