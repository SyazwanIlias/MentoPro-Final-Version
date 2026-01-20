package controller;

import dao.StudentDAO;
import model.Student;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
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
            // ACTION: Request Mentorship (Applied by Mentee ONLY)
            if ("apply".equals(action) || "request".equals(action)) {
                // Validate that only Mentees can apply
                if (!"Mentee".equals(currentRole)) {
                    String errorMsg = URLEncoder.encode("Only mentees can apply for mentorship", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=mentors&msg=" + errorMsg + "&status=error");
                    return;
                }
                
                int mentorId = Integer.parseInt(request.getParameter("mentorId"));
                
                // Check current request status
                String currentStatus = dao.getRequestStatus(mentorId, currentId);
                
                if (currentStatus != null) {
                    if ("PENDING".equals(currentStatus)) {
                        String errorMsg = URLEncoder.encode("You have already sent a request to this mentor", "UTF-8");
                        response.sendRedirect("dashboard.jsp?view=mentors&msg=" + errorMsg + "&status=error");
                        return;
                    } else if ("APPROVED".equals(currentStatus)) {
                        String errorMsg = URLEncoder.encode("You are already connected with this mentor", "UTF-8");
                        response.sendRedirect("dashboard.jsp?view=connections&msg=" + errorMsg + "&status=error");
                        return;
                    } else if ("REJECTED".equals(currentStatus)) {
                        // Allow reapplication - update the existing rejected request to PENDING
                        if (dao.updateRequestStatus(mentorId, currentId, "PENDING")) {
                            String successMsg = URLEncoder.encode("Mentorship request sent again successfully!", "UTF-8");
                            response.sendRedirect("dashboard.jsp?view=mentors&msg=" + successMsg + "&status=success");
                        } else {
                            String errorMsg = URLEncoder.encode("Failed to send request. Please try again.", "UTF-8");
                            response.sendRedirect("dashboard.jsp?view=mentors&msg=" + errorMsg + "&status=error");
                        }
                        return;
                    }
                }
                
                // No existing request - create new one
                if (dao.applyForMentorship(mentorId, currentId)) {
                    String successMsg = URLEncoder.encode("Mentorship request sent successfully!", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=mentors&msg=" + successMsg + "&status=success");
                } else {
                    String errorMsg = URLEncoder.encode("Failed to send request. Please try again.", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=mentors&msg=" + errorMsg + "&status=error");
                }
            } 
            
            // ACTION: Approve Request (Done by Mentor ONLY)
            else if ("approve".equals(action)) {
                // Validate that only Mentors can approve
                if (!"Mentor".equals(currentRole)) {
                    String errorMsg = URLEncoder.encode("Only mentors can approve requests", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=mentors&msg=" + errorMsg + "&status=error");
                    return;
                }
                
                int menteeId = Integer.parseInt(request.getParameter("menteeId"));
                int mentorId = Integer.parseInt(request.getParameter("mentorId"));
                
                // Verify the mentor is approving their own request
                if (mentorId != currentId) {
                    String errorMsg = URLEncoder.encode("You can only approve requests sent to you", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=requests&msg=" + errorMsg + "&status=error");
                    return;
                }
                
                if (dao.updateRequestStatus(mentorId, menteeId, "APPROVED")) {
                    String successMsg = URLEncoder.encode("Request approved successfully!", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=requests&msg=" + successMsg + "&status=success");
                } else {
                    String errorMsg = URLEncoder.encode("Failed to approve request", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=requests&msg=" + errorMsg + "&status=error");
                }
            } 
            
            // ACTION: Reject Request (Done by Mentor ONLY)
            else if ("reject".equals(action)) {
                // Validate that only Mentors can reject
                if (!"Mentor".equals(currentRole)) {
                    String errorMsg = URLEncoder.encode("Only mentors can reject requests", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=mentors&msg=" + errorMsg + "&status=error");
                    return;
                }
                
                int menteeId = Integer.parseInt(request.getParameter("menteeId"));
                int mentorId = Integer.parseInt(request.getParameter("mentorId"));
                
                // Verify the mentor is rejecting their own request
                if (mentorId != currentId) {
                    String errorMsg = URLEncoder.encode("You can only reject requests sent to you", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=requests&msg=" + errorMsg + "&status=error");
                    return;
                }
                
                if (dao.updateRequestStatus(mentorId, menteeId, "REJECTED")) {
                    String successMsg = URLEncoder.encode("Request rejected", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=requests&msg=" + successMsg + "&status=success");
                } else {
                    String errorMsg = URLEncoder.encode("Failed to reject request", "UTF-8");
                    response.sendRedirect("dashboard.jsp?view=requests&msg=" + errorMsg + "&status=error");
                }
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
                request.getRequestDispatcher("myConnections.jsp").forward(request, response);
            }
            
            else {
                response.sendRedirect("dashboard.jsp");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = URLEncoder.encode("An error occurred: " + e.getMessage(), "UTF-8");
            response.sendRedirect("dashboard.jsp?msg=" + errorMsg + "&status=error");
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}