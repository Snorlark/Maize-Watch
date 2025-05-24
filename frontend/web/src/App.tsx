// src/App.tsx
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';

// Your existing pages
import Index from './pages/Index';
import TechnologyPage from './pages/TechnologyPage';
import SolutionsPage from './pages/SolutionsPage';
import ProductPage from './pages/ProductPage';
import HeaderMenuPage from './pages/HeaderMenu';
import GetAppPage from './pages/GetApp';

const App: React.FC = () => {
  return (

    <Routes>
      {/* Public Routes */}
      <Route path="/" element={<Index />} />
      <Route path="/technology" element={<TechnologyPage />} />
      <Route path="/solutions" element={<SolutionsPage />} />
      <Route path="/product" element={<ProductPage />} />
      <Route path="/header-menu" element={<HeaderMenuPage />} />
      <Route path="/getapp" element={<GetAppPage />} />

      {/* Catch-all route */}
      <Route path="*" element={<Navigate to="/" />} />
    </Routes>
  );
};

export default App;