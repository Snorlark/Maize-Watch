import React from 'react';
import { Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { UserProvider } from './contexts/UserContext';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Components
import LoginForm from './components/auth/LoginForm';
import Navbar from './components/Navbar';
import Unauthorized from './pages/Unauthorized';
import NotFound from './pages/NotFound';

// Pages
import Dashboard from './pages/Dashboard';
import AccountManagement from './pages/AccountManagement';
import LiveData from './pages/LiveData';
import ActivityLogPage from './pages/ActivityLog'; // <--- Import the ActivityLogPage
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
        {/* Public Routes */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="/login" element={<LoginForm />} />
        <Route path="/unauthorized" element={<Unauthorized />} />

        {/* Protected Routes that require authentication */}
        <Route element={<ProtectedRoute />}>
          <Route element={<AuthenticatedLayout />}>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/livedata" element={<LiveData />} />
          </Route>
        </Route>

        {/* Admin-only routes */}
        <Route element={<ProtectedRoute requireAdmin={true} redirectPath="/login" />}>
          <Route element={<AuthenticatedLayout />}>
            <Route
              path="/accountmanagement"
              element={
                <UserProvider>
                  <AccountManagement />
                </UserProvider>
              }
            />
          </Route>
        </Route>

        {/* Super Admin-only route */}
        <Route element={<ProtectedRoute requireSuperAdmin={true} redirectPath="/login" />}>
          <Route element={<AuthenticatedLayout />}>
            <Route path="/admin/activity-logs" element={<ActivityLogPage />} />
          </Route>
        </Route>

        {/* Admin Logs route */}
        <Route path="/admin/logs" element={
          <ProtectedRoute>
            <AdminLogs />
          </ProtectedRoute>
        } />

        {/* Not found route */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </AuthProvider>
  );
};

export default App;
