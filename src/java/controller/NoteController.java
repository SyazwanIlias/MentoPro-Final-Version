package controller;

import dao.StudentDAO;
import model.Note;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "NoteController", urlPatterns = {"/NoteController"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // Limit to 10MB
public class NoteController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("download".equals(action)) {
            try {
                int noteId = Integer.parseInt(request.getParameter("id"));
                StudentDAO dao = new StudentDAO();
                Note note = dao.getNoteById(noteId);

                if (note != null && note.getFileData() != null) {
                    response.setContentType(note.getFileType());
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + note.getFileName() + "\"");
                    
                    try (OutputStream out = response.getOutputStream()) {
                        out.write(note.getFileData());
                    }
                }
            } catch (Exception e) {
                response.sendRedirect("dashboard.jsp?view=notes&status=error");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("upload".equals(action)) {
            try {
                int mentorId = (int) request.getSession().getAttribute("studentID");
                Part filePart = request.getPart("file");
                
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = filePart.getSubmittedFileName();
                    String fileType = filePart.getContentType();
                    
                    // Read file data into byte array using native Java logic (no external library needed)
                    byte[] fileData = new byte[(int) filePart.getSize()];
                    try (InputStream inputStream = filePart.getInputStream()) {
                        int bytesRead = 0;
                        int offset = 0;
                        while (offset < fileData.length && (bytesRead = inputStream.read(fileData, offset, fileData.length - offset)) != -1) {
                            offset += bytesRead;
                        }
                    }
                    
                    StudentDAO dao = new StudentDAO();
                    boolean success = dao.uploadNote(mentorId, fileName, fileType, fileData);
                    
                    if (success) {
                        response.sendRedirect("dashboard.jsp?view=notes&status=uploaded");
                    } else {
                        response.sendRedirect("dashboard.jsp?view=notes&status=fail");
                    }
                }
            } catch (Exception e) {
                response.sendRedirect("dashboard.jsp?view=notes&status=error");
            }
        }
    }
}