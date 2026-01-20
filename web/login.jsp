<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login | MentoPro</title>
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
            /* Blended purple + red gradient background */
            background: linear-gradient(135deg, #7B9DFF 0%, #9B7FFF 25%, #B87FD4 50%, #D98FA9 75%, #FF8E8E 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            min-height: 100vh;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }

        /* Animated gradient background overlay */
        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, 
                rgba(91, 127, 255, 0.3) 0%, 
                rgba(155, 127, 255, 0.3) 25%, 
                rgba(184, 127, 212, 0.3) 50%, 
                rgba(217, 143, 169, 0.3) 75%, 
                rgba(255, 107, 107, 0.3) 100%);
            animation: gradientShift 10s ease infinite;
            z-index: 0;
        }

        @keyframes gradientShift {
            0%, 100% { opacity: 0.5; }
            50% { opacity: 0.8; }
        }

        /* Floating particles */
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
            background: rgba(255, 255, 255, 0.15);
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

        .container {
            background-color: #fff;
            border-radius: 30px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            position: relative;
            overflow: hidden;
            width: 850px;
            max-width: 100%;
            min-height: 550px;
            z-index: 1;
        }

        /* Logo at top */
        .logo-top {
            position: absolute;
            top: 30px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 1001;
            text-align: center;
        }

        .logo-icon {
            background: linear-gradient(135deg, #7B9DFF 0%, #FF8E8E 100%);
            color: white;
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin: 0 auto 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .logo-text {
            font-size: 22px;
            font-weight: 800;
            background: linear-gradient(135deg, #7B9DFF 0%, #FF8E8E 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .container p {
            font-size: 14px;
            line-height: 22px;
            letter-spacing: 0.3px;
            margin: 15px 0;
            color: #64748b;
        }

        .container a {
            color: #7B9DFF;
            font-size: 13px;
            text-decoration: none;
            margin: 15px 0 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .container a:hover {
            color: #FF8E8E;
        }

        .container button {
            background: linear-gradient(135deg, #7B9DFF 0%, #FF8E8E 100%);
            color: #fff;
            font-size: 13px;
            padding: 12px 45px;
            border: none;
            border-radius: 12px;
            font-weight: 700;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin-top: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(123, 157, 255, 0.3);
        }

        .container button:hover {
            box-shadow: 0 8px 20px rgba(123, 157, 255, 0.4);
            transform: translateY(-2px);
        }

        .container button.ghost {
            background-color: transparent;
            border: 2px solid #fff;
        }

        .container button.ghost:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        .container form {
            background-color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 0 50px;
            height: 100%;
        }

        .container input {
            background-color: #f1f5f9;
            border: 2px solid #e2e8f0;
            margin: 8px 0;
            padding: 14px 18px;
            font-size: 14px;
            border-radius: 12px;
            width: 100%;
            outline: none;
            transition: all 0.3s ease;
        }

        .container input:focus {
            border-color: #7B9DFF;
            box-shadow: 0 0 0 4px rgba(123, 157, 255, 0.1);
            background: white;
        }

        /* Form containers */
        .form-container {
            position: absolute;
            top: 0;
            height: 100%;
            transition: all 0.6s ease-in-out;
        }

        .sign-in-mentee {
            left: 0;
            width: 50%;
            z-index: 2;
        }

        .container.active .sign-in-mentee {
            transform: translateX(100%);
        }

        .sign-in-mentor {
            left: 0;
            width: 50%;
            opacity: 0;
            z-index: 1;
        }

        .container.active .sign-in-mentor {
            transform: translateX(100%);
            opacity: 1;
            z-index: 5;
            animation: show 0.6s;
        }

        @keyframes show {
            0%, 49.99% {
                opacity: 0;
                z-index: 1;
            }
            50%, 100% {
                opacity: 1;
                z-index: 5;
            }
        }

        h2 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 10px;
            color: #2d3748;
        }

        .role-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 20px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .mentee-badge {
            background: linear-gradient(135deg, rgba(91, 127, 255, 0.15) 0%, rgba(123, 157, 255, 0.15) 100%);
            color: #5B7FFF;
            border: 2px solid #5B7FFF;
        }

        .mentor-badge {
            background: linear-gradient(135deg, rgba(255, 107, 107, 0.15) 0%, rgba(255, 142, 142, 0.15) 100%);
            color: #FF6B6B;
            border: 2px solid #FF6B6B;
        }

        /* Toggle Container - Sliding Panel */
        .toggle-container {
            position: absolute;
            top: 0;
            left: 50%;
            width: 50%;
            height: 100%;
            overflow: hidden;
            transition: all 0.6s ease-in-out;
            border-radius: 0 30px 30px 0;
            z-index: 1000;
        }

        .container.active .toggle-container {
            transform: translateX(-100%);
            border-radius: 30px 0 0 30px;
        }

        .toggle {
            height: 100%;
            position: relative;
            left: -100%;
            width: 200%;
            transform: translateX(0);
            transition: all 0.6s ease-in-out;
        }

        /* Mentee theme (default - blue/purple) */
        .toggle {
            background: linear-gradient(135deg, #5B7FFF 0%, #7B9DFF 100%);
        }

        /* Mentor theme (red) */
        .container.active .toggle {
            background: linear-gradient(135deg, #FF6B6B 0%, #FF8E8E 100%);
            transform: translateX(50%);
        }

        .toggle-panel {
            position: absolute;
            width: 50%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 0 40px;
            text-align: center;
            top: 0;
            transform: translateX(0);
            transition: all 0.6s ease-in-out;
            color: #fff;
        }

        .toggle-left {
            transform: translateX(-200%);
        }

        .container.active .toggle-left {
            transform: translateX(0);
        }

        .toggle-right {
            right: 0;
            transform: translateX(0);
        }

        .container.active .toggle-right {
            transform: translateX(200%);
        }

        .toggle-panel h1 {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 15px;
        }

        .toggle-panel p {
            color: rgba(255, 255, 255, 0.9);
            font-size: 15px;
            line-height: 24px;
            margin-bottom: 20px;
        }

        /* Icon styling */
        .role-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.9;
        }

        /* Error message */
        .error-msg {
            background: linear-gradient(135deg, #fff5f5 0%, #fee 100%);
            color: #e53e3e;
            padding: 12px 18px;
            border-radius: 12px;
            font-size: 13px;
            margin-bottom: 20px;
            border: 2px solid #feb2b2;
            width: 100%;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: shake 0.5s ease-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }

        /* Input icons */
        .input-group {
            position: relative;
            width: 100%;
        }

        .input-group i {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 16px;
            pointer-events: none;
        }

        .input-group input {
            padding-left: 50px;
        }

        .input-group input:focus + i {
            color: #7B9DFF;
        }

        /* Register link */
        .register-link {
            margin-top: 20px;
            font-size: 13px;
            color: #64748b;
        }

        .register-link a {
            background: linear-gradient(135deg, #7B9DFF 0%, #FF8E8E 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 700;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .container {
                min-height: 600px;
            }

            .sign-in-mentee,
            .sign-in-mentor {
                width: 100%;
            }

            .container.active .sign-in-mentee {
                transform: translateX(0);
                opacity: 0;
                z-index: 1;
            }

            .container.active .sign-in-mentor {
                transform: translateX(0);
            }

            .toggle-container {
                left: 0;
                width: 100%;
                height: 200px;
                border-radius: 0 0 30px 30px;
            }

            .container.active .toggle-container {
                transform: translateY(350px);
                border-radius: 30px 30px 0 0;
            }

            .toggle {
                left: 0;
                width: 100%;
            }

            .toggle-panel {
                width: 100%;
            }

            .sign-in-mentee,
            .sign-in-mentor {
                top: 200px;
                height: calc(100% - 200px);
            }

            .logo-top {
                display: none;
            }
        }

        /* Submit button loading state */
        .btn-submit {
            position: relative;
        }

        .btn-submit.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .btn-submit.loading::after {
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
    </style>
</head>
<body>

<!-- Animated particles -->
<div class="particles" id="particles"></div>

<div class="logo-top">
    <div class="logo-icon">
        <i class="fa-solid fa-graduation-cap"></i>
    </div>
    <div class="logo-text">MentoPro</div>
</div>

<div class="container" id="container">
    
    <!-- MENTEE LOGIN (Left Side) -->
    <div class="form-container sign-in-mentee">
        <form action="LoginServlet" method="POST" onsubmit="handleSubmit(event, 'mentee')">
            <input type="hidden" name="role" value="Mentee">
            
            <h2>Welcome Back!</h2>
            <div class="role-badge mentee-badge">
                <i class="fa-solid fa-user-graduate"></i>
                <span>Mentee Login</span>
            </div>
            
            <% 
                String errorParam = request.getParameter("error");
                String roleParam = request.getParameter("role");
                if(errorParam != null && "Mentee".equals(roleParam)) { 
            %>
                <div class="error-msg">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <span><%= errorParam %></span>
                </div>
            <% } %>

            <div class="input-group">
                <input type="text" name="username" placeholder="Username" required autocomplete="username">
                <i class="fa-solid fa-user"></i>
            </div>
            
            <div class="input-group">
                <input type="password" name="password" placeholder="Password" required autocomplete="current-password">
                <i class="fa-solid fa-lock"></i>
            </div>

            <button type="submit" class="btn-submit" id="menteeBtn">Sign In as Mentee</button>
            
            <div class="register-link">
                Don't have an account? <a href="register.jsp">Register here</a>
            </div>
        </form>
    </div>

    <!-- MENTOR LOGIN (Right Side - Hidden Initially) -->
    <div class="form-container sign-in-mentor">
        <form action="LoginServlet" method="POST" onsubmit="handleSubmit(event, 'mentor')">
            <input type="hidden" name="role" value="Mentor">
            
            <h2>Welcome Back!</h2>
            <div class="role-badge mentor-badge">
                <i class="fa-solid fa-chalkboard-user"></i>
                <span>Mentor Login</span>
            </div>
            
            <% 
                if(errorParam != null && "Mentor".equals(roleParam)) { 
            %>
                <div class="error-msg">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <span><%= errorParam %></span>
                </div>
            <% } %>

            <div class="input-group">
                <input type="text" name="username" placeholder="Username" required autocomplete="username">
                <i class="fa-solid fa-user"></i>
            </div>
            
            <div class="input-group">
                <input type="password" name="password" placeholder="Password" required autocomplete="current-password">
                <i class="fa-solid fa-lock"></i>
            </div>

            <button type="submit" class="btn-submit" id="mentorBtn">Sign In as Mentor</button>
            
            <div class="register-link">
                Don't have an account? <a href="register.jsp">Register here</a>
            </div>
        </form>
    </div>

    <!-- SLIDING TOGGLE PANEL -->
    <div class="toggle-container">
        <div class="toggle">
            
            <!-- Left Panel (Visible when Mentor is active) -->
            <div class="toggle-panel toggle-left">
                <i class="fa-solid fa-user-graduate role-icon"></i>
                <h1>Hello, Mentee!</h1>
                <p>Looking to learn and grow? Sign in with your mentee account to connect with amazing mentors.</p>
                <button class="ghost" type="button" onclick="switchToMentee()">
                    Login as Mentee
                </button>
            </div>

            <!-- Right Panel (Visible by default) -->
            <div class="toggle-panel toggle-right">
                <i class="fa-solid fa-chalkboard-user role-icon"></i>
                <h1>Hello, Mentor!</h1>
                <p>Ready to guide and inspire? Sign in with your mentor account to help students succeed.</p>
                <button class="ghost" type="button" onclick="switchToMentor()">
                    Login as Mentor
                </button>
            </div>

        </div>
    </div>
</div>

<script>
// Create animated particles
function createParticles() {
    const particlesContainer = document.getElementById('particles');
    const particleCount = 20;
    
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

const container = document.getElementById('container');

function switchToMentor() {
    container.classList.add('active');
}

function switchToMentee() {
    container.classList.remove('active');
}

function handleSubmit(event, role) {
    event.preventDefault();
    const btn = role === 'mentee' ? document.getElementById('menteeBtn') : document.getElementById('mentorBtn');
    btn.classList.add('loading');
    btn.textContent = '';
    
    // Submit the form after showing loading state
    setTimeout(() => {
        event.target.submit();
    }, 100);
}

// Check if error exists and show appropriate panel based on role parameter
window.addEventListener('load', function() {
    createParticles();
    
    <% if(roleParam != null) { %>
        <% if("Mentor".equals(roleParam)) { %>
            switchToMentor();
        <% } else { %>
            switchToMentee();
        <% } %>
    <% } %>
});
</script>

</body>
</html>
