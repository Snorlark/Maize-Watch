// src/App.tsx
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { UserProvider } from './contexts/UserContext';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Your existing pages
import Index from './pages/Index';
import SignUpPage from './pages/Signup';
import LoginPage from './pages/Login';
import TechnologyPage from './pages/TechnologyPage';
import SolutionsPage from './pages/SolutionsPage';
import ProductPage from './pages/ProductPage';
import Dashboard from './pages/Dashboard';
import AccountManagement from "./pages/AccountManagement";
import LiveData from "./pages/LiveData";
import HeaderMenuPage from './pages/HeaderMenu';
import ConnectionTest from './components/ConnectionTest';
import LoginForm from './components/auth/LoginForm';
import RegisterForm from './components/auth/RegistrationForm'; // Add this for testing

const App: React.FC = () => {
  return (
    <AuthProvider>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<Index />} />
        <Route path="/signup" element={<RegisterForm />} />
        <Route path="/login" element={<LoginForm />} />
        <Route path="/technology" element={<TechnologyPage />} />
        <Route path="/solutions" element={<SolutionsPage />} />
        <Route path="/products" element={<ProductPage />} />
        <Route path="/headermenu" element={<HeaderMenuPage />} />
        <Route path="/test-connection" element={<ConnectionTest />} /> {/* Add this route for testing */}

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
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  );
};

export default App;