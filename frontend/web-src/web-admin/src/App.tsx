import React from 'react';
import { Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { UserProvider } from './contexts/UserContext';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Components
import LoginForm from './components/auth/LoginForm';
import Navbar from './components/Sidebar';
import Unauthorized from './pages/Unauthorized';
import NotFound from './pages/NotFound';

// Pages
import Dashboard from './pages/Dashboard';
import AccountManagement from './pages/AccountManagement';
import LiveData from './pages/LiveData';
import DataHistory from './pages/DataHistory'; 
import ActivityLogPage from './pages/ActivityLog'; 
import AdminLogs from './pages/AdminLogs';

// Layout component for authenticated pages with Navbar
const AuthenticatedLayout = () => {
  return (
    <>
      <Navbar />
      <Outlet />
    </>
  );
};

const App: React.FC = () => {
  return (
    <AuthProvider>
      <Routes>
        {/* Public Routes - Updated for new admin portal path */}
        <Route index element={<Navigate to="admin-portal-xyz123/login" replace />} />
        <Route path="admin-portal-xyz123/login" element={<LoginForm />} />
        <Route path="unauthorized" element={<Unauthorized />} />

        {/* Protected Routes that require authentication */}
        <Route element={<ProtectedRoute />}>
          <Route element={<AuthenticatedLayout />}>
            <Route path="admin-portal-xyz123/dashboard" element={<Dashboard />} />
            <Route path="admin-portal-xyz123/livedata" element={<LiveData />} />
            <Route path="admin-portal-xyz123/datahistory" element={<DataHistory />} />
          </Route>
        </Route>

        {/* Super Admin only: user management, activity logs */}
        <Route element={<ProtectedRoute requireSuperAdmin={true} redirectPath="admin-portal-xyz123/login" />}>
          <Route element={<AuthenticatedLayout />}>
            <Route path="admin-portal-xyz123/activity-logs" element={<ActivityLogPage />} />
            <Route
              path="admin-portal-xyz123/accountmanagement"
              element={
                <UserProvider>
                  <AccountManagement />
                </UserProvider>
              }
            />
          </Route>
        </Route>

        {/* Admin Logs route */}
        <Route element={<ProtectedRoute requireAdmin={true} redirectPath="admin-portal-xyz123/login" />}>
          <Route element={<AuthenticatedLayout />}>
            <Route path="admin-portal-xyz123/logs" element={<AdminLogs />} />
          </Route>
        </Route>

        {/* Not found route */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </AuthProvider>
  );
};

export default App;
