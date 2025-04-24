
import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Index from './pages/Index';
import SignUpPage from './pages/Signup';
import LoginPage from './pages/Login';
import TechnologyPage from './pages/TechnologyPage';
import SolutionsPage from './pages/SolutionsPage';
import ProductPage from './pages/ProductPage';
import Dashboard from './pages/Dashboard';
import AccountManagement from "./pages/AccountManagement";
import LiveData from "./pages/LiveData";


const App: React.FC = () => {
  return (
    <Routes>
      <Route path="/" element={<Index />} />
      <Route path="/signup" element={<SignUpPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/accountmanagement" element={<AccountManagement />} />
      <Route path="/livedata" element={<LiveData />} />
      <Route path="/technology" element={<TechnologyPage />} />
      <Route path="/solutions" element={<SolutionsPage />} />
      <Route path="/products" element={<ProductPage />} />
      <Route path="/dashboard" element={<Dashboard />} />
    </Routes>
  );
};

export default App;
