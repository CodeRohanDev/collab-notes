<?php
// Get note ID from URL
// Expected URL: https://collabnotes.hostspica.com/note.php?id=abc123
// Or with URL rewriting: https://collabnotes.hostspica.com/note/abc123

$noteId = '';

// Try to get from query parameter
if (isset($_GET['id'])) {
    $noteId = htmlspecialchars($_GET['id']);
}
// Try to get from path
else if (isset($_SERVER['REQUEST_URI'])) {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $parts = explode('/', trim($path, '/'));
    if (count($parts) >= 2 && $parts[0] === 'note') {
        $noteId = htmlspecialchars($parts[1]);
    }
}

// If no note ID, redirect to home
if (empty($noteId)) {
    header('Location: https://collabnotes.hostspica.com');
    exit;
}

$deepLink = "https://collabnotes.hostspica.com/note/{$noteId}";
$appScheme = "collabnotes://note/{$noteId}";
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Open Note - CollabNotes</title>
    
    <!-- Open Graph Meta Tags for better sharing -->
    <meta property="og:title" content="Open in CollabNotes">
    <meta property="og:description" content="You've been invited to collaborate on a note. Open it in the CollabNotes app.">
    <meta property="og:type" content="website">
    <meta property="og:url" content="<?php echo $deepLink; ?>">
    
    <!-- Twitter Card Meta Tags -->
    <meta name="twitter:card" content="summary">
    <meta name="twitter:title" content="Open in CollabNotes">
    <meta name="twitter:description" content="You've been invited to collaborate on a note.">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
        }

        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            color: white;
        }

        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
        }

        p {
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .btn {
            display: inline-block;
            padding: 15px 40px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            width: 100%;
            margin-bottom: 15px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-secondary {
            background: #f0f0f0;
            color: #333;
        }

        .btn-secondary:hover {
            background: #e0e0e0;
        }

        .loading {
            display: none;
            margin: 20px 0;
        }

        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
            font-size: 14px;
            color: #666;
        }

        .store-badges {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 20px;
        }

        .store-badge {
            height: 50px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">📝</div>
        <h1>Open in CollabNotes</h1>
        <p>You've been invited to collaborate on a note. Open it in the CollabNotes app to start editing together.</p>

        <div class="loading" id="loading">
            <div class="spinner"></div>
            <p style="margin-top: 10px;">Opening app...</p>
        </div>

        <div id="buttons">
            <button class="btn btn-primary" id="openAppBtn">Open in App</button>
            <a href="https://play.google.com/store/apps/details?id=com.hostspica.collabnotes" class="btn btn-secondary" id="downloadBtn" style="display: none;">Download App</a>
        </div>

        <div class="info">
            <strong>Don't have the app?</strong><br>
            Download CollabNotes to collaborate on notes in real-time with your team.
        </div>

        <div class="store-badges" id="storeBadges" style="display: none;">
            <a href="https://play.google.com/store/apps/details?id=com.hostspica.collabnotes" target="_blank">
                <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get it on Google Play" class="store-badge">
            </a>
        </div>
    </div>

    <script>
        const noteId = '<?php echo $noteId; ?>';
        const deepLink = '<?php echo $deepLink; ?>';
        const appScheme = '<?php echo $appScheme; ?>';

        // Detect if user is on mobile
        const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        const isAndroid = /Android/i.test(navigator.userAgent);
        const isIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent);

        // Auto-open app on mobile
        if (isMobile) {
            document.getElementById('loading').style.display = 'block';
            document.getElementById('buttons').style.display = 'none';

            // Try to open the app
            setTimeout(() => {
                window.location.href = deepLink;
            }, 100);

            // If app doesn't open in 2 seconds, show download button
            setTimeout(() => {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('buttons').style.display = 'block';
                document.getElementById('downloadBtn').style.display = 'block';
                document.getElementById('storeBadges').style.display = 'flex';
            }, 2000);
        }

        // Open app button click handler
        document.getElementById('openAppBtn').addEventListener('click', () => {
            document.getElementById('loading').style.display = 'block';
            document.getElementById('buttons').style.display = 'none';

            // Try app scheme first
            window.location.href = appScheme;

            // Fallback to https deep link
            setTimeout(() => {
                window.location.href = deepLink;
            }, 500);

            // Show download option if app doesn't open
            setTimeout(() => {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('buttons').style.display = 'block';
                document.getElementById('downloadBtn').style.display = 'block';
                document.getElementById('storeBadges').style.display = 'flex';
            }, 2500);
        });

        console.log('Note ID:', noteId);
        console.log('Deep Link:', deepLink);
        console.log('Is Mobile:', isMobile);
    </script>
</body>
</html>
