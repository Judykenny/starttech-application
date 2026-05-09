import React, { useState, useEffect } from 'react';

function App() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const apiUrl = process.env.REACT_APP_API_URL || '';
    fetch(`${apiUrl}/health`)
      .then(res => res.json())
      .then(data => {
        setHealth(data);
        setLoading(false);
      })
      .catch(() => {
        setHealth({ status: 'unreachable' });
        setLoading(false);
      });
  }, []);

  return (
    <div style={{ fontFamily: 'Arial, sans-serif', maxWidth: '800px', margin: '50px auto', padding: '20px' }}>
      <h1>StartTech Application</h1>
      <p>Frontend deployed via CloudFront + S3</p>
      <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#f5f5f5', borderRadius: '8px' }}>
        <h3>Backend Health Status</h3>
        {loading ? (
          <p>Checking backend...</p>
        ) : (
          <pre>{JSON.stringify(health, null, 2)}</pre>
        )}
      </div>
      <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#e8f5e9', borderRadius: '8px' }}>
        <h3>Environment</h3>
        <p>API URL: {process.env.REACT_APP_API_URL || 'not set'}</p>
        <p>Environment: {process.env.REACT_APP_ENV || 'development'}</p>
      </div>
    </div>
  );
}

export default App;
