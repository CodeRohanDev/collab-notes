'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';

export default function NotePage() {
  const params = useParams();
  const noteId = params.noteId as string;
  const [isMobile, setIsMobile] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const deepLink = `https://collabnotes.hostspica.com/note/${noteId}`;
  const appScheme = `collabnotes://note/${noteId}`;

  useEffect(() => {
    // Detect mobile
    const mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
      navigator.userAgent
    );
    setIsMobile(mobile);

    // Auto-open app on mobile
    if (mobile) {
      setTimeout(() => {
        window.location.href = deepLink;
      }, 100);

      // Show download option after 2 seconds
      setTimeout(() => {
        setIsLoading(false);
      }, 2000);
    } else {
      setIsLoading(false);
    }
  }, [deepLink]);

  const handleOpenApp = () => {
    setIsLoading(true);
    
    // Try app scheme first
    window.location.href = appScheme;

    // Fallback to https deep link
    setTimeout(() => {
      window.location.href = deepLink;
    }, 500);

    // Show download option if app doesn't open
    setTimeout(() => {
      setIsLoading(false);
    }, 2500);
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
    }}>
      <div style={{
        background: 'white',
        borderRadius: '20px',
        padding: '40px',
        maxWidth: '500px',
        width: '100%',
        boxShadow: '0 20px 60px rgba(0, 0, 0, 0.3)',
        textAlign: 'center'
      }}>
        {/* Logo */}
        <div style={{
          width: '80px',
          height: '80px',
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          borderRadius: '20px',
          margin: '0 auto 20px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '40px'
        }}>
          📝
        </div>

        {/* Title */}
        <h1 style={{
          color: '#333',
          marginBottom: '10px',
          fontSize: '28px',
          fontWeight: 'bold'
        }}>
          Open in CollabNotes
        </h1>

        {/* Description */}
        <p style={{
          color: '#666',
          marginBottom: '30px',
          lineHeight: '1.6'
        }}>
          You've been invited to collaborate on a note. Open it in the CollabNotes app to start editing together.
        </p>

        {/* Loading State */}
        {isLoading && (
          <div style={{ margin: '20px 0' }}>
            <div style={{
              width: '40px',
              height: '40px',
              border: '3px solid #f3f3f3',
              borderTop: '3px solid #667eea',
              borderRadius: '50%',
              animation: 'spin 1s linear infinite',
              margin: '0 auto'
            }}></div>
            <p style={{ marginTop: '10px', color: '#666' }}>Opening app...</p>
            <style jsx>{`
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            `}</style>
          </div>
        )}

        {/* Buttons */}
        {!isLoading && (
          <div>
            <button
              onClick={handleOpenApp}
              style={{
                width: '100%',
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                color: 'white',
                padding: '15px 40px',
                borderRadius: '10px',
                fontWeight: '600',
                fontSize: '16px',
                border: 'none',
                cursor: 'pointer',
                marginBottom: '15px',
                transition: 'all 0.3s ease'
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.transform = 'translateY(-2px)';
                e.currentTarget.style.boxShadow = '0 10px 20px rgba(102, 126, 234, 0.3)';
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.transform = 'translateY(0)';
                e.currentTarget.style.boxShadow = 'none';
              }}
            >
              Open in App
            </button>

            <a
              href="https://play.google.com/store/apps/details?id=com.hostspica.collabnotes"
              style={{
                display: 'block',
                width: '100%',
                background: '#f0f0f0',
                color: '#333',
                padding: '15px 40px',
                borderRadius: '10px',
                fontWeight: '600',
                fontSize: '16px',
                textDecoration: 'none',
                transition: 'all 0.3s ease'
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.background = '#e0e0e0';
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.background = '#f0f0f0';
              }}
            >
              Download App
            </a>
          </div>
        )}

        {/* Info Box */}
        <div style={{
          background: '#f8f9fa',
          padding: '15px',
          borderRadius: '10px',
          marginTop: '20px',
          fontSize: '14px',
          color: '#666'
        }}>
          <strong style={{ color: '#333' }}>Don't have the app?</strong>
          <br />
          Download CollabNotes to collaborate on notes in real-time with your team.
        </div>

        {/* Store Badge */}
        {!isLoading && (
          <div style={{ marginTop: '20px' }}>
            <a
              href="https://play.google.com/store/apps/details?id=com.hostspica.collabnotes"
              target="_blank"
              rel="noopener noreferrer"
            >
              <img
                src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
                alt="Get it on Google Play"
                style={{ height: '50px', margin: '0 auto' }}
              />
            </a>
          </div>
        )}
      </div>
    </div>
  );
}
