import React from 'react';
import { Link } from 'react-router-dom';

const Navbar: React.FC = () => {
  return (
    <nav className="bg-white shadow-md py-4">
      <div className="container mx-auto px-4 flex justify-between items-center">
        <Link to="/" className="text-[#356B2C] font-bold text-xl">
          Maize Watch
        </Link>
        <div className="space-x-6">
          <Link to="/live-data" className="text-[#356B2C] hover:text-green-700">Live Data</Link>
          <a href="/dashboard" className="text-[#356B2C] hover:text-green-700">Admin Dashboard</a>
          <Link to="/profile" className="text-[#356B2C] hover:text-green-700">Profile</Link>
        </div>
      </div>
    </nav>
  );
};

export default Navbar; 