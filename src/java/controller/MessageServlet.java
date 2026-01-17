package controller;

import dao.MessageDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MessageServlet")
public class MessageServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer senderId = (Integer) session.getAttribute("studentID");

        if (senderId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // DECLARE THESE VARIABLES BEFORE USING THEM
        String receiverIdStr = request.getParameter("receiverId");
        String content = request.getParameter("message");

        if (receiverIdStr != null && content != null && !content.trim().isEmpty()) {
            try {
                // 1. Initialize receiverId by parsing the string from the form
                int receiverId = Integer.parseInt(receiverIdStr);

                // 2. Initialize the dao
                dao.MessageDAO mDao = new dao.MessageDAO();

                // 3. Use the initialized variables
                if (mDao.sendMessage(senderId, receiverId, content)) {
                    // Success redirect
                    response.sendRedirect("dashboard.jsp?view=messages&msg=Message+sent+successfully&status=success");
                } else {
                    // Database error redirect
                    response.sendRedirect("dashboard.jsp?view=messages&msg=Database+error&status=error");
                }
            } catch (Exception e) {
                response.sendRedirect("dashboard.jsp?view=messages&msg=Invalid+Receiver&status=error");
            }
        } else {
            response.sendRedirect("dashboard.jsp?view=messages&msg=Message+cannot+be+empty&status=error");
        }
    }
}