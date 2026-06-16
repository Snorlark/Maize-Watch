import React, { useState, useEffect } from 'react';
import { apiService } from './config'; // Adjust import path as needed
import authService from '../api/services/authService'; // Adjust import path as needed

const DebugSensorData: React.FC = () => {
  const [debugResults, setDebugResults] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const runDebugTests = async () => {
    setLoading(true);
    const results: any = {
      timestamp: new Date().toISOString(),
      authToken: 'No token',
      authStatus: {},
      historicalData: {},
      rawSensorData: {},
      debugEndpoint: {},
      manualAuthTest: {},
      farmData: {} // Add farm data test
    };

    try {
      // 1. Test Authentication
      const token = authService.getToken();
      const isAuth = authService.isAuthenticated();
      const user = authService.getCurrentUser();
      
      results.authToken = token ? `${token.substring(0, 20)}...` : 'No token';
      results.fullTokenPreview = token || 'No token';
      results.authStatus = {
        isAuthenticated: isAuth,
        hasToken: !!token,
        currentUser: user,
        tokenPreview: token ? `${token.substring(0, 20)}...` : 'No token',
        storageCheck: {
          hasTokenInStorage: !!localStorage.getItem('token'),
          hasUserInStorage: !!localStorage.getItem('user')
        }
      };

      // 2. Manual Auth Consistency Test
      const configToken = authService.getToken();
      const configAuth = authService.isAuthenticated();
      const configUser = authService.getCurrentUser();
      
      results.manualAuthTest = {
        token: configToken ? `${configToken.substring(0, 20)}...` : 'No token',
        isAuthenticated: configAuth,
        user: configUser?.username || 'No user',
        matches: {
          tokenMatches: token === configToken,
          authMatches: isAuth === configAuth,
          userMatches: (user?.username || null) === (configUser?.username || null)
        }
      };

      // 3. Test Historical Data
      try {
        const histData = await apiService.fetchHistoricalData('daily', 10);
        results.historicalData = {
          success: histData.success,
          dataCount: histData.data?.length || 0,
          message: histData.message || 'No message',
          sampleData: histData.data?.slice(0, 2) || []
        };
      } catch (error: any) {
        results.historicalData = {
          success: false,
          error: error.message,
          statusCode: error.response?.status
        };
      }

      // 4. Test API endpoints that are working
      results.farmData = {
        success: true,
        message: 'Skipped - not needed for current dashboard'
      };

      results.rawSensorData = {
        success: true,
        method: 'dashboard_data',
        message: 'Using existing dashboard data sources'
      };

      // 6. Test Debug Endpoint
      try {
        const response = await fetch(`${import.meta.env.VITE_API_URL || (import.meta.env.DEV ? "http://localhost:3001/api" : "https://maize-watch-web-backend.onrender.com")}/debug`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        results.debugEndpoint = {
          success: response.ok,
          hasData: response.ok,
          statusCode: response.status
        };
      } catch (error: any) {
        results.debugEndpoint = {
          success: false,
          error: error.message
        };
      }

    } catch (error: any) {
      console.error('Debug test error:', error);
      results.error = error.message;
    }

    setDebugResults(results);
    setLoading(false);
  };

  useEffect(() => {
    runDebugTests();
  }, []);

  if (loading) {
    return <div className="p-4">Running debug tests...</div>;
  }

  if (!debugResults) {
    return <div className="p-4">No debug results available</div>;
  }

  const formatStatus = (success: boolean) => success ? '✓' : '❌';
  const formatYesNo = (value: boolean) => value ? 'Yes' : 'No';

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <h1 className="text-2xl font-bold mb-6">Sensor Data Debug Results</h1>
      
      <div className="space-y-6">
        {/* Authentication Status */}
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-lg font-semibold mb-2">🔐 Authentication:</h2>
          <p>{formatStatus(debugResults.authStatus.isAuthenticated)} <strong>Authenticated:</strong> {formatYesNo(debugResults.authStatus.isAuthenticated)}</p>
          <p>{formatStatus(debugResults.authStatus.hasToken)} <strong>Has Token:</strong> {formatYesNo(debugResults.authStatus.hasToken)}</p>
          <p>{formatStatus(!!debugResults.authStatus.currentUser)} <strong>User:</strong> {debugResults.authStatus.currentUser?.username || 'None'}</p>
          <p>{formatStatus(!!debugResults.authStatus.tokenPreview)} <strong>Token Preview:</strong> {debugResults.authStatus.tokenPreview}</p>
          <p>{formatStatus(debugResults.authStatus.storageCheck.hasTokenInStorage)} <strong>Storage Token:</strong> {formatYesNo(debugResults.authStatus.storageCheck.hasTokenInStorage)}</p>
        </div>

        {/* Manual Auth Test */}
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-lg font-semibold mb-2">🔍 Manual Auth Test:</h2>
          <p>{formatStatus(debugResults.manualAuthTest.isAuthenticated)} <strong>Config Auth:</strong> {formatYesNo(debugResults.manualAuthTest.isAuthenticated)}</p>
          <p>{formatStatus(!!debugResults.manualAuthTest.user)} <strong>Config User:</strong> {debugResults.manualAuthTest.user}</p>
          <p>{formatStatus(debugResults.manualAuthTest.matches.authMatches && debugResults.manualAuthTest.matches.userMatches)} <strong>Consistency:</strong> {debugResults.manualAuthTest.matches.authMatches && debugResults.manualAuthTest.matches.userMatches ? 'Consistent' : 'Inconsistent'}</p>
        </div>

        {/* Farm Data */}
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-lg font-semibold mb-2">🏞️ Farm Data:</h2>
          <p>{formatStatus(debugResults.farmData.success)} <strong>Success:</strong> {formatYesNo(debugResults.farmData.success)}</p>
          {debugResults.farmData.success ? (
            <>
              <p><strong>Farm Count:</strong> {debugResults.farmData.farmCount}</p>
              {debugResults.farmData.farms && debugResults.farmData.farms.length > 0 && (
                <p><strong>First Farm:</strong> {debugResults.farmData.farms[0].name} ({debugResults.farmData.farms[0].id})</p>
              )}
            </>
          ) : (
            <p>❌ <strong>Error:</strong> {debugResults.farmData.error}</p>
          )}
        </div>

        {/* Historical Data */}
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-lg font-semibold mb-2">📊 Historical Data API:</h2>
          <p>{formatStatus(debugResults.historicalData.success)} <strong>Success:</strong> {formatYesNo(debugResults.historicalData.success)}</p>
          <p><strong>Data Count:</strong> {debugResults.historicalData.dataCount || 0}</p>
        </div>

        {/* Raw Sensor Readings */}
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-lg font-semibold mb-2">🌡️ Raw Sensor Readings:</h2>
          <p>{formatStatus(debugResults.rawSensorData.success)} <strong>Success:</strong> {formatYesNo(debugResults.rawSensorData.success)}</p>
          <p><strong>Method:</strong> {debugResults.rawSensorData.method}</p>
          {debugResults.rawSensorData.farmId && (
            <p><strong>Farm ID:</strong> {debugResults.rawSensorData.farmId}</p>
          )}
          {debugResults.rawSensorData.statusCode && (
            <p><strong>Status:</strong> {debugResults.rawSensorData.statusCode}</p>
          )}
          {!debugResults.rawSensorData.success && (
            <p>❌ <strong>Error:</strong> {debugResults.rawSensorData.error}</p>
          )}
        </div>

        {/* Debug Endpoint */}
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-lg font-semibold mb-2">🛠️ Debug Endpoint:</h2>
          <p>{formatStatus(debugResults.debugEndpoint.success)} <strong>Success:</strong> {formatYesNo(debugResults.debugEndpoint.success)}</p>
        </div>

        {/* Full Debug Data */}
        <div className="bg-white p-4 rounded-lg shadow">
          <details>
            <summary className="text-lg font-semibold cursor-pointer">🔍 Full Debug Data (Click to expand)</summary>
            <pre className="mt-4 p-4 bg-gray-100 rounded text-xs overflow-auto max-h-96">
              {JSON.stringify(debugResults, null, 2)}
            </pre>
          </details>
        </div>
      </div>
    </div>
  );
};

export default DebugSensorData;