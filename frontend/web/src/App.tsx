// src/App.tsx
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Pages
import Index from './pages/Index';
import TechnologyPage from './pages/TechnologyPage';
import SolutionsPage from './pages/SolutionsPage';
import ProductPage from './pages/ProductPage';
import Dashboard from './pages/Dashboard';
import AccountManagement from './pages/AccountManagement';
import LiveData from './pages/LiveData';
import HeaderMenuPage from './pages/HeaderMenu';
import GetAppPage from './pages/GetApp';

// Components for Auth
import LoginForm from './components/auth/LoginForm';
import RegisterForm from './components/auth/RegistrationForm';

// Testing Component
import ConnectionTest from './components/ConnectionTest';

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
        <Route path="/getapp" element={<GetAppPage />} />
        <Route path="/test-connection" element={<ConnectionTest />} />

        {/* Protected Routes */}
        <Route element={<ProtectedRoute redirectPath="/login" />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/accountmanagement" element={<AccountManagement />} />
          <Route path="/livedata" element={<LiveData />} />
        </Route>

        {/* Fallback */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  );
};

export default App;
