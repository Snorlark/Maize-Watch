// src/App.tsx
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { UserProvider } from './contexts/UserContext';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Your existing pages
import Index from './pages/Index';
import TechnologyPage from './pages/TechnologyPage';
import SolutionsPage from './pages/SolutionsPage';
import ProductPage from './pages/ProductPage';
import Dashboard from './pages/Dashboard';
import AccountManagement from "./pages/AccountManagement";
import LiveData from "./pages/LiveData";
import HeaderMenuPage from './pages/HeaderMenu';
import ConnectionTest from './components/ConnectionTest';
import LoginForm from './components/auth/LoginForm';
import Unauthorized from './pages/Unauthorized';
import RegisterForm from './components/auth/RegistrationForm'; // Add this for testing

const App: React.FC = () => {
  return (
    <AuthProvider>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<Index />} />
        <Route path="/login" element={<LoginForm />} />
        <Route path="/technology" element={<TechnologyPage />} />
        <Route path="/solutions" element={<SolutionsPage />} />
        <Route path="/product" element={<ProductPage />} />
        <Route path="/header-menu" element={<HeaderMenuPage />} />
        <Route path="/connection-test" element={<ConnectionTest />} />
        <Route path="/unauthorized" element={<Unauthorized />} />
        <Route path="/register-form" element={<RegisterForm />} /> {/* Add this route for testing */}

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