package controller;

import dao.NotesDAO;
import java.io.*;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/NotesServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class NotesServlet extends HttpServlet {

    // Handling Mentor Upload
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer mentorId = (Integer) session.getAttribute("studentID"); //
        
        Part filePart = request.getPart("noteFile");
        if (filePart != null && mentorId != null) {
            try {
                String fileName = filePart.getSubmittedFileName();
                InputStream is = filePart.getInputStream();
                
                NotesDAO dao = new NotesDAO();
                if (dao.uploadNote(mentorId, fileName, is)) {
                    response.sendRedirect("dashboard.jsp?msg=UploadSuccess");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("dashboard.jsp?msg=UploadError");
            }
        }
    }

    // Handling Mentee Download
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam != null) {
            try {
                NotesDAO dao = new NotesDAO();
                Map<String, Object> file = dao.getNoteFile(Integer.parseInt(idParam));
                
                if (file != null) {
                    String fileName = (String) file.get("name");
                    InputStream is = (InputStream) file.get("data");
                    
                    response.setContentType("application/octet-stream");
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                    
                    OutputStream os = response.getOutputStream();
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = is.read(buffer)) != -1) {
                        os.write(buffer, 0, bytesRead);
                    }
                    is.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}