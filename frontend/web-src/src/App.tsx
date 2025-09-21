import React from 'react';
import { Routes, Route, Navigate, Outlet } from 'react-router-dom';

// Admin imports
import { AuthProvider } from '../web-admin/src/contexts/AuthContext';
import { UserProvider } from '../web-admin/src/contexts/UserContext';
import ProtectedRoute from '../web-admin/src/components/auth/ProtectedRoute';

// Admin Components
import LoginForm from '../web-admin/src/components/auth/LoginForm';
import AdminNavbar from '../web-admin/src/components/Sidebar';
import Unauthorized from '../web-admin/src/pages/Unauthorized';
import AdminNotFound from '../web-admin/src/pages/NotFound';

// Admin Pages
import Dashboard from '../web-admin/src/pages/Dashboard';
import AccountManagement from '../web-admin/src/pages/AccountManagement';
import LiveData from '../web-admin/src/pages/LiveData';
import DataHistory from '../web-admin/src/pages/DataHistory'; 
import ActivityLogPage from '../web-admin/src/pages/ActivityLog'; 
import AdminLogs from '../web-admin/src/pages/AdminLogs';

// Public Pages
import Index from '../web-public/src/pages/Index';
import TechnologyPage from '../web-public/src/pages/TechnologyPage';
import SolutionsPage from '../web-public/src/pages/SolutionsPage';
import ProductPage from '../web-public/src/pages/ProductPage';
import HeaderMenuPage from '../web-public/src/pages/HeaderMenu';
import GetAppPage from '../web-public/src/pages/GetApp';

// Layout component for authenticated admin pages
const AdminAuthenticatedLayout = () => {
  return (
    <>
      <AdminNavbar />
      <Outlet />
    </>
  );
};

// Main App Component
const App: React.FC = () => {
  const ADMIN_PATH = import.meta.env.VITE_ADMIN_PATH || 'admin-portal-xyz123';

  return (
    <AuthProvider>
      <UserProvider>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<Index />} />
        <Route path="/technology" element={<TechnologyPage />} />
        <Route path="/solutions" element={<SolutionsPage />} />
        <Route path="/product" element={<ProductPage />} />
        <Route path="/header-menu" element={<HeaderMenuPage />} />
        <Route path="/getapp" element={<GetAppPage />} />

        {/* Admin Routes */}
        <Route path={`${ADMIN_PATH}`}>
          <Route index element={<Navigate to="login" replace />} />
          <Route path="login" element={<LoginForm />} />
          <Route path="unauthorized" element={<Unauthorized />} />

          {/* Protected Routes */}
          <Route element={<ProtectedRoute />}>
            <Route element={<AdminAuthenticatedLayout />}>
              <Route path="dashboard" element={<Dashboard />} />
              <Route path="livedata" element={<LiveData />} />
              <Route path="datahistory" element={<DataHistory />} />
            </Route>
          </Route>

          {/* Admin-only routes */}
          <Route element={<ProtectedRoute requireAdmin={true} redirectPath="login" />}>
            <Route element={<AdminAuthenticatedLayout />}>
              <Route
                path="accountmanagement"
                element={
                  <UserProvider>
                    <AccountManagement />
                  </UserProvider>
                }
              />
            </Route>
          </Route>

          {/* Super Admin-only route */}
          <Route element={<ProtectedRoute requireSuperAdmin={true} redirectPath="login" />}>
            <Route element={<AdminAuthenticatedLayout />}>
              <Route path="activity-logs" element={<ActivityLogPage />} />
            </Route>
          </Route>

          {/* Admin Logs route */}
          <Route element={<ProtectedRoute requireAdmin={true} redirectPath="login" />}>
            <Route element={<AdminAuthenticatedLayout />}>
              <Route path="logs" element={<AdminLogs />} />
            </Route>
          </Route>

          {/* Catch-all for admin not found */}
          <Route path="*" element={<AdminNotFound />} />
        </Route>
      </Routes>
      </UserProvider>
    </AuthProvider>
  );
};

export default App;
