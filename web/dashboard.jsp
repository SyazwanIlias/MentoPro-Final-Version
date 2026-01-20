<%@page import="model.Note"%>
<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.StudentDAO, model.Student, model.Note, java.util.*" %>
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
    
    // Determine if user is a mentor
    boolean isMentor = "Mentor".equals(currentRole);
    
    // Set colors based on role - softer, more pleasant colors
    String primaryColor = isMentor ? "#FF6B6B" : "#5B7FFF";
    String primaryLight = isMentor ? "#FFE5E5" : "#E8EDFF";
    String primaryDark = isMentor ? "#E65454" : "#4A6BE6";
    String gradientStart = isMentor ? "#FF6B6B" : "#5B7FFF";
    String gradientEnd = isMentor ? "#FF8E8E" : "#7B9DFF";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard | MentoPro</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
        }
        
        body { 
            background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf4 100%);
            color: #2d3748; 
            overflow-x: hidden;
            font-family: 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
            font-size: 15px;
            line-height: 1.6;
        }

        /* Smooth Sidebar */
        .sidebar { 
            width: 280px;
            height: 100vh; 
            background: linear-gradient(180deg, #ffffff 0%, #fafbfc 100%);
            position: fixed; 
            left: 0; 
            top: 0; 
            padding: 28px 20px;
            box-shadow: 4px 0 24px rgba(0,0,0,0.04);
            display: flex; 
            flex-direction: column;
            z-index: 100; 
            transition: all 0.4s cubic-bezier(0.4, 0.0, 0.2, 1);
        }

        .sidebar.collapsed { 
            width: 85px;
            padding: 28px 15px; 
        }
        
        .sidebar-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 48px;
            transition: all 0.3s ease;
        }

        .sidebar.collapsed .sidebar-header {
            flex-direction: column;
            gap: 20px;
        }

        .sidebar.collapsed .logo span, 
        .sidebar.collapsed .nav-links a span,
        .sidebar.collapsed .sign-out-text { 
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .logo { 
            font-size: 26px; 
            font-weight: 800; 
            background: linear-gradient(135deg, <%= gradientStart %> 0%, <%= gradientEnd %> 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            display: flex; 
            align-items: center; 
            gap: 12px; 
            transition: all 0.3s ease;
        }
        
        .logo i {
            background: linear-gradient(135deg, <%= gradientStart %> 0%, <%= gradientEnd %> 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .toggle-sidebar { 
            background: <%= primaryLight %>;
            border: none; 
            width: 42px;
            height: 42px;
            border-radius: 12px; 
            cursor: pointer; 
            color: <%= primaryColor %>; 
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            font-size: 18px;
        }
        
        .toggle-sidebar:hover { 
            background: <%= primaryColor %>;
            color: white;
            transform: scale(1.05);
        }

        .nav-links { 
            list-style: none; 
            flex-grow: 1;
        }
        
        .nav-links li { 
            margin-bottom: 8px;
        }
        
        .nav-links a { 
            display: flex; 
            align-items: center; 
            gap: 14px; 
            padding: 14px 18px;
            border-radius: 14px; 
            color: #64748b; 
            transition: all 0.3s ease; 
            font-weight: 500; 
            text-decoration: none;
            position: relative;
            overflow: hidden;
        }
        
        .nav-links a i {
            font-size: 20px;
            transition: all 0.3s ease;
        }
        
        .nav-links a::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: <%= primaryColor %>;
            transform: scaleY(0);
            transition: transform 0.3s ease;
        }
        
        .nav-links a:hover { 
            background: <%= primaryLight %>;
            color: <%= primaryColor %>;
            transform: translateX(4px);
        }
        
        .nav-links a:hover i {
            transform: scale(1.1);
        }
        
        .nav-links a.active { 
            background: linear-gradient(135deg, <%= gradientStart %> 0%, <%= gradientEnd %> 100%);
            color: #ffffff;
            box-shadow: 0 8px 16px <%= isMentor ? "rgba(255, 107, 107, 0.25)" : "rgba(91, 127, 255, 0.25)" %>;
        }
        
        .nav-links a.active::before {
            transform: scaleY(1);
        }
        
        .sidebar.collapsed .nav-links a { 
            justify-content: center; 
            padding: 14px;
        }

        .sign-out-link {
            text-decoration: none;
            margin-top: auto;
        }
        
        .sign-out-btn {
            padding: 14px 18px;
            color: #f87171;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 14px;
            border-radius: 14px;
            transition: all 0.3s ease;
            background: transparent;
        }
        
        .sign-out-btn:hover {
            background: #fee2e2;
            transform: translateX(4px);
        }

        /* Top Bar with Glassmorphism */
        .top-bar { 
            position: fixed;
            top: 0; 
            left: 280px; 
            right: 0; 
            height: 80px; 
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            display: flex; 
            align-items: center;
            justify-content: space-between; 
            padding: 0 48px; 
            z-index: 90; 
            border-bottom: 1px solid rgba(0,0,0,0.06);
            box-shadow: 0 4px 24px rgba(0,0,0,0.04);
            transition: all 0.4s cubic-bezier(0.4, 0.0, 0.2, 1);
        }
        
        .sidebar.collapsed + .top-bar { 
            left: 85px;
        }

        .welcome-text {
            font-size: 20px;
            font-weight: 700;
            background: linear-gradient(135deg, #2d3748 0%, #4a5568 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .user-profile-section {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 10px 20px;
            background: white;
            border-radius: 50px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
        }
        
        .user-profile-section:hover {
            box-shadow: 0 6px 20px rgba(0,0,0,0.12);
            transform: translateY(-2px);
        }

        .content { 
            margin-left: 280px;
            padding: 110px 48px 48px 48px; 
            min-height: 100vh; 
            transition: all 0.4s cubic-bezier(0.4, 0.0, 0.2, 1);
        }

        .sidebar.collapsed ~ .content { 
            margin-left: 85px;
        }

        /* Modern Search */
        .search-container {
            position: relative;
            margin-bottom: 36px;
            max-width: 520px;
        }
        
        .search-input {
            width: 100%;
            padding: 18px 24px 18px 56px;
            border-radius: 16px;
            border: 2px solid #e2e8f0;
            background: white;
            font-size: 15px;
            font-family: 'Poppins', sans-serif;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
            transition: all 0.3s ease;
        }
        
        .search-input:focus {
            outline: none;
            border-color: <%= primaryColor %>;
            box-shadow: 0 8px 24px <%= isMentor ? "rgba(255, 107, 107, 0.15)" : "rgba(91, 127, 255, 0.15)" %>;
            transform: translateY(-2px);
        }
        
        .search-icon {
            position: absolute;
            left: 22px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 18px;
            transition: all 0.3s ease;
        }
        
        .search-input:focus + .search-icon {
            color: <%= primaryColor %>;
        }

        /* Card Grid */
        .grid { 
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); 
            gap: 28px;
            animation: fadeInUp 0.6s ease;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .m-card { 
            background: white;
            border-radius: 20px;
            padding: 32px; 
            text-align: center;
            border: 2px solid #f1f5f9;
            transition: all 0.4s cubic-bezier(0.4, 0.0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }
        
        .m-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, <%= gradientStart %> 0%, <%= gradientEnd %> 100%);
            transform: scaleX(0);
            transition: transform 0.4s ease;
        }
        
        .m-card:hover::before {
            transform: scaleX(1);
        }
        
        .m-card:hover { 
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            border-color: <%= primaryColor %>;
        }
        
        .m-card.hidden { 
            display: none;
        }
        
        .m-avatar { 
            width: 90px;
            height: 90px; 
            border-radius: 50%; 
            margin: 0 auto 20px;
            background: linear-gradient(135deg, <%= gradientStart %> 0%, <%= gradientEnd %> 100%);
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 32px; 
            font-weight: 700;
            color: white;
            overflow: hidden; 
            border: 4px solid white;
            box-shadow: 0 8px 24px <%= isMentor ? "rgba(255, 107, 107, 0.25)" : "rgba(91, 127, 255, 0.25)" %>;
            position: relative;
            transition: all 0.4s ease;
        }
        
        .m-card:hover .m-avatar {
            transform: scale(1.08) rotate(5deg);
            box-shadow: 0 12px 32px <%= isMentor ? "rgba(255, 107, 107, 0.35)" : "rgba(91, 127, 255, 0.35)" %>;
        }
        
        .m-avatar img { 
            width: 100%; 
            height: 100%; 
            object-fit: cover;
        }
        
        /* Smooth Buttons */
        .btn { 
            padding: 12px 24px;
            border-radius: 12px; 
            font-weight: 600; 
            cursor: pointer; 
            border: none; 
            text-decoration: none; 
            display: inline-flex; 
            align-items: center; 
            gap: 10px; 
            font-size: 14px;
            font-family: 'Poppins', sans-serif;
            transition: all 0.3s ease;
        }
        
        .btn-primary { 
            background: linear-gradient(135deg, <%= gradientStart %> 0%, <%= gradientEnd %> 100%);
            color: white;
            box-shadow: 0 4px 12px <%= isMentor ? "rgba(255, 107, 107, 0.3)" : "rgba(91, 127, 255, 0.3)" %>;
        }
        
        .btn-primary:hover {
            box-shadow: 0 8px 20px <%= isMentor ? "rgba(255, 107, 107, 0.4)" : "rgba(91, 127, 255, 0.4)" %>;
            transform: translateY(-2px);
        }
        
        .btn-success { 
            background: linear-gradient(135deg, #10b981 0%, #34d399 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        
        .btn-success:hover { 
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
            transform: translateY(-2px);
        }
        
        .btn-danger { 
            background: linear-gradient(135deg, #ef4444 0%, #f87171 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }
        
        .btn-danger:hover { 
            box-shadow: 0 8px 20px rgba(239, 68, 68, 0.4);
            transform: translateY(-2px);
        }
        
        .btn-outline { 
            border: 2px solid #e2e8f0;
            color: #64748b;
            background: white;
        }
        
        .btn-outline:hover { 
            background: #f8fafc;
            border-color: <%= primaryColor %>;
            color: <%= primaryColor %>;
            transform: translateY(-2px);
        }
        
        /* Smooth Detail Box */
        .detail-box { 
            background: white;
            padding: 48px; 
            border-radius: 24px; 
            box-shadow: 0 8px 32px rgba(0,0,0,0.08);
            max-width: 960px; 
            margin: 0 auto;
            border: 2px solid #f1f5f9;
            animation: fadeInUp 0.6s ease;
        }
        
        /* Beautiful Table */
        .request-table { 
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 12px;
            margin-top: 24px;
        }
        
        .request-table th { 
            padding: 16px 24px; 
            text-align: left; 
            color: #94a3b8; 
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase; 
            letter-spacing: 1.2px;
        }
        
        .request-table tr td { 
            background: white;
            padding: 20px 24px;
            transition: all 0.3s ease;
            border-top: 2px solid #f1f5f9;
            border-bottom: 2px solid #f1f5f9;
        }
        
        .request-table tr:hover td {
            background: <%= primaryLight %>;
            transform: translateX(4px);
        }
        
        .request-table tr td:first-child { 
            border-radius: 16px 0 0 16px;
            border-left: 2px solid #f1f5f9;
        }
        
        .request-table tr td:last-child { 
            border-radius: 0 16px 16px 0;
            border-right: 2px solid #f1f5f9;
        }
        
        .small-avatar { 
            width: 50px;
            height: 50px; 
            border-radius: 50%; 
            overflow: hidden;
            background: linear-gradient(135deg, <%= gradientStart %> 0%, <%= gradientEnd %> 100%);
            color: white; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 20px;
            font-weight: 700;
            border: 3px solid white;
            box-shadow: 0 4px 12px <%= isMentor ? "rgba(255, 107, 107, 0.25)" : "rgba(91, 127, 255, 0.25)" %>;
        }
        
        .small-avatar img { 
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        /* Smooth Pills */
        .info-pill { 
            padding: 6px 16px;
            background: <%= primaryLight %>;
            color: <%= primaryColor %>;
            border-radius: 24px; 
            font-size: 13px; 
            font-weight: 600;
            display: inline-block;
            transition: all 0.3s ease;
        }
        
        .info-pill:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 12px <%= isMentor ? "rgba(255, 107, 107, 0.2)" : "rgba(91, 127, 255, 0.2)" %>;
        }
        
        .role-badge {
            font-size: 12px; 
            color: <%= primaryColor %>;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        
        /* Beautiful Form Elements */
        input, textarea, select { 
            width: 100%; 
            padding: 14px 18px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
            transition: all 0.3s ease;
            background: white;
        }
        
        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: <%= primaryColor %>;
            box-shadow: 0 4px 12px <%= isMentor ? "rgba(255, 107, 107, 0.15)" : "rgba(91, 127, 255, 0.15)" %>;
            transform: translateY(-1px);
        }
        
        label { 
            display: block; 
            font-size: 12px; 
            font-weight: 700;
            color: #64748b;
            margin-bottom: 8px; 
            text-transform: uppercase; 
            letter-spacing: 0.8px;
        }

        /* Page Headers */
        .page-header {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 32px;
            background: linear-gradient(135deg, #2d3748 0%, #4a5568 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Smooth Toast Notifications */
        .notification-container {
            position: fixed;
            top: 24px;
            right: 24px;
            z-index: 9999;
        }

        .toast {
            background: white;
            padding: 18px 28px;
            border-radius: 16px;
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.15);
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 12px;
            border-left: 4px solid <%= primaryColor %>;
            animation: slideInRight 0.4s cubic-bezier(0.4, 0.0, 0.2, 1) forwards;
            backdrop-filter: blur(10px);
        }

        .toast.success { 
            border-left-color: #10b981;
        }
        
        .toast.error { 
            border-left-color: #ef4444;
        }

        @keyframes slideInRight {
            from { 
                transform: translateX(400px);
                opacity: 0;
            }
            to { 
                transform: translateX(0);
                opacity: 1;
            }
        }

        .toast-fade-out {
            animation: fadeOutRight 0.4s ease-in forwards;
        }

        @keyframes fadeOutRight {
            to { 
                opacity: 0;
                transform: translateX(400px);
            }
        }
        
        .verified-badge {
            background: <%= primaryLight %>;
            color: <%= primaryColor %>;
        }
        
        /* Mentor Name Styling */
        .mentor-name {
            font-size: 19px;
            font-weight: 700;
            margin-bottom: 10px;
            color: #2d3748;
        }
        
        /* No Results State */
        .no-results {
            text-align: center;
            padding: 80px 40px;
            color: #94a3b8;
        }
        
        .no-results i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .no-results p {
            font-size: 18px;
            font-weight: 500;
        }
        
        /* Profile Section */
        .profile-avatar-section {
            text-align: center;
        }
        
        .profile-avatar-large {
            width: 140px;
            height: 140px;
            font-size: 52px;
            margin-bottom: 20px;
        }
        
        /* Delete Account Section */
        .danger-zone {
            margin-top: 48px;
            padding: 28px;
            border: 2px solid #fee2e2;
            border-radius: 16px;
            background: linear-gradient(135deg, #fff5f5 0%, #fff 100%);
        }
        
        .danger-zone h3 {
            color: #991b1b;
            font-size: 20px;
            margin-bottom: 10px;
            font-weight: 700;
        }
        
        .danger-zone p {
            color: #7f1d1d;
            font-size: 14px;
            margin-bottom: 20px;
            line-height: 1.6;
        }
        
        .danger-zone button {
            background: linear-gradient(135deg, #dc2626 0%, #ef4444 100%);
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 700;
            font-family: 'Poppins', sans-serif;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.3);
        }
        
        .danger-zone button:hover {
            box-shadow: 0 8px 20px rgba(220, 38, 38, 0.4);
            transform: translateY(-2px);
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .sidebar {
                width: 85px;
                padding: 28px 15px;
            }
            
            .sidebar .logo span,
            .sidebar .nav-links a span,
            .sidebar .sign-out-text {
                display: none;
            }
            
            .top-bar {
                left: 85px;
                padding: 0 24px;
            }
            
            .content {
                margin-left: 85px;
                padding: 110px 24px 24px 24px;
            }
            
            .grid {
                grid-template-columns: 1fr;
            }
        }
        /* Disabled button style */
        .btn:disabled {
            cursor: not-allowed !important;
            opacity: 0.6;
            transform: none !important;
        }

        .btn:disabled:hover {
            transform: none !important;
            box-shadow: none !important;
        }
        
        /* Card Grid Styles for Notes */
        .card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
        .note-card { background: white; border: 1px solid #e2e8f0; border-radius: 16px; padding: 20px; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); position: relative; }
        .note-card:hover { transform: translateY(-5px); box-shadow: 0 12px 20px -5px rgba(0,0,0,0.1); border-color: <%= primaryColor%>; }

        .note-icon { width: 48px; height: 48px; background: #f1f5f9; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: <%= primaryColor%>; font-size: 22px; margin-bottom: 15px; }
        .note-title { font-weight: 700; font-size: 16px; margin-bottom: 6px; color: #0f172a; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .note-meta { font-size: 13px; color: #64748b; margin-bottom: 18px; line-height: 1.6; }

        .card-actions { display: flex; gap: 10px; }
        .btn { flex: 1; padding: 10px; text-align: center; text-decoration: none; border-radius: 10px; font-size: 14px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; border: none; transition: all 0.2s; }
        .btn-download { background: <%= primaryColor%>; color: white; }
        .btn-download:hover { background: <%= primaryDark%>; }
        .btn-remove { background: #fee2e2; color: #ef4444; flex: 0 0 45px; }
        .btn-remove:hover { background: #fecaca; }

        /* Modal / Upload Style */
        .section-upload { background: white; border: 1px solid #e2e8f0; padding: 25px; margin-bottom: 25px; border-radius: 16px; display: none; }

        #notifContainer { position: fixed; top: 20px; right: 20px; z-index: 9999; }
        .toast { background: white; padding: 16px 24px; border-radius: 12px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); display: flex; align-items: center; gap: 12px; margin-bottom: 10px; border-left: 4px solid #10b981; animation: slideIn 0.3s ease-out; }
        .toast.error { border-left-color: #ef4444; }
        @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
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
        <li>
            <a href="dashboard.jsp?view=connections" class="<%= view.equals("connections") || view.equals("connection_detail") ? "active" : ""%>">
                <i class="fa-solid fa-link"></i>
                <span>My Connections</span>
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
        <li class="nav-item">
            <a href="dashboard.jsp?view=notes" class="nav-link <%= "notes".equals(view) ? "active" : ""%>">
                <i class="fa-solid fa-book-open"></i> Study Notes
            </a>
        </li>
        <li>
            <a href="dashboard.jsp?view=profile" class="<%= view.equals("profile") ? "active" : "" %>">
                <i class="fa-solid fa-user"></i>
                <span>My Profile</span>
            </a>
        </li>
    </ul>
    
    <a href="LogoutServlet" class="sign-out-link">
        <div class="sign-out-btn">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
            <span class="sign-out-text">Sign Out</span>
        </div>
    </a>
</div>

<div class="top-bar">
    <div class="welcome-text">
        Welcome back, <%= me.getStudentName() %> 👋
    </div>
    <div class="user-profile-section">
        <div style="text-align: right;">
            <div style="font-weight: 600; font-size: 15px; color: #2d3748;"><%= me.getStudentName() %></div>
            <div class="role-badge"><%= currentRole.toUpperCase() %></div>
        </div>
        <div class="small-avatar" style="width: 46px; height: 46px; font-size: 18px;">
            <% if (me.getProfilePic() != null && !me.getProfilePic().isEmpty()) { %>
                <img src="<%= me.getProfilePic() %>">
            <% } else { %>
                <%= me.getStudentName().substring(0,1) %>
            <% } %>
        </div>
    </div>
</div>

<div class="content">
    <% if (view.equals("mentors")) { %>
    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 24px; margin-bottom: 36px;">
        <h1 class="page-header">
            <% if (isMentor) { %>
            All Mentors (View Only)
            <% } else { %>
            Find Your Perfect Mentor
            <% } %>
        </h1>
        <div class="search-container" style="margin-bottom: 0;">
            <input type="text" id="mentorSearch" class="search-input" placeholder="Search by name or course code..." onkeyup="filterMentors()">
            <i class="fa-solid fa-magnifying-glass search-icon"></i>
        </div>
    </div>

    <% if (isMentor) { %>
    <!-- MENTOR VIEW: Show all mentors (view only, no apply button) -->
    <div class="grid" id="mentorGrid">
        <%
            List<Student> allMentors = sDao.getAllMentorsExcludingSelf(currentId);
            for (Student s : allMentors) {
        %>
        <div class="m-card mentor-item" 
             data-name="<%= s.getStudentName().toLowerCase()%>" 
             data-course="<%= s.getCourseCode().toLowerCase()%>"
             onclick="location.href='dashboard.jsp?view=mentor_detail&mid=<%= s.getStudentID()%>'">
            <div class="m-avatar">
                <% if (s.getProfilePic() != null && !s.getProfilePic().isEmpty()) {%>
                <img src="<%= s.getProfilePic()%>">
                <% } else {%>
                <%= s.getStudentName().substring(0, 1)%>
                <% }%>
            </div>
            <h3 class="mentor-name"><%= s.getStudentName()%></h3>
            <span class="info-pill mentor-course"><%= s.getCourseCode()%></span>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <!-- MENTEE VIEW: Show mentors excluding approved ones, with request status -->
    <div class="grid" id="mentorGrid">
        <%
            List<Map<String, Object>> mentorsForMentee = sDao.getMentorsForMenteeOverview(currentId);
            for (Map<String, Object> mentorData : mentorsForMentee) {
                Student s = (Student) mentorData.get("student");
                String requestStatus = (String) mentorData.get("requestStatus");
        %>
        <div class="m-card mentor-item" 
             data-name="<%= s.getStudentName().toLowerCase()%>" 
             data-course="<%= s.getCourseCode().toLowerCase()%>">
            <div onclick="location.href='dashboard.jsp?view=mentor_detail&mid=<%= s.getStudentID()%>'" style="cursor: pointer;">
                <div class="m-avatar">
                    <% if (s.getProfilePic() != null && !s.getProfilePic().isEmpty()) {%>
                    <img src="<%= s.getProfilePic()%>">
                    <% } else {%>
                    <%= s.getStudentName().substring(0, 1)%>
                    <% }%>
                </div>
                <h3 class="mentor-name"><%= s.getStudentName()%></h3>
                <span class="info-pill mentor-course"><%= s.getCourseCode()%></span>
            </div>

            <div style="margin-top: 16px;">
                <% if (requestStatus == null) {%>
                <!-- No request sent yet - show Apply button -->
                <a href="MentorshipServlet?action=request&mentorId=<%= s.getStudentID()%>&menteeId=<%= currentId%>" 
                   class="btn btn-primary" style="width: 100%; justify-content: center; padding: 10px 16px;">
                    <i class="fa-solid fa-paper-plane"></i> Apply
                </a>
                <% } else if ("PENDING".equals(requestStatus)) { %>
                <!-- Request is pending -->
                <button class="btn btn-outline" disabled style="width: 100%; justify-content: center; padding: 10px 16px;">
                    <i class="fa-solid fa-clock"></i> Request Sent
                </button>
                <% } else if ("REJECTED".equals(requestStatus)) {%>
                <!-- Request was rejected - allow reapplication -->
                <a href="MentorshipServlet?action=request&mentorId=<%= s.getStudentID()%>&menteeId=<%= currentId%>" 
                   class="btn btn-primary" style="width: 100%; justify-content: center; padding: 10px 16px;">
                    <i class="fa-solid fa-rotate-right"></i> Apply Again
                </a>
                <div style="margin-top: 8px; font-size: 11px; color: #ef4444; text-align: center; font-weight: 600;">
                    Previous request was rejected
                </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>

    <div id="noResults" class="no-results" style="display: none;">
        <i class="fa-solid fa-user-slash"></i>
        <p>No mentors found matching your search</p>
    </div>

    <% } else if (view.equals("connections")) { %>

        <h1 class="page-header">My Connections</h1>

        <div class="grid">
            <%
                List<Student> myConns = "Mentor".equals(currentRole) ? sDao.getApprovedMenteesForMentor(currentId) : sDao.getApprovedMentorsForStudent(currentId);

                if (myConns != null && !myConns.isEmpty()) {
                    for (Student person : myConns) {
            %>
            <div class="m-card" onclick="location.href='dashboard.jsp?view=connection_detail&mid=<%= person.getStudentID()%>'">
                <div class="m-avatar">
                    <% if (person.getProfilePic() != null) {%>
                        <img src="<%= person.getProfilePic()%>">
                    <% } else {%>
                        <%= person.getStudentName().substring(0, 1)%>
                    <% }%>
                </div>
                <h3 class="mentor-name"><%= person.getStudentName()%></h3>
                <p style="color: #64748b; font-size: 14px; margin: 8px 0;"><%= person.getCourseCode()%></p>
                <span class="info-pill" style="background: #d1fae5; color: #059669;">
                    <i class="fa-solid fa-circle-check"></i> Connected
                </span>
            </div>
            <% 
                    }
                } else { 
            %>
            <div class="no-results" style="grid-column: 1/-1;">
                <i class="fa-solid fa-user-group"></i>
                <p>No connections found yet</p>
            </div>
            <% } %>
        </div>

    <% } else if (view.equals("connection_detail")) {
        Student person = sDao.getStudentById(Integer.parseInt(request.getParameter("mid")));
    %>

        <a href="dashboard.jsp?view=connections" class="btn btn-outline" style="margin-bottom: 28px;">
            <i class="fa-solid fa-arrow-left"></i> Back to Connections
        </a>

        <div class="detail-box">
            <div style="display: flex; gap: 40px; align-items: flex-start; margin-bottom: 36px;">
                <div class="m-avatar" style="width: 130px; height: 130px; font-size: 52px; margin:0;">
                    <% if (person.getProfilePic() != null) {%>
                        <img src="<%= person.getProfilePic()%>">
                    <% } else {%>
                        <%= person.getStudentName().substring(0, 1)%>
                    <% }%>
                </div>
                <div style="flex-grow: 1;">
                    <h1 style="font-size: 32px; font-weight: 800; margin-bottom: 12px; color: #2d3748;"><%= person.getStudentName()%></h1>
                    <span class="info-pill" style="background: #d1fae5; color: #059669; margin-bottom: 20px; display: inline-block; font-size: 14px;">
                        <i class="fa-solid fa-circle-check"></i> Approved Connection
                    </span>
                    <p style="color: #64748b; margin: 8px 0; font-size: 15px;"><i class="fa-solid fa-envelope" style="margin-right: 8px;"></i> <%= person.getStudentEmail()%></p>
                    <p style="color: #64748b; font-size: 15px;"><i class="fa-solid fa-phone" style="margin-right: 8px;"></i> <%= person.getStudentPhone()%></p>
                    <a href="https://wa.me/<%= person.getStudentPhone()%>" target="_blank" style="display: inline-flex; align-items: center; background-color: #25D366; color: white; padding: 8px 16px; border-radius: 5px; text-decoration: none; font-family: sans-serif; font-size: 14px; margin-right: 10px;">
                        <i class="fa-brands fa-whatsapp" style="margin-right: 8px;"></i> WhatsApp
                    </a>

                    <a href="https://t.me/+<%= person.getStudentPhone().replace("+", "")%>" target="_blank" style="display: inline-flex; align-items: center; background-color: #0088cc; color: white; padding: 8px 16px; border-radius: 5px; text-decoration: none; font-family: sans-serif; font-size: 14px;">
                        <i class="fa-brands fa-telegram" style="margin-right: 8px;"></i> Telegram
                    </a>
                </div>
            </div>
            <div style="border-top: 2px solid #f1f5f9; padding-top: 28px;">
                <h4 style="margin-bottom: 12px; font-size: 13px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 1px;">About</h4>
                <p style="line-height: 1.8; color: #475569;"><%= (person.getStudentBio() != null && !person.getStudentBio().isEmpty()) ? person.getStudentBio() : "Professional profile details for " + person.getStudentName() + "."%></p>
            </div>
        </div>

                <% } else if (view.equals("mentor_detail")) {
                    int mid = Integer.parseInt(request.getParameter("mid"));
                    Student mentor = sDao.getStudentById(mid);

                    String requestStatus = null;
                    if ("Mentee".equals(currentRole)) {
                        requestStatus = sDao.getRequestStatus(mid, currentId);
                    }
                %>
                <a href="dashboard.jsp?view=mentors" class="btn btn-outline" style="margin-bottom: 28px;">
                    <i class="fa-solid fa-arrow-left"></i> Back to Mentors
                </a>
                <div class="detail-box">
                    <div style="display: flex; gap: 48px; align-items: flex-start;">
                        <div class="m-avatar" style="width: 160px; height: 160px; margin: 0; font-size: 68px;">
                            <% if (mentor.getProfilePic() != null && !mentor.getProfilePic().isEmpty()) {%>
                            <img src="<%= mentor.getProfilePic()%>">
                            <% } else {%>
                            <%= mentor.getStudentName().substring(0, 1)%>
                            <% }%>
                        </div>
                        <div style="flex-grow: 1;">
                            <h1 style="font-size: 36px; font-weight: 800; margin-bottom: 12px; color: #2d3748;"><%= mentor.getStudentName()%></h1>
                            <div style="display: flex; gap: 12px; margin-bottom: 28px; flex-wrap: wrap;">
                                <span class="info-pill" style="font-size: 14px;"><%= mentor.getCourseCode()%></span>
                                <span class="info-pill verified-badge" style="font-size: 14px;">
                                    <i class="fa-solid fa-circle-check"></i> VERIFIED MENTOR
                                </span>
                            </div>

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 32px;">
                                <div style="padding: 20px; background: linear-gradient(135deg, #f8fafc 0%, #fff 100%); border-radius: 16px; border: 2px solid #f1f5f9;">
                                    <label style="margin-bottom: 8px;">Email Address</label>
                                    <div style="font-size: 15px; font-weight: 600; color: #2d3748;">
                                        <% if ("APPROVED".equals(requestStatus)) {%>
                                        <%= mentor.getStudentEmail()%>
                                        <% } else { %>
                                        <label>*******@gmail.com</label>
                                        <% } %>
                                    </div>
                                </div>
                                <div style="padding: 20px; background: linear-gradient(135deg, #f8fafc 0%, #fff 100%); border-radius: 16px; border: 2px solid #f1f5f9;">
                                    <label style="margin-bottom: 8px;">Phone Number</label>
                                    <div style="font-size: 15px; font-weight: 600; color: #2d3748;">
                                        <% if ("APPROVED".equals(requestStatus)) {%>
                                        <%= mentor.getStudentPhone()%>
                                        <% } else { %>
                                        <label>+60*********</label>
                                        <% }%>
                                    </div>
                                </div>
                            </div>

                            <div style="margin-bottom: 28px;">
                                <label style="margin-bottom: 10px;">Professional Bio</label>
                                <p style="line-height: 1.8; color: #475569;"><%= (mentor.getStudentBio() != null && !mentor.getStudentBio().isEmpty()) ? mentor.getStudentBio() : "No bio provided."%></p>
                            </div>

                            <div style="margin-bottom: 32px;">
                                <label style="margin-bottom: 10px;">Expertise & Achievements</label>
                                <p style="line-height: 1.8; color: #475569;"><%= (mentor.getStudentAchievements() != null && !mentor.getStudentAchievements().isEmpty()) ? mentor.getStudentAchievements() : "No achievements listed."%></p>
                            </div>

                            <div style="display: flex; gap: 14px; margin-top: 36px; border-top: 2px solid #f1f5f9; padding-top: 32px; flex-wrap: wrap;">
                                <% if ("Mentee".equals(currentRole)) { %>
                                <% if (requestStatus == null) {%>
                                <!-- No request sent yet -->
                                <a href="MentorshipServlet?action=request&mentorId=<%= mentor.getStudentID()%>&menteeId=<%= currentId%>" class="btn btn-primary" style="padding: 14px 32px; font-size: 15px;">
                                    <i class="fa-solid fa-paper-plane"></i> Request Mentorship
                                </a>
                                <% } else if ("PENDING".equals(requestStatus)) { %>
                                <!-- Request pending -->
                                <button class="btn btn-outline" disabled style="padding: 14px 32px; font-size: 15px;">
                                    <i class="fa-solid fa-clock"></i> Request Already Sent
                                </button>
                                <div style="width: 100%; margin-top: -8px; font-size: 13px; color: #64748b;">
                                    Your request is waiting for approval from this mentor
                                </div>
                                <% } else if ("APPROVED".equals(requestStatus)) { %>
                                <!-- Already connected -->
                                <button class="btn btn-success" disabled style="padding: 14px 32px; font-size: 15px;">
                                    <i class="fa-solid fa-circle-check"></i> Already Connected
                                </button>
                                <a href="dashboard.jsp?view=connections" class="btn btn-outline" style="padding: 14px 32px; font-size: 15px;">
                                    <i class="fa-solid fa-link"></i> View in Connections
                                </a>
                                <% } else if ("REJECTED".equals(requestStatus)) {%>
                                <!-- Request was rejected - allow reapplication -->
                                <a href="MentorshipServlet?action=request&mentorId=<%= mentor.getStudentID()%>&menteeId=<%= currentId%>" class="btn btn-primary" style="padding: 14px 32px; font-size: 15px;">
                                    <i class="fa-solid fa-rotate-right"></i> Request Mentorship Again
                                </a>
                                <div style="width: 100%; margin-top: -8px; font-size: 13px; color: #ef4444; font-weight: 600;">
                                    Your previous request was rejected. You can apply again.
                                </div>
                                <% } %>
                                <% } else { %>
                                <!-- User is a Mentor - view only -->
                                <div class="info-pill" style="background: #fee2e2; color: #991b1b; padding: 14px 32px; font-size: 15px;">
                                    <i class="fa-solid fa-eye"></i> View Only - Mentors cannot request mentorship
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

    <% } else if (view.equals("requests")) { %>
        <h1 class="page-header">Pending Requests</h1>
        <div class="detail-box" style="max-width: 1100px; padding: 32px;">
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
                    <tr><td colspan="3" class="no-results" style="padding: 60px;">No pending requests</td></tr>
                    <% } else { 
                        for (Map<String, Object> req : requests) { 
                    %>
                    <tr>
                        <td style="display: flex; align-items: center; gap: 18px; cursor: pointer;" onclick="location.href='dashboard.jsp?view=mentee_detail&mid=<%= req.get("menteeId") %>'">
                            <div class="small-avatar">
                                <% 
                                    String pic = (String)req.get("profilePic"); 
                                    if (pic != null && !pic.isEmpty()) { 
                                %>
                                    <img src="<%= pic %>">
                                <% } else { %>
                                    <%= ((String)req.get("menteeName")).substring(0,1) %>
                                <% } %>
                            </div>
                            <div>
                                <div style="font-weight: 700; color: #2d3748; font-size: 15px;"><%= req.get("menteeName") %></div>
                                <div style="font-size: 12px; color: <%= primaryColor %>; font-weight: 600;">Click to view profile</div>
                            </div>
                        </td>
                        <td><span class="info-pill"><%= req.get("courseCode") %></span></td>
                        <td>
                            <div style="display: flex; gap: 10px;">
                                <a href="MentorshipServlet?action=approve&menteeId=<%= req.get("menteeId") %>&mentorId=<%= currentId %>" class="btn btn-success" style="padding: 10px 16px;">
                                    <i class="fa-solid fa-check"></i> Approve
                                </a>
                                <a href="MentorshipServlet?action=reject&menteeId=<%= req.get("menteeId") %>&mentorId=<%= currentId %>" class="btn btn-danger" style="padding: 10px 16px;">
                                    <i class="fa-solid fa-xmark"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                    <% 
                        } 
                    } 
                    %>
                </tbody>
            </table>
        </div>

    <% } else if (view.equals("mentee_detail")) { 
        Student mentee = sDao.getStudentById(Integer.parseInt(request.getParameter("mid")));
    %>
        <a href="dashboard.jsp?view=requests" class="btn btn-outline" style="margin-bottom: 28px;">
            <i class="fa-solid fa-arrow-left"></i> Back to Requests
        </a>
        <div class="detail-box">
            <div style="display: flex; gap: 48px; align-items: flex-start;">
                <div class="m-avatar" style="width: 160px; height: 160px; margin: 0; font-size: 68px;">
                    <% if (mentee.getProfilePic() != null && !mentee.getProfilePic().isEmpty()) { %>
                        <img src="<%= mentee.getProfilePic() %>">
                    <% } else { %>
                        <%= mentee.getStudentName().substring(0,1) %>
                    <% } %>
                </div>
                <div style="flex-grow: 1;">
                    <h1 style="font-size: 36px; font-weight: 800; margin-bottom: 12px; color: #2d3748;"><%= mentee.getStudentName() %></h1>
                    <div style="display: flex; gap: 12px; margin-bottom: 28px; flex-wrap: wrap;">
                        <span class="info-pill" style="font-size: 14px;"><%= mentee.getCourseCode() %></span>
                        <span class="info-pill" style="background: #d1fae5; color: #059669; font-size: 14px;">
                            <i class="fa-solid fa-user-graduate"></i> MENTEE APPLICANT
                        </span>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 32px;">
                        <div style="padding: 20px; background: linear-gradient(135deg, #d1fae5 0%, #ecfdf5 100%); border-radius: 16px; border: 2px solid #a7f3d0;">
                            <label style="margin-bottom: 8px; color: #065f46;">Current CGPA</label>
                            <div style="font-size: 32px; font-weight: 800; color: #059669;"><%= mentee.getStudentCGPA() %></div>
                        </div>
                        <div style="padding: 20px; background: linear-gradient(135deg, #f8fafc 0%, #fff 100%); border-radius: 16px; border: 2px solid #f1f5f9;">
                            <label style="margin-bottom: 8px;">Email Address</label>
                            <div style="font-size: 15px; font-weight: 600; color: #2d3748;"><%= mentee.getStudentEmail() %></div>
                        </div>
                    </div>

                    <div style="margin-bottom: 28px;">
                        <label style="margin-bottom: 10px;">Student Bio</label>
                        <p style="line-height: 1.8; color: #475569;"><%= (mentee.getStudentBio()!=null && !mentee.getStudentBio().isEmpty())?mentee.getStudentBio():"No bio provided." %></p>
                    </div>

                    <div style="margin-bottom: 32px;">
                        <label style="margin-bottom: 10px;">Academic Achievements</label>
                        <p style="line-height: 1.8; color: #475569;"><%= (mentee.getStudentAchievements()!=null && !mentee.getStudentAchievements().isEmpty())?mentee.getStudentAchievements():"No achievements listed." %></p>
                    </div>

                    <div style="display: flex; gap: 14px; margin-top: 36px; border-top: 2px solid #f1f5f9; padding-top: 32px; flex-wrap: wrap;">
                        <a href="MentorshipServlet?action=approve&menteeId=<%= mentee.getStudentID() %>&mentorId=<%= currentId %>" class="btn btn-success" style="padding: 14px 32px; font-size: 15px;">
                            <i class="fa-solid fa-check"></i> Accept Application
                        </a>
                        <a href="MentorshipServlet?action=reject&menteeId=<%= mentee.getStudentID() %>&mentorId=<%= currentId %>" class="btn btn-danger" style="padding: 14px 32px; font-size: 15px;">
                            <i class="fa-solid fa-xmark"></i> Reject
                        </a>
                    </div>
                </div>
            </div>
        </div>
                            
    <% } else if (view.equals("notes")) { %>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
            <h2 style="font-size: 28px; font-weight: 800;">Study Resources</h2>
            <% if (isMentor) { %>
                <button onclick="document.getElementById('uploadModal').style.display='flex'" class="btn btn-primary">
                    <i class="fa-solid fa-plus"></i> Upload Resource
                </button>
            <% } %>
        </div>

        <div class="card-grid">
            <% 
                try {
                    List<Note> notes = isMentor ? sDao.getAllMentorNotes() : sDao.getNotesForMentee(currentId);
                    if (notes == null || notes.isEmpty()) { 
            %>
                <div style="grid-column: 1/-1; text-align: center; padding: 60px; background: white; border-radius: 20px; border: 1px dashed #cbd5e1;">
                    <i class="fa-solid fa-folder-open" style="font-size: 40px; color: #cbd5e1; margin-bottom: 10px;"></i>
                    <p style="color: #64748b;">No resources available yet.</p>
                </div>
            <% 
                    } else { 
                        for (Note n : notes) {
            %>
                <div class="note-card">
                    <div class="note-icon"><i class="fa-solid fa-file-pdf"></i></div>
                    <div class="note-title" title="<%= n.getFileName() %>"><%= n.getFileName() %></div>
                    <div class="note-meta">
                        <div><i class="fa-solid fa-user-circle"></i> <%= n.getMentorName() %></div>
                        <div><i class="fa-solid fa-calendar-day"></i> <%= n.getUploadDate() %></div>
                    </div>
                    <div class="card-actions">
                        <a href="NoteController?action=download&id=<%= n.getNoteID() %>" class="btn btn-download">Download</a>
                        <% if (isMentor) { %>
                        <a href="NoteController?action=remove&id=<%= n.getNoteID() %>" class="btn btn-remove" onclick="return confirm('Delete this note?')">
                            <i class="fa-solid fa-trash"></i>
                        </a>
                        <% } %>
                    </div>
                </div>
            <%          } 
                    }
                } catch(Exception e) { %>
                    <div style="grid-column: 1/-1; color: red;">Error: <%= e.getMessage() %></div>
            <%  } %>
        </div>

        <% if (isMentor) { %>
        <div id="uploadModal" class="modal-overlay">
            <div class="modal-card">
                <div style="display: flex; justify-content: space-between; margin-bottom: 25px;">
                    <h3>Share Resources</h3>
                    <button onclick="document.getElementById('uploadModal').style.display='none'" style="border:none; background:none; cursor:pointer;"><i class="fa-solid fa-xmark"></i></button>
                </div>
                <form action="NoteController?action=upload" method="post" enctype="multipart/form-data">
                    <div class="upload-dropzone" onclick="document.getElementById('fileInput').click()">
                        <input type="file" name="file" id="fileInput" required style="display: none;" onchange="updateFileName(this)">
                        <i class="fa-solid fa-cloud-arrow-up" style="font-size: 48px; color: <%= primaryColor %>;"></i>
                        <p id="fileNameLabel">Click to browse files</p>
                    </div>
                    <div style="display: flex; gap: 12px; margin-top: 10px;">
                        <button type="button" onclick="document.getElementById('uploadModal').style.display='none'" class="btn btn-outline" style="flex:1;">Cancel</button>
                        <button type="submit" class="btn btn-primary" style="flex:2;">Upload</button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>
                        
    <% } else if (view.equals("profile")) { %>
        <h1 class="page-header">Account Settings</h1>
        <div class="detail-box">
            <form action="ProfileServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="studentID" value="<%= currentId %>">
                <div style="display: flex; align-items: flex-start; gap: 48px; margin-bottom: 36px;">
                    <div class="profile-avatar-section">
                        <div class="m-avatar profile-avatar-large">
                            <% if (me.getProfilePic() != null && !me.getProfilePic().isEmpty()) { %>
                                <img src="<%= me.getProfilePic() %>">
                            <% } else { %>
                                <%= me.getStudentName().substring(0,1) %>
                            <% } %>
                        </div>
                        <label class="btn btn-outline" style="font-size: 13px; cursor: pointer; text-transform: none; letter-spacing: 0;">
                            <i class="fa-solid fa-camera"></i> Change Photo
                            <input type="file" name="profilePicFile" style="display: none;" onchange="this.form.submit()">
                        </label>
                    </div>
                    <div style="flex-grow: 1;">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
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
                                <input type="text" name="phone" value="<%= me.getStudentPhone() != null && !me.getStudentPhone().isEmpty() ? me.getStudentPhone() : "+60"%>" oninput="if(!this.value.startsWith('+60')) this.value = '+60' + this.value.replace(/^\+?6?0?/, ''); this.value = '+60' + this.value.substring(3).replace(/\D/g, '');">
                            </div>
                            <div>
                                <label>Current CGPA</label>
                                <input type="number" step="0.01" max="4.00" min="0.00" name="cgpa" value="<%= me.getStudentCGPA() %>">
                            </div>
                            <div>
                                <label>Current Course</label>
                                <select name="courseCode">
                                    <% 
                                        List<Map<String, String>> courses = sDao.getAllCourses();
                                        for(Map<String, String> c : courses) { 
                                    %>
                                    <option value="<%= c.get("code") %>" <%= c.get("code").equals(me.getCourseCode()) ? "selected" : "" %>>
                                        <%= c.get("code") %> - <%= c.get("name") %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div style="margin-bottom: 24px;">
                    <label>Professional Bio</label>
                    <textarea name="bio" rows="4"><%= me.getStudentBio() %></textarea>
                </div>
                <div style="margin-bottom: 36px;">
                    <label>Achievements</label>
                    <textarea name="achievements" rows="4"><%= me.getStudentAchievements() %></textarea>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center; padding: 16px; font-size: 16px;">
                    <i class="fa-solid fa-floppy-disk"></i> Save Profile Changes
                </button>
            </form>
            
            <div class="danger-zone">
                <h3><i class="fa-solid fa-triangle-exclamation" style="margin-right: 8px;"></i> Delete Account</h3>
                <p>
                    Deleting your account will permanently remove all your profile data and mentorship connections. This action cannot be undone.
                </p>
                <form action="ProfileServlet" method="POST" onsubmit="return confirm('⚠️ WARNING: This will permanently delete ALL your data from the database. Are you absolutely sure?');">
                    <input type="hidden" name="studentID" value="<%= currentId %>">
                    <input type="hidden" name="action" value="delete">
                    <button type="submit">
                        <i class="fa-solid fa-trash-can" style="margin-right: 8px;"></i> Permanently Delete Account
                    </button>
                </form>
            </div>
        </div>               
    <% } %>
</div>

<script>
function toggleSidebar() {
    var sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('collapsed');
}

function filterMentors() {
    var input = document.getElementById('mentorSearch').value.toLowerCase();
    var items = document.getElementsByClassName('mentor-item');
    var grid = document.getElementById('mentorGrid');
    var noResults = document.getElementById('noResults');
    var visibleCount = 0;

    for (var i = 0; i < items.length; i++) {
        var item = items[i];
        var name = item.getAttribute('data-name');
        var course = item.getAttribute('data-course');
        
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

    function updateFileName(input) {
        const label = document.getElementById('fileNameLabel');
        if (input.files && input.files.length > 0) {
            label.textContent = input.files[0].name;
            label.style.color = '#10b981';
        }
    }

    function showNotification(message, type = 'success') {
        const container = document.getElementById('notifContainer');
        if (!container) return;
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        const icon = type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation';
        toast.innerHTML = `<i class="fa-solid ${icon}"></i><div>${message}</div>`;
        container.appendChild(toast);
        setTimeout(() => {
            toast.classList.add('toast-fade-out');
            setTimeout(() => toast.remove(), 400);
        }, 3000);
    }

    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('status') === 'uploaded') showNotification('Material shared successfully!');
        if (urlParams.get('status') === 'fail') showNotification('Upload failed. Please try again.', 'error');
        if (urlParams.get('status') === 'error') showNotification('An unexpected error occurred.', 'error');
    };
    
function showNotification(message, type) {
    type = type || 'success';
    var container = document.getElementById('notifContainer');
    var toast = document.createElement('div');
    toast.className = 'toast ' + type;
    
    var icon = type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation';
    var iconColor = type === 'success' ? '#10b981' : '#ef4444';
    toast.innerHTML = '<i class="fa-solid ' + icon + '" style="color: ' + iconColor + '; font-size: 20px;"></i><div style="font-weight: 600; font-size: 15px;">' + message + '</div>';
    container.appendChild(toast);

    setTimeout(function() {
        toast.classList.add('toast-fade-out');
        setTimeout(function() { 
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 400);
    }, 4000);
}

window.onload = function() {
    var urlParams = new URLSearchParams(window.location.search);
    var msg = urlParams.get('msg');
    var status = urlParams.get('status');

    if (msg) {
        // Decode the URL-encoded message
        var decodedMsg = decodeURIComponent(msg.replace(/\+/g, ' '));
        showNotification(decodedMsg, status || 'success');
    }
};
</script>

</body>
</html>
