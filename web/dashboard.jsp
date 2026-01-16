<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.StudentDAO, model.Student, java.util.*" %>
<%
    if (session.getAttribute("studentName") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Integer currentId = (Integer) session.getAttribute("studentID");
    String currentRole = (String) session.getAttribute("studentRole");
    String view = request.getParameter("view");
    if (view == null) view = "mentors";

    StudentDAO sDao = new StudentDAO();
    Student me = sDao.getStudentById(currentId);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard | MentoPro</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', sans-serif; }
        body { background: #f8fafc; color: #1e293b; overflow-x: hidden; }

        .sidebar { 
            width: 260px; 
            height: 100vh; 
            background: #ffffff; 
            position: fixed; 
            left: 0; 
            top: 0; 
            padding: 20px; 
            border-right: 1px solid rgba(0,0,0,0.05); 
            display: flex; 
            flex-direction: column; 
            z-index: 100; 
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .sidebar.collapsed { width: 80px; padding: 20px 10px; }
        
        .sidebar-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 40px;
            transition: all 0.3s;
        }

        .sidebar.collapsed .sidebar-header {
            flex-direction: column;
            gap: 15px;
        }

        .sidebar.collapsed .logo span, 
        .sidebar.collapsed .nav-links a span,
        .sidebar.collapsed .sign-out-text { 
            display: none; 
        }

        .logo { font-size: 24px; font-weight: 800; color: #6366f1; display: flex; align-items: center; gap: 10px; white-space: nowrap; overflow: hidden; }
        
        .toggle-sidebar { 
            background: #f1f5f9; 
            border: none; 
            width: 35px;
            height: 35px;
            border-radius: 8px; 
            cursor: pointer; 
            color: #64748b; 
            display: flex;
            align-items: center;
            justify-content: center;
            transition: 0.2s;
        }
        .toggle-sidebar:hover { background: #e2e8f0; color: #6366f1; }

        .nav-links { list-style: none; flex-grow: 1; }
        .nav-links li { margin-bottom: 8px; }
        .nav-links a { display: flex; align-items: center; gap: 12px; padding: 12px 15px; border-radius: 10px; color: #64748b; transition: 0.3s; font-weight: 500; text-decoration: none; white-space: nowrap; }
        .nav-links a:hover, .nav-links a.active { background: #6366f1; color: #ffffff; }
        .sidebar.collapsed .nav-links a { justify-content: center; padding: 12px; }

        .top-bar { 
            position: fixed; 
            top: 0; 
            left: 260px; 
            right: 0; 
            height: 70px; 
            background: rgba(255, 255, 255, 0.9); 
            backdrop-filter: blur(10px); 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            padding: 0 40px; 
            z-index: 90; 
            border-bottom: 1px solid rgba(0,0,0,0.05); 
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .sidebar.collapsed + .top-bar { left: 80px; }

        .content { 
            margin-left: 260px; 
            padding: 100px 40px 40px 40px; 
            min-height: 100vh; 
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .sidebar.collapsed ~ .content { margin-left: 80px; }

        .search-container {
            position: relative;
            margin-bottom: 30px;
            max-width: 500px;
        }
        .search-input {
            width: 100%;
            padding: 15px 20px 15px 50px;
            border-radius: 15px;
            border: 1px solid #e2e8f0;
            background: white;
            font-size: 16px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            transition: all 0.3s;
        }
        .search-input:focus {
            outline: none;
            border-color: #6366f1;
            box-shadow: 0 10px 15px -3px rgba(99, 102, 241, 0.1);
        }
        .search-icon {
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }

        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 25px; }
        .m-card { background: #ffffff; border-radius: 20px; padding: 25px; text-align: center; border: 1px solid rgba(0,0,0,0.02); transition: 0.3s; cursor: pointer; }
        .m-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        .m-card.hidden { display: none; }
        
        .m-avatar { width: 80px; height: 80px; border-radius: 50%; margin: 0 auto 15px; background: #6366f1; display: flex; align-items: center; justify-content: center; font-size: 28px; color: white; overflow: hidden; border: 3px solid white; box-shadow: 0 4px 10px rgba(0,0,0,0.1); position: relative; }
        .m-avatar img { width: 100%; height: 100%; object-fit: cover; }
        
        .btn { padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; border: none; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; font-size: 14px; transition: 0.2s; }
        .btn-primary { background: #6366f1; color: white; }
        .btn-success { background: #10b981; color: white; }
        .btn-danger { background: #f87171; color: white; }
        .btn-outline { border: 1px solid #e2e8f0; color: #64748b; background: white; }
        
        .detail-box { background: white; padding: 40px; border-radius: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.04); max-width: 900px; margin: 0 auto; }
        .request-table { width: 100%; border-collapse: separate; border-spacing: 0 10px; margin-top: 20px; }
        .request-table th { padding: 12px 20px; text-align: left; color: #94a3b8; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        .request-table tr td { background: white; padding: 15px 20px; transition: 0.2s; }
        .request-table tr td:first-child { border-radius: 12px 0 0 12px; }
        .request-table tr td:last-child { border-radius: 0 12px 12px 0; }
        
        .small-avatar { width: 45px; height: 45px; border-radius: 50%; overflow: hidden; background: #6366f1; color: white; display: flex; align-items: center; justify-content: center; font-size: 18px; border: 2px solid white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .small-avatar img { width: 100%; height: 100%; object-fit: cover; }
        
        .info-pill { padding: 4px 12px; background: #eef2ff; color: #6366f1; border-radius: 20px; font-size: 12px; font-weight: 600; }
        input, textarea, select { width: 100%; padding: 12px; border: 1px solid #e2e8f0; border-radius: 10px; outline-color: #6366f1; }
        label { display: block; font-size: 11px; font-weight: 800; color: #94a3b8; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }

        /* CHAT PAGE SPECIFIC STYLES */
        .chat-container {
            display: flex;
            height: calc(100vh - 180px);
            background: white;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
        }
        .chat-sidebar {
            width: 320px;
            border-right: 1px solid #f1f5f9;
            display: flex;
            flex-direction: column;
        }
        .chat-list {
            flex-grow: 1;
            overflow-y: auto;
        }
        .chat-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px 20px;
            cursor: pointer;
            transition: 0.2s;
            border-bottom: 1px solid #f8fafc;
        }
        .chat-item:hover { background: #f8fafc; }
        .chat-item.active { background: #eef2ff; border-left: 4px solid #6366f1; }
        
        .chat-main {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background: #fff;
        }
        .chat-header {
            padding: 15px 25px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .chat-messages {
            flex-grow: 1;
            padding: 25px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
            background: #f8fafc;
        }
        .message {
            max-width: 70%;
            padding: 12px 18px;
            border-radius: 18px;
            font-size: 14px;
            line-height: 1.5;
        }
        .message.received {
            align-self: flex-start;
            background: white;
            color: #1e293b;
            border-bottom-left-radius: 2px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.02);
        }
        .message.sent {
            align-self: flex-end;
            background: #6366f1;
            color: white;
            border-bottom-right-radius: 2px;
        }
        .chat-input-area {
            padding: 20px;
            border-top: 1px solid #f1f5f9;
            display: flex;
            gap: 15px;
            align-items: center;
        }
        .chat-input-area input {
            flex-grow: 1;
            border: 1px solid #e2e8f0;
            padding: 12px 20px;
            border-radius: 12px;
            background: #f8fafc;
        }
        
        /* Notification Toast Styles */
.notification-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
}

.toast {
    background: white;
    padding: 15px 25px;
    border-radius: 12px;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 10px;
    border-left: 4px solid #6366f1; /* Primary Blue */
    animation: slideIn 0.3s ease-out forwards;
}

.toast.success { border-left-color: #10b981; } /* Success Green */
.toast.error { border-left-color: #f87171; }   /* Error Red */

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}

.toast-fade-out {
    animation: fadeOut 0.5s ease-in forwards;
}

@keyframes fadeOut {
    to { opacity: 0; transform: translateY(-20px); }
}
    </style>
</head>
<body>
<div id="notifContainer" class="notification-container"></div>
<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <div class="logo">
            <i class="fa-solid fa-graduation-cap"></i>
            <span>MentoPro</span>
        </div>
        <button class="toggle-sidebar" onclick="toggleSidebar()">
            <i class="fa-solid fa-bars"></i>
        </button>
    </div>
    <ul class="nav-links">
        <li>
            <a href="dashboard.jsp?view=mentors" class="<%= view.equals("mentors") || view.equals("mentor_detail") ? "active" : "" %>">
                <i class="fa-solid fa-house"></i>
                <span>Overview</span>
            </a>
        </li>
        <% if ("Mentor".equals(currentRole)) { %>
        <li>
            <a href="dashboard.jsp?view=requests" class="<%= view.equals("requests") || view.equals("mentee_detail") ? "active" : "" %>">
                <i class="fa-solid fa-bell"></i>
                <span>Pending Requests</span>
            </a>
        </li>
        <% } %>
        <li>
            <a href="dashboard.jsp?view=messages" class="<%= view.equals("messages") ? "active" : "" %>">
                <i class="fa-solid fa-comment-dots"></i>
                <span>Messages</span>
            </a>
        </li>
        <li>
            <a href="dashboard.jsp?view=profile" class="<%= view.equals("profile") ? "active" : "" %>">
                <i class="fa-solid fa-user"></i>
                <span>My Profile</span>
            </a>
        </li>
    </ul>
    <a href="LogoutServlet" style="text-decoration: none; margin-top: auto;">
        <div style="padding: 12px 15px; color: #f87171; font-weight: 600; display: flex; align-items: center; gap: 12px;">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
            <span class="sign-out-text">Sign Out</span>
        </div>
    </a>
</div>

<div class="top-bar">
    <div style="display: flex; align-items: center;">
        <h2 style="font-size: 18px; font-weight: 700;">Welcome back, <%= me.getStudentName() %></h2>
    </div>
    <div style="display: flex; align-items: center; gap: 15px;">
        <div style="text-align: right;">
            <div style="font-weight: 600; font-size: 14px;"><%= me.getStudentName() %></div>
            <div style="font-size: 11px; color: #6366f1; font-weight: 700;"><%= currentRole.toUpperCase() %></div>
        </div>
        <div class="small-avatar" style="width: 40px; height: 40px;">
            <% if (me.getProfilePic() != null && !me.getProfilePic().isEmpty()) { %><img src="<%= me.getProfilePic() %>"><% } else { %><%= me.getStudentName().substring(0,1) %><% } %>
        </div>
    </div>
</div>

<div class="content">
    <% if (view.equals("mentors")) { %>
        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 20px;">
            <h2 style="margin-bottom: 25px;">Find a Mentor</h2>
            <div class="search-container">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" id="mentorSearch" class="search-input" placeholder="Search by name or course code..." onkeyup="filterMentors()">
            </div>
        </div>

        <div class="grid" id="mentorGrid">
            <% for (Student s : sDao.getAllMentors()) { if (s.getStudentID() == currentId) continue; %>
                <div class="m-card mentor-item" 
                     data-name="<%= s.getStudentName().toLowerCase() %>" 
                     data-course="<%= s.getCourseCode().toLowerCase() %>"
                     onclick="location.href='dashboard.jsp?view=mentor_detail&mid=<%= s.getStudentID() %>'">
                    <div class="m-avatar">
                        <% if (s.getProfilePic() != null && !s.getProfilePic().isEmpty()) { %><img src="<%= s.getProfilePic() %>"><% } else { %><%= s.getStudentName().substring(0, 1) %><% } %>
                    </div>
                    <h3 class="mentor-name" style="font-size: 18px; margin-bottom: 5px;"><%= s.getStudentName() %></h3>
                    <span class="info-pill mentor-course"><%= s.getCourseCode() %></span>
                </div>
            <% } %>
        </div>

        <div id="noResults" style="display: none; text-align: center; padding: 50px; color: #94a3b8;">
            <i class="fa-solid fa-user-slash" style="font-size: 48px; margin-bottom: 10px;"></i>
            <p>No mentors found matching your search.</p>
        </div>

    <% } else if (view.equals("mentor_detail")) { 
        int mid = Integer.parseInt(request.getParameter("mid"));
        Student mentor = sDao.getStudentById(mid);
    %>
        <a href="dashboard.jsp?view=mentors" class="btn btn-outline" style="margin-bottom: 20px;"><i class="fa-solid fa-arrow-left"></i> Back to Mentors</a>
        <div class="detail-box">
            <div style="display: flex; gap: 40px; align-items: flex-start;">
                <div class="m-avatar" style="width: 150px; height: 150px; margin: 0; font-size: 60px;">
                    <% if (mentor.getProfilePic() != null && !mentor.getProfilePic().isEmpty()) { %><img src="<%= mentor.getProfilePic() %>"><% } else { %><%= mentor.getStudentName().substring(0,1) %><% } %>
                </div>
                <div style="flex-grow: 1;">
                    <h1 style="font-size: 32px; margin-bottom: 5px;"><%= mentor.getStudentName() %></h1>
                    <div style="display: flex; gap: 10px; margin-bottom: 20px;">
                        <span class="info-pill"><%= mentor.getCourseCode() %></span>
                        <span class="info-pill" style="background: #eef2ff; color: #6366f1;">VERIFIED MENTOR</span>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 25px;">
                        <div style="padding: 15px; background: #f8fafc; border-radius: 12px;">
                            <label>Email Address</label>
                            <div style="font-size: 14px; font-weight: 600;"><%= mentor.getStudentEmail() %></div>
                        </div>
                         <div style="padding: 15px; background: #f8fafc; border-radius: 12px;">
                            <label>Phone Number</label>
                            <div style="font-size: 14px; font-weight: 600;"><%= mentor.getStudentPhone() %></div>
                        </div>
                    </div>

                    <div style="margin-bottom: 25px;">
                        <label>Professional Bio</label>
                        <p style="line-height: 1.6;"><%= (mentor.getStudentBio()!=null && !mentor.getStudentBio().isEmpty())?mentor.getStudentBio():"No bio provided." %></p>
                    </div>

                    <div style="margin-bottom: 25px;">
                        <label>Expertise & Achievements</label>
                        <p style="line-height: 1.6;"><%= (mentor.getStudentAchievements()!=null && !mentor.getStudentAchievements().isEmpty())?mentor.getStudentAchievements():"No achievements listed." %></p>
                    </div>

                    <div style="display: flex; gap: 12px; margin-top: 30px; border-top: 1px solid #f1f5f9; padding-top: 25px;">
                        <a href="MentorshipServlet?action=request&mentorId=<%= mentor.getStudentID() %>&menteeId=<%= currentId %>" class="btn btn-primary" style="padding: 12px 30px;">
                            <i class="fa-solid fa-paper-plane"></i> Request Mentorship
                        </a>
                        <a href="dashboard.jsp?view=messages" class="btn btn-outline" style="padding: 12px 30px;">
                            <i class="fa-solid fa-message"></i> Message
                        </a>
                    </div>
                </div>
            </div>
        </div>

    <% } else if (view.equals("requests")) { %>
        <h2 style="margin-bottom: 25px;">Pending Requests</h2>
        <div class="detail-box" style="max-width: 1000px; padding: 20px;">
            <table class="request-table">
                <thead>
                    <tr>
                        <th>Mentee</th>
                        <th>Course Code</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    List<Map<String, Object>> requests = sDao.getPendingRequests(currentId);
                    if (requests.isEmpty()) { 
                    %>
                    <tr><td colspan="3" style="text-align: center; padding: 50px; color: #94a3b8;">No pending requests.</td></tr>
                    <% } else { for (Map<String, Object> req : requests) { %>
                    <tr>
                        <td style="display: flex; align-items: center; gap: 15px; cursor: pointer;" onclick="location.href='dashboard.jsp?view=mentee_detail&mid=<%= req.get("menteeId") %>'">
                            <div class="small-avatar">
                                <% String pic = (String)req.get("profilePic"); if (pic != null && !pic.isEmpty()) { %><img src="<%= pic %>"><% } else { %><%= ((String)req.get("menteeName")).substring(0,1) %><% } %>
                            </div>
                            <div>
                                <div style="font-weight: 700; color: #1e293b;"><%= req.get("menteeName") %></div>
                                <div style="font-size: 11px; color: #6366f1;">Click to view profile</div>
                            </div>
                        </td>
                        <td><span class="info-pill"><%= req.get("courseCode") %></span></td>
                        <td>
                            <div style="display: flex; gap: 8px;">
                                <a href="MentorshipServlet?action=approve&menteeId=<%= req.get("menteeId") %>&mentorId=<%= currentId %>" class="btn btn-success" style="padding: 8px 12px;"><i class="fa-solid fa-check"></i> Approve</a>
                                <a href="MentorshipServlet?action=reject&menteeId=<%= req.get("menteeId") %>&mentorId=<%= currentId %>" class="btn btn-danger" style="padding: 8px 12px;"><i class="fa-solid fa-xmark"></i></a>
                            </div>
                        </td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>

    <% } else if (view.equals("mentee_detail")) { 
        Student mentee = sDao.getStudentById(Integer.parseInt(request.getParameter("mid")));
    %>
        <a href="dashboard.jsp?view=requests" class="btn btn-outline" style="margin-bottom: 20px;"><i class="fa-solid fa-arrow-left"></i> Back to Requests</a>
        <div class="detail-box">
            <div style="display: flex; gap: 40px; align-items: flex-start;">
                <div class="m-avatar" style="width: 150px; height: 150px; margin: 0; font-size: 60px;">
                    <% if (mentee.getProfilePic() != null && !mentee.getProfilePic().isEmpty()) { %><img src="<%= mentee.getProfilePic() %>"><% } else { %><%= mentee.getStudentName().substring(0,1) %><% } %>
                </div>
                <div style="flex-grow: 1;">
                    <h1 style="font-size: 32px; margin-bottom: 5px;"><%= mentee.getStudentName() %></h1>
                    <div style="display: flex; gap: 10px; margin-bottom: 20px;">
                        <span class="info-pill"><%= mentee.getCourseCode() %></span>
                        <span class="info-pill" style="background: #f0fdf4; color: #16a34a;">MENTEE APPLICANT</span>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 25px;">
                        <div style="padding: 15px; background: #f8fafc; border-radius: 12px;">
                            <label>Current CGPA</label>
                            <div style="font-size: 24px; font-weight: 800; color: #10b981;"><%= mentee.getStudentCGPA() %></div>
                        </div>
                        <div style="padding: 15px; background: #f8fafc; border-radius: 12px;">
                            <label>Email Address</label>
                            <div style="font-size: 14px; font-weight: 600;"><%= mentee.getStudentEmail() %></div>
                        </div>
                    </div>

                    <div style="margin-bottom: 25px;">
                        <label>Student Bio</label>
                        <p style="line-height: 1.6;"><%= (mentee.getStudentBio()!=null && !mentee.getStudentBio().isEmpty())?mentee.getStudentBio():"No bio provided." %></p>
                    </div>

                    <div style="margin-bottom: 25px;">
                        <label>Academic Achievements</label>
                        <p style="line-height: 1.6;"><%= (mentee.getStudentAchievements()!=null && !mentee.getStudentAchievements().isEmpty())?mentee.getStudentAchievements():"No achievements listed." %></p>
                    </div>

                    <div style="display: flex; gap: 12px; margin-top: 30px; border-top: 1px solid #f1f5f9; padding-top: 25px;">
                        <a href="MentorshipServlet?action=approve&menteeId=<%= mentee.getStudentID() %>&mentorId=<%= currentId %>" class="btn btn-success" style="padding: 12px 30px;">
                            <i class="fa-solid fa-check"></i> Accept Application
                        </a>
                        <a href="MentorshipServlet?action=reject&menteeId=<%= mentee.getStudentID() %>&mentorId=<%= currentId %>" class="btn btn-danger" style="padding: 12px 30px;">
                            <i class="fa-solid fa-xmark"></i> Reject
                        </a>
                    </div>
                </div>
            </div>
        </div>

    <% } else if (view.equals("messages")) { %>
        <h2 style="margin-bottom: 25px;">Messages</h2>
        <div class="chat-container">
            <div class="chat-sidebar">
                <div style="padding: 20px; border-bottom: 1px solid #f1f5f9;">
                    <input type="text" placeholder="Search chats..." style="font-size: 13px;">
                </div>
                <div class="chat-list" id="chatList">
                    <% 
                    List<Map<String, Object>> connections = sDao.getAcceptedConnections(currentId, currentRole);
                    if (connections.isEmpty()) { 
                    %>
                    <div style="padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 13px;">
                        No accepted connections yet.
                    </div>
                    <% } else { 
                        int count = 0;
                        for (Map<String, Object> conn : connections) { 
                            String name = (String)conn.get("name");
                            String pic = (String)conn.get("profilePic");
                    %>
                    <div class="chat-item <%= count == 0 ? "active" : "" %>" 
                         onclick="selectChat(this, '<%= name %>', '<%= pic != null ? pic : "" %>')">
                        <div class="small-avatar">
                            <% if (pic != null && !pic.isEmpty()) { %><img src="<%= pic %>"><% } else { %><%= name.substring(0,1) %><% } %>
                        </div>
                        <div style="flex-grow: 1;">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <span style="font-weight: 700; font-size: 14px;"><%= name %></span>
                                <span style="font-size: 10px; color: #94a3b8;">Active</span>
                            </div>
                            <div style="font-size: 12px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 180px;">
                                Click to start conversation...
                            </div>
                        </div>
                    </div>
                    <% count++; } } %>
                </div>
            </div>
            <div class="chat-main" id="chatMain" <%= connections.isEmpty() ? "style='display:none'" : "" %>>
                <div class="chat-header">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div class="small-avatar" id="activeChatAvatar">
                            <% if(!connections.isEmpty()) { 
                                Map<String,Object> first = connections.get(0);
                                String firstPic = (String)first.get("profilePic");
                                String firstName = (String)first.get("name");
                                if(firstPic != null && !firstPic.isEmpty()) { %><img src="<%= firstPic %>"><% } else { %><%= firstName.substring(0,1) %><% }
                            } %>
                        </div>
                        <div>
                            <div style="font-weight: 700; font-size: 15px;" id="activeChatName">
                                <%= !connections.isEmpty() ? connections.get(0).get("name") : "Select a chat" %>
                            </div>
                            <div style="font-size: 11px; color: #10b981; display: flex; align-items: center; gap: 4px;">
                                <span style="width: 6px; height: 6px; background: #10b981; border-radius: 50%;"></span> Online
                            </div>
                        </div>
                    </div>
                    <div style="display: flex; gap: 15px; color: #94a3b8;">
                        <i class="fa-solid fa-phone" style="cursor: pointer;"></i>
                        <i class="fa-solid fa-video" style="cursor: pointer;"></i>
                        <i class="fa-solid fa-ellipsis-vertical" style="cursor: pointer;"></i>
                    </div>
                </div>
                <div class="chat-messages" id="chatMessages">
                    <div class="message received">
                        Hello! Let's get started with our mentorship session.
                    </div>
                </div>
                <div class="chat-input-area">
                    <button class="toggle-sidebar" style="background: none;"><i class="fa-solid fa-paperclip"></i></button>
                    <input type="text" placeholder="Type your message here..." id="msgInput" onkeypress="if(event.key==='Enter') sendMessage()">
                    <button class="btn btn-primary" onclick="sendMessage()" style="padding: 10px 15px;">
                        <i class="fa-solid fa-paper-plane"></i>
                    </button>
                </div>
            </div>
            <% if (connections.isEmpty()) { %>
            <div style="flex-grow: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #f8fafc; color: #94a3b8;">
                 <i class="fa-solid fa-comments" style="font-size: 64px; margin-bottom: 20px; opacity: 0.5;"></i>
                 <p>Connect with others to start messaging</p>
            </div>
            <% } %>
        </div>

    <% } else if (view.equals("profile")) { %>
        <h2 style="margin-bottom: 25px;">Account Settings</h2>
        <div class="detail-box">
            <form action="ProfileServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="studentID" value="<%= currentId %>">
                <div style="display: flex; align-items: flex-start; gap: 40px; margin-bottom: 30px;">
                    <div style="text-align: center;">
                        <div class="m-avatar" style="width: 130px; height: 130px; font-size: 45px; margin-bottom: 15px;">
                            <% if (me.getProfilePic() != null && !me.getProfilePic().isEmpty()) { %><img src="<%= me.getProfilePic() %>"><% } else { %><%= me.getStudentName().substring(0,1) %><% } %>
                        </div>
                        <label class="btn btn-outline" style="font-size: 12px; cursor: pointer; text-transform: none; letter-spacing: 0;">
                            <i class="fa-solid fa-camera"></i> Change Photo
                            <input type="file" name="profilePicFile" style="display: none;" onchange="this.form.submit()">
                        </label>
                    </div>
                    <div style="flex-grow: 1;">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                            <div style="grid-column: span 2;">
                                <label>Full Name</label>
                                <input type="text" name="name" value="<%= me.getStudentName() %>">
                            </div>
                            <div>
                                <label>Email Address</label>
                                <input type="email" name="email" value="<%= me.getStudentEmail() %>">
                            </div>
                            <div>
                                <label>Phone Number</label>
                                <input type="text" name="phone" value="<%= me.getStudentPhone() %>">
                            </div>
                            <div>
                                <label>Current CGPA</label>
                                <input type="number" step="0.01" max="4.00" min="0.00" name="cgpa" value="<%= me.getStudentCGPA() %>">
                            </div>
                            <div>
                                <label>Current Course</label>
                                <select name="courseCode">
                                    <% List<Map<String, String>> courses = sDao.getAllCourses();
                                       for(Map<String, String> c : courses) { %>
                                         <option value="<%= c.get("code") %>" <%= c.get("code").equals(me.getCourseCode()) ? "selected" : "" %>>
                                            <%= c.get("code") %> - <%= c.get("name") %>
                                         </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div style="margin-bottom: 20px;">
                    <label>Professional Bio</label>
                    <textarea name="bio" rows="3"><%= me.getStudentBio() %></textarea>
                </div>
                <div style="margin-bottom: 30px;">
                    <label>Achievements</label>
                    <textarea name="achievements" rows="3"><%= me.getStudentAchievements() %></textarea>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center; padding: 15px;">Save Profile Changes</button>
            </form>
        </div>
        <div style="margin-top: 40px; padding: 20px; border: 2px solid #fee2e2; border-radius: 12px; background: #fff;">
    <h3 style="color: #991b1b; font-size: 18px; margin-bottom: 8px;">Delete Account</h3>
    <p style="color: #7f1d1d; font-size: 14px; margin-bottom: 15px;">
        Deleting your account will remove all your profile data and mentorship connections permanently.
    </p>
    
    <form action="ProfileServlet" method="POST" onsubmit="return confirm('WARNING: This will drop ALL your data from the database. Are you sure?');">
        <!-- currentId is from your session at top of dashboard.jsp -->
        <input type="hidden" name="studentID" value="<%= currentId %>">
        <input type="hidden" name="action" value="delete">
        
        <button type="submit" style="background: #dc2626; color: white; border: none; padding: 12px 24px; border-radius: 8px; cursor: pointer; font-weight: bold; transition: background 0.2s;">
            <i class="fa-solid fa-trash-can" style="margin-right: 8px;"></i> Permanent Delete
        </button>
    </form>
</div>        
    <% } %>
</div>

<script>
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('collapsed');
}

function filterMentors() {
    const input = document.getElementById('mentorSearch').value.toLowerCase();
    const items = document.getElementsByClassName('mentor-item');
    const grid = document.getElementById('mentorGrid');
    const noResults = document.getElementById('noResults');
    let visibleCount = 0;

    for (let item of items) {
        const name = item.getAttribute('data-name');
        const course = item.getAttribute('data-course');
        
        if (name.includes(input) || course.includes(input)) {
            item.style.display = "block";
            visibleCount++;
        } else {
            item.style.display = "none";
        }
    }

    if(noResults) noResults.style.display = visibleCount === 0 ? "block" : "none";
    if(grid) grid.style.display = visibleCount === 0 ? "none" : "grid";
}

function selectChat(element, name, pic) {
    // 1. Update Active state in list
    document.querySelectorAll('.chat-item').forEach(item => item.classList.remove('active'));
    element.classList.add('active');

    // 2. Update Header Name
    document.getElementById('activeChatName').textContent = name;

    // 3. Update Header Avatar
    const avatarDiv = document.getElementById('activeChatAvatar');
    if (pic && pic !== "") {
        avatarDiv.innerHTML = `<img src="${pic}" alt="${name}">`;
    } else {
        // If no picture, show the first letter
        avatarDiv.innerHTML = name.charAt(0).toUpperCase();
    }

    // 4. Reset messages for the new chat (Demo logic)
    const chatMessages = document.getElementById('chatMessages');
    chatMessages.innerHTML = `
        <div class="message received">
            You are now chatting with ${name}. How can I help you today?
        </div>
    `;
    
    // Scroll to bottom
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function sendMessage() {
    const input = document.getElementById('msgInput');
    const text = input.value.trim();
    if (!text) return;

    const chatMessages = document.getElementById('chatMessages');
    
    // Add user message
    const msgDiv = document.createElement('div');
    msgDiv.className = 'message sent';
    msgDiv.textContent = text;
    chatMessages.appendChild(msgDiv);

    // Clear input
    input.value = '';

    // Auto scroll
    chatMessages.scrollTop = chatMessages.scrollHeight;

    // Simulate response
    setTimeout(() => {
        const replyDiv = document.createElement('div');
        replyDiv.className = 'message received';
        replyDiv.textContent = "Thanks for the message! I'll get back to you shortly.";
        chatMessages.appendChild(replyDiv);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }, 1000);
}

// Function to create and show a toast
function showNotification(message, type = 'success') {
    const container = document.getElementById('notifContainer');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    // Choose icon based on type
    const icon = type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation';
    const iconColor = type === 'success' ? '#10b981' : '#f87171';

    toast.innerHTML = `
        <i class="fa-solid ${icon}" style="color: ${iconColor}"></i>
        <div style="font-weight: 600; font-size: 14px;">${message}</div>
    `;

    container.appendChild(toast);

    // Auto-remove after 4 seconds
    setTimeout(() => {
        toast.classList.add('toast-fade-out');
        setTimeout(() => toast.remove(), 500);
    }, 4000);
}

// Check URL for status messages when the page loads
window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    const msg = urlParams.get('msg');
    const status = urlParams.get('status'); // 'success' or 'error'

    if (msg) {
        showNotification(decodeURIComponent(msg), status || 'success');
    }
};
</script>

</body>
</html>