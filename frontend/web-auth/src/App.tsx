// src/App.tsx
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { UserProvider } from './contexts/UserContext';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Your existing pages
import Dashboard from './pages/Dashboard';
import AccountManagement from "./pages/AccountManagement";
import LiveData from "./pages/LiveData";
import LoginForm from './components/auth/LoginForm';
import Unauthorized from './pages/Unauthorized';

const App: React.FC = () => {
  return (
    <AuthProvider>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<LoginForm />} />
        <Route path="/login" element={<LoginForm />} />
        <Route path="/unauthorized" element={<Unauthorized />} />

        {/* Protected Routes - Require Authentication */}
        <Route element={<ProtectedRoute redirectPath="/login" />}>
          <Route path="/dashboard" element={<Dashboard />} />
          {/* Wrap AccountManagement with UserProvider */}
          <Route path="/accountmanagement" element={
            <UserProvider>
              <AccountManagement />
            </UserProvider>
          } />
          <Route path="/livedata" element={<LiveData />} />
        </Route>

        {/* Catch-all route */}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </AuthProvider>
  );
};

export default App;