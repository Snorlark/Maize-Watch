// src/components/ConnectionTest.tsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';

const ConnectionTest: React.FC = () => {
  const [result, setResult] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [serverInfo, setServerInfo] = useState({
    apiUrl: import.meta.env.VITE_API_URL || 'Not set',
    nodeEnv: import.meta.env.MODE || 'development'
  });

  // Try a connection on component mount
  useEffect(() => {
    testConnection();
  }, []);

  const testConnection = async () => {
    setLoading(true);
    setResult('Testing connection...');
    
    try {
      // First, try the root endpoint
      await testEndpoint('/');
    } catch (rootError) {
      try {
        // If root fails, try the health endpoint
        await testEndpoint('/health');
      } catch (healthError) {
        try {
          // If health fails, try the auth endpoint
          await testEndpoint('/auth');
        } catch (authError) {
          // All attempts failed
          setResult(`❌ Failed to connect to any endpoint.\n\nDetails:\n${authError}`);
        }
      }
    } finally {
      setLoading(false);
    }
  };

  const testEndpoint = async (endpoint: string) => {
    const apiUrl = serverInfo.apiUrl;
    try {
      const response = await axios.get(`${apiUrl}${endpoint}`, {
        timeout: 10000
      });
      setResult(`✅ Connection successful to ${endpoint}!\n\nStatus: ${response.status}\nResponse: ${JSON.stringify(response.data, null, 2)}`);
      return true;
    } catch (error: any) {
      if (axios.isAxiosError(error)) {
        if (error.response) {
          setResult(`⚠️ Server responded with status ${error.response.status} at ${endpoint}\n\nData: ${JSON.stringify(error.response.data, null, 2)}`);
          // A 404 or other error code still means we connected to the server
          if (error.response.status !== 0) {
            return true;
          }
        } else if (error.request) {
          throw `No response received when trying ${endpoint}. The server may be down or unreachable.`;
        } else {
          throw `Error setting up request to ${endpoint}: ${error.message}`;
        }
      }
      throw error instanceof Error ? error.message : String(error);
    }
  };

  return (
    <div style={{ margin: '20px', padding: '20px', border: '1px solid #ddd', borderRadius: '8px', maxWidth: '800px' }}>
      <h2 style={{ marginTop: 0 }}>API Connection Test</h2>
      
      <div style={{ marginBottom: '20px' }}>
        <h3>Environment Information:</h3>
        <ul>
          <li><strong>API URL:</strong> {serverInfo.apiUrl}</li>
          <li><strong>Node Environment:</strong> {serverInfo.nodeEnv}</li>
        </ul>
      </div>
      
      <button 
        onClick={testConnection}
        disabled={loading}
        style={{ 
          padding: '10px 20px',
          backgroundColor: '#4285f4',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          fontSize: '16px',
          cursor: loading ? 'not-allowed' : 'pointer'
        }}
      >
        {loading ? 'Testing Connection...' : 'Test Server Connection'}
      </button>
      
      {result && (
        <div style={{ 
          marginTop: '20px', 
          padding: '15px', 
          backgroundColor: result.includes('✅') ? '#e6f4ea' : 
                           result.includes('⚠️') ? '#fef7e0' : '#fce8e6', 
          borderRadius: '4px',
          whiteSpace: 'pre-wrap',
          fontFamily: 'monospace'
        }}>
          {result}
        </div>
      )}
      
      <div style={{ marginTop: '20px' }}>
        <h3>Troubleshooting Tips:</h3>
        <ul>
          <li>Make sure your server is running</li>
          <li>Check that your API URL in .env file is correct</li>
          <li>Verify that CORS is properly configured on your server</li>
          <li>Check your network connection</li>
          <li>Look at your browser's Network tab in Developer Tools for more details</li>
        </ul>
      </div>
    </div>
  );
};

export default ConnectionTest;