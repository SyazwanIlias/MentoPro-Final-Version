<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.StudentDAO, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Join MentoPro | Registration</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
            font-family: 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
        }
        
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            position: relative;
            overflow-x: hidden;
            transition: background 0.6s ease;
        }

        /* Dynamic theme for Mentee (Purple) and Mentor (Red) */
        body.mentee-theme {
            background: linear-gradient(135deg, #5B7FFF 0%, #7B9DFF 100%);
        }

        body.mentor-theme {
            background: linear-gradient(135deg, #FF6B6B 0%, #FF8E8E 100%);
        }

        /* Animated background particles */
        .particles {
            position: fixed;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            z-index: 0;
            pointer-events: none;
        }

        .particle {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: float 15s infinite;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0) translateX(0) rotate(0deg);
                opacity: 0;
            }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% {
                transform: translateY(-100vh) translateX(100px) rotate(360deg);
                opacity: 0;
            }
        }

        .register-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            padding: 45px 40px;
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 520px;
            position: relative;
            z-index: 1;
            animation: slideIn 0.6s cubic-bezier(0.4, 0.0, 0.2, 1);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        @keyframes slideIn {
            from { 
                opacity: 0; 
                transform: translateY(30px) scale(0.95);
            }
            to { 
                opacity: 1; 
                transform: translateY(0) scale(1);
            }
        }

        h2 { 
            color: #2d3748; 
            margin-bottom: 8px; 
            text-align: center; 
            font-size: 28px; 
            font-weight: 800;
            animation: fadeInDown 0.6s ease-out 0.2s both;
        }

        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .subtitle {
            text-align: center;
            color: #64748b;
            font-size: 14px;
            margin-bottom: 30px;
            animation: fadeInDown 0.6s ease-out 0.3s both;
        }
        
        /* Avatar Selection with Animations */
        .avatar-selection-wrapper {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 28px;
            animation: fadeInUp 0.6s ease-out 0.4s both;
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

        .profile-preview-container {
            position: relative;
            width: 110px;
            height: 110px;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .profile-preview-container:hover {
            transform: scale(1.05) rotate(2deg);
        }

        .profile-preview {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #ffffff;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
            background: #f8f9fa;
            transition: all 0.3s ease;
        }

        .profile-preview-container:hover .profile-preview {
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.2);
        }

        .camera-overlay {
            position: absolute;
            bottom: 0;
            right: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            border: 3px solid #ffffff;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }

        body.mentee-theme .camera-overlay {
            background: linear-gradient(135deg, #5B7FFF 0%, #7B9DFF 100%);
        }

        body.mentor-theme .camera-overlay {
            background: linear-gradient(135deg, #FF6B6B 0%, #FF8E8E 100%);
        }

        .profile-preview-container:hover .camera-overlay {
            transform: scale(1.1) rotate(10deg);
        }

        .avatar-label {
            margin-top: 12px;
            font-size: 12px;
            color: #667eea;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: color 0.3s ease;
        }

        body.mentee-theme .avatar-label {
            color: #5B7FFF;
        }

        body.mentor-theme .avatar-label {
            color: #FF6B6B;
        }

        /* Role Selection with smooth transitions */
        .role-selection { 
            display: flex; 
            gap: 12px; 
            margin-bottom: 20px;
            animation: fadeInUp 0.6s ease-out 0.5s both;
        }

        .role-option { 
            flex: 1; 
        }

        .role-option input { 
            display: none; 
        }

        .role-option label {
            display: block;
            padding: 14px;
            text-align: center;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 700;
            color: #64748b;
            transition: all 0.3s ease;
            background: white;
            position: relative;
            overflow: hidden;
        }

        .role-option label::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            transition: left 0.5s;
        }

        .role-option label:hover::before {
            left: 100%;
        }

        .role-option label:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .role-option input:checked + label { 
            border-color: #667eea; 
            color: #667eea; 
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
        }

        /* Mentee theme */
        body.mentee-theme .role-option input:checked + label {
            border-color: #5B7FFF;
            color: #5B7FFF;
            background: linear-gradient(135deg, rgba(91, 127, 255, 0.1) 0%, rgba(123, 157, 255, 0.1) 100%);
            box-shadow: 0 4px 12px rgba(91, 127, 255, 0.2);
        }

        /* Mentor theme */
        body.mentor-theme .role-option input:checked + label {
            border-color: #FF6B6B;
            color: #FF6B6B;
            background: linear-gradient(135deg, rgba(255, 107, 107, 0.1) 0%, rgba(255, 142, 142, 0.1) 100%);
            box-shadow: 0 4px 12px rgba(255, 107, 107, 0.2);
        }

        /* Form Input Groups with staggered animations */
        .input-group { 
            margin-bottom: 20px;
            animation: fadeInUp 0.6s ease-out both;
        }

        .input-group:nth-child(4) { animation-delay: 0.6s; }
        .input-group:nth-child(5) { animation-delay: 0.65s; }
        .input-group:nth-child(6) { animation-delay: 0.7s; }
        .input-group:nth-child(7) { animation-delay: 0.75s; }
        .input-group:nth-child(8) { animation-delay: 0.8s; }

        .input-group label { 
            display: block; 
            margin-bottom: 8px; 
            color: #475569; 
            font-weight: 600; 
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .input-group label i { 
            margin-right: 8px; 
            color: #667eea;
            transition: color 0.3s ease;
        }

        body.mentee-theme .input-group label i {
            color: #5B7FFF;
        }

        body.mentor-theme .input-group label i {
            color: #FF6B6B;
        }

        .input-group input, 
        .input-group select {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-size: 14px;
            outline: none;
            transition: all 0.3s ease;
            background: white;
            color: #2d3748;
        }

        .input-group input:focus, 
        .input-group select:focus { 
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
            transform: translateY(-1px);
        }

        body.mentee-theme .input-group input:focus,
        body.mentee-theme .input-group select:focus {
            border-color: #5B7FFF;
            box-shadow: 0 0 0 4px rgba(91, 127, 255, 0.1);
        }

        body.mentor-theme .input-group input:focus,
        body.mentor-theme .input-group select:focus {
            border-color: #FF6B6B;
            box-shadow: 0 0 0 4px rgba(255, 107, 107, 0.1);
        }

        /* Register Button with gradient animation */
        .btn-register {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            margin-top: 10px;
            transition: all 0.3s ease;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.6s ease-out 0.85s both;
        }

        .btn-register::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            transition: left 0.5s;
        }

        .btn-register:hover::before {
            left: 100%;
        }

        body.mentee-theme .btn-register {
            background: linear-gradient(135deg, #5B7FFF 0%, #7B9DFF 100%);
            box-shadow: 0 8px 20px rgba(91, 127, 255, 0.3);
        }

        body.mentor-theme .btn-register {
            background: linear-gradient(135deg, #FF6B6B 0%, #FF8E8E 100%);
            box-shadow: 0 8px 20px rgba(255, 107, 107, 0.3);
        }

        .btn-register:hover {
            box-shadow: 0 12px 28px rgba(102, 126, 234, 0.4);
            transform: translateY(-2px);
        }

        body.mentee-theme .btn-register:hover {
            box-shadow: 0 12px 28px rgba(91, 127, 255, 0.4);
        }

        body.mentor-theme .btn-register:hover {
            box-shadow: 0 12px 28px rgba(255, 107, 107, 0.4);
        }

        .btn-register:active {
            transform: translateY(0);
        }

        .btn-register.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .btn-register.loading::after {
            content: '';
            position: absolute;
            width: 16px;
            height: 16px;
            top: 50%;
            left: 50%;
            margin-left: -8px;
            margin-top: -8px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Login link */
        .login-link { 
            text-align: center; 
            margin-top: 25px; 
            font-size: 14px; 
            color: #64748b;
            animation: fadeInUp 0.6s ease-out 0.9s both;
        }

        .login-link a { 
            color: #667eea; 
            text-decoration: none; 
            font-weight: 700;
            transition: all 0.2s;
            position: relative;
        }

        .login-link a::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 0;
            height: 2px;
            background: #667eea;
            transition: width 0.3s ease;
        }

        .login-link a:hover::after {
            width: 100%;
        }

        body.mentee-theme .login-link a {
            color: #5B7FFF;
        }

        body.mentee-theme .login-link a::after {
            background: #5B7FFF;
        }

        body.mentor-theme .login-link a {
            color: #FF6B6B;
        }

        body.mentor-theme .login-link a::after {
            background: #FF6B6B;
        }

        /* Modal with smooth animations */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(5px);
            align-items: center;
            justify-content: center;
            animation: fadeIn 0.3s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-content {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 20px;
            width: 90%;
            max-width: 450px;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: modalSlideIn 0.4s cubic-bezier(0.4, 0.0, 0.2, 1);
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-30px) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .modal-content h3 {
            margin-bottom: 20px;
            color: #2d3748;
            font-size: 22px;
            font-weight: 700;
        }

        .avatar-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-top: 20px;
        }

        .avatar-option {
            width: 100%;
            aspect-ratio: 1;
            border-radius: 12px;
            cursor: pointer;
            border: 3px solid transparent;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .avatar-option:hover {
            border-color: #667eea;
            transform: scale(1.1) rotate(3deg);
            box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
        }

        body.mentee-theme .avatar-option:hover {
            border-color: #5B7FFF;
            box-shadow: 0 4px 16px rgba(91, 127, 255, 0.3);
        }

        body.mentor-theme .avatar-option:hover {
            border-color: #FF6B6B;
            box-shadow: 0 4px 16px rgba(255, 107, 107, 0.3);
        }

        .avatar-option.selected {
            border-color: #667eea;
            transform: scale(1.05);
            box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
        }

        body.mentee-theme .avatar-option.selected {
            border-color: #5B7FFF;
            box-shadow: 0 4px 16px rgba(91, 127, 255, 0.4);
        }

        body.mentor-theme .avatar-option.selected {
            border-color: #FF6B6B;
            box-shadow: 0 4px 16px rgba(255, 107, 107, 0.4);
        }

        .modal-close-btn {
            margin-top: 25px;
            background: #f1f5f9;
            border: none;
            padding: 12px 28px;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            color: #64748b;
            transition: all 0.3s ease;
        }

        .modal-close-btn:hover {
            background: #e2e8f0;
            transform: translateY(-1px);
        }

        /* Floating shapes */
        .shape {
            position: absolute;
            border-radius: 50%;
            filter: blur(40px);
            opacity: 0.3;
            animation: float-shapes 20s infinite ease-in-out;
            pointer-events: none;
        }

        .shape1 {
            width: 300px;
            height: 300px;
            background: rgba(102, 126, 234, 0.3);
            top: -150px;
            right: -100px;
        }

        .shape2 {
            width: 400px;
            height: 400px;
            background: rgba(118, 75, 162, 0.3);
            bottom: -200px;
            left: -150px;
            animation-delay: -10s;
        }

        @keyframes float-shapes {
            0%, 100% {
                transform: translate(0, 0) scale(1);
            }
            33% {
                transform: translate(30px, -50px) scale(1.1);
            }
            66% {
                transform: translate(-20px, 30px) scale(0.9);
            }
        }

        /* Responsive */
        @media (max-width: 576px) {
            .register-container {
                padding: 35px 25px;
            }

            .avatar-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
    </style>
</head>
<body>

<!-- Animated background -->
<div class="particles" id="particles"></div>
<div class="shape shape1"></div>
<div class="shape shape2"></div>

<div class="register-container">
    <h2>Join MentoPro ✨</h2>
    <p class="subtitle">Start your mentorship journey today</p>

    <form action="RegisterServlet" method="POST" id="registerForm">
        <!-- Profile Picture Section -->
        <div class="avatar-selection-wrapper">
            <div class="profile-preview-container" onclick="openAvatarModal()">
                <img src="gambar/pic1.png" id="mainProfilePreview" class="profile-preview">
                <div class="camera-overlay">
                    <i class="fa-solid fa-camera"></i>
                </div>
            </div>
            <span class="avatar-label">Choose Avatar</span>
            <input type="hidden" id="profilePicInput" name="profilePic" value="gambar/pic1.png">
        </div>

        <!-- Role Selection -->
        <div class="role-selection">
            <div class="role-option">
                <input type="radio" name="role" id="mentee" value="Mentee" checked onchange="updateTheme()">
                <label for="mentee">
                    <i class="fa-solid fa-user-graduate"></i> Mentee
                </label>
            </div>
            <div class="role-option">
                <input type="radio" name="role" id="mentor" value="Mentor" onchange="updateTheme()">
                <label for="mentor">
                    <i class="fa-solid fa-chalkboard-user"></i> Mentor
                </label>
            </div>
        </div>

        <div class="input-group">
            <label><i class="fa-solid fa-id-card"></i> Student ID</label>
            <input type="number" name="studentID" placeholder="Enter your student ID" required>
        </div>

        <div class="input-group">
            <label><i class="fa-solid fa-user"></i> Full Name</label>
            <input type="text" name="name" placeholder="Enter your full name" required>
        </div>

        <div class="input-group">
            <label><i class="fa-solid fa-book"></i> Course</label>
            <select name="courseCode" required>
                <option value="" disabled selected>Select your course</option>
                <% 
                    try {
                        StudentDAO courseDao = new StudentDAO();
                        List<Map<String, String>> courses = courseDao.getAllCourses();
                        for(Map<String, String> c : courses) { 
                %>
                    <option value="<%= c.get("code") %>"><%= c.get("code") %> - <%= c.get("name") %></option>
                <% 
                        }
                    } catch(Exception e) {
                %>
                    <option value="" disabled>Error loading courses</option>
                <% 
                    }
                %>
            </select>
        </div>

        <div class="input-group">
            <label><i class="fa-solid fa-user-tag"></i> Username</label>
            <input type="text" name="username" placeholder="Choose a unique username" required autocomplete="username">
        </div>

        <div class="input-group">
            <label><i class="fa-solid fa-lock"></i> Password</label>
            <input type="password" name="password" placeholder="Create a strong password" required autocomplete="new-password">
        </div>

        <button type="submit" class="btn-register" id="registerBtn">
            Create Account
        </button>
    </form>
    
    <div class="login-link">
        Already have an account? <a href="login.jsp">Sign in here</a>
    </div>
</div>

<!-- Avatar Selection Modal -->
<div id="avatarModal" class="modal">
    <div class="modal-content">
        <h3>✨ Choose Your Avatar</h3>
        <div class="avatar-grid">
            <% for(int i=1; i<=12; i++) { 
                String path = "gambar/pic" + i + ".png";
            %>
                <img src="<%= path %>" class="avatar-option" onclick="selectAvatar('<%= path %>')">
            <% } %>
        </div>
        <button class="modal-close-btn" onclick="closeAvatarModal()">
            <i class="fa-solid fa-check"></i> Done
        </button>
    </div>
</div>

<script>
// Create animated particles
function createParticles() {
    const particlesContainer = document.getElementById('particles');
    const particleCount = 15;
    
    for(let i = 0; i < particleCount; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.width = Math.random() * 60 + 20 + 'px';
        particle.style.height = particle.style.width;
        particle.style.left = Math.random() * 100 + '%';
        particle.style.animationDelay = Math.random() * 15 + 's';
        particle.style.animationDuration = (Math.random() * 10 + 15) + 's';
        particlesContainer.appendChild(particle);
    }
}

// Update theme based on role selection
function updateTheme() {
    const menteeRadio = document.getElementById('mentee');
    const body = document.body;
    
    body.classList.remove('mentee-theme', 'mentor-theme');
    
    if (menteeRadio.checked) {
        body.classList.add('mentee-theme');
    } else {
        body.classList.add('mentor-theme');
    }
}

// Modal functions
var modal = document.getElementById('avatarModal');

function openAvatarModal() {
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

function closeAvatarModal() {
    modal.style.display = 'none';
    document.body.style.overflow = 'auto';
}

function selectAvatar(path) {
    document.getElementById('profilePicInput').value = path;
    document.getElementById('mainProfilePreview').src = path;
    
    var options = document.getElementsByClassName('avatar-option');
    for(var i=0; i < options.length; i++) {
        options[i].classList.remove('selected');
        if(options[i].src.indexOf(path) !== -1) {
            options[i].classList.add('selected');
        }
    }
}

// Close modal when clicking outside
window.onclick = function(event) {
    if (event.target == modal) {
        closeAvatarModal();
    }
}

// Loading state for form submission
document.getElementById('registerForm').addEventListener('submit', function() {
    const btn = document.getElementById('registerBtn');
    btn.classList.add('loading');
    btn.textContent = '';
});

// Input focus animations
const inputs = document.querySelectorAll('input, select');
inputs.forEach(input => {
    input.addEventListener('focus', function() {
        this.parentElement.style.transform = 'translateY(-2px)';
    });
    
    input.addEventListener('blur', function() {
        this.parentElement.style.transform = 'translateY(0)';
    });
});

// Initialize
window.addEventListener('load', function() {
    createParticles();
    updateTheme(); // Set initial theme
});
</script>

</body>
</html>
