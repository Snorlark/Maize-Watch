import React from 'react';
import { Routes, Route } from 'react-router-dom';

// Landing Pages
import Index from './pages/Index';
import TechnologyPage from './pages/TechnologyPage';
import SolutionsPage from './pages/SolutionsPage';
import ProductPage from './pages/ProductPage';

// Auth Pages
import SignUpPage from './pages/Signup';
import LoginPage from './pages/Login';

// Dashboard Pages
import Dashboard from './pages/Dashboard';
import AccountManagement from './pages/AccountManagement';
import LiveData from './pages/LiveData';

const App: React.FC = () => {
  return (
    <Routes>
      {/* Landing Pages */}
      <Route path="/" element={<Index />} />
      <Route path="/technology" element={<TechnologyPage />} />
      <Route path="/solutions" element={<SolutionsPage />} />
      <Route path="/products" element={<ProductPage />} />

      {/* Auth Routes */}
      <Route path="/auth">
        <Route path="login" element={<LoginPage />} />
        <Route path="signup" element={<SignUpPage />} />
      </Route>

      {/* Dashboard Routes */}
      <Route path="/dashboard">
        <Route path="data-history" element={<Dashboard />} /> {/* default: /dashboard */}
        <Route path="account-management" element={<AccountManagement />} />
        <Route path="live-data" element={<LiveData />} />
      </Route>
    </Routes>
  );
};

export default App;
