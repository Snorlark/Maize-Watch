import React, { useState } from "react";
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { User } from '../api/services/authService';
import { Menu, X, ChevronRight } from "lucide-react";

const Navbar: React.FC = () => {
  const [menuOpen, setMenuOpen] = useState(false);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);
  const [accountModalOpen, setAccountModalOpen] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();


  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  // Helper function to display user identifier
  const getUserDisplayName = (user: User | null) => {
    if (!user) return '';
    return user.username || user.userId || 'User';
  };

   const [accountInfo, setAccountInfo] = useState({
    firstName: "Juan",
    lastName: "Dela Cruz",
    email: "juandelacruz@gmail.com"
  });
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setAccountInfo(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSave = () => {
    // Here you would typically send this data to your backend
    console.log("Saving account info:", accountInfo);
    setAccountModalOpen(false);
  };

  return (
    <header className="sticky top-0 z-50 bg-[#E6F0D3] py-10 px-1 font-montserrat">
      <div className="max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-2">
          <img
            src="/maizewatch.png"
            alt="Maize Watch Logo"
            className="h-20 w-80"
          />
        </div>

        <nav className="hidden md:flex mt-3 gap-10 items-center text-[#1E441E] text-sm font-medium">
          <NavLink
            to="/dashboard"
            className={({ isActive }) =>
              isActive ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D]"
                : " hover:text-[#347928] transition"
            }
          >
            Dashboard
          </NavLink>

          <NavLink
            to="/livedata"
            className={({ isActive }) =>
              isActive ? "relative  pb-2  after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D]"
                : "hover:text-[#347928] transition"
            }
          >
            Live Data
          </NavLink>

          {user?.role === 'admin' && (
            <NavLink
              to="/accountmanagement"
              className={({ isActive }) =>
                isActive ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D]"
                  : "hover:text-[#456C2D] transition"
              }
            >
              Account Management
            </NavLink>
          )}
        </nav>
        <button onClick={() => setMenuOpen(true)} className="text-[#1E441E]">
          <Menu size={28} />
        </button>
      </div>

      {menuOpen && (
        <div className="absolute top-24 right-4 w-72 bg-white shadow-xl z-50 p-6 rounded-2xl border border-gray-200 animate-fade-in">
          <div className="flex justify-end mb-4">
            <button onClick={() => setMenuOpen(false)} className="text-[#1E441E]">
              <X size={24} />
            </button>
          </div>
          <ul className="space-y-5 text-base font-semibold">
            <li 
              className="flex justify-between items-center text-[#1E441E] hover:opacity-80 cursor-pointer"
              onClick={() => {
                setAccountModalOpen(true);
                setMenuOpen(false);
              }}
            >
              Account Setting <ChevronRight size={18} />
            </li>
            <li 
              className="flex justify-between items-center text-[#1E441E] hover:opacity-80 cursor-pointer"
              onClick={() => {
                setAboutModalOpen(true);
                setMenuOpen(false);
              }}
            >
              About <ChevronRight size={18} />
            </li>
            <NavLink
              to="/login"
              onClick={handleLogout}>
              <li className="flex justify-between items-center text-gray-700 hover:opacity-80 cursor-pointer text-[#1E441E]">
                Log out
                <ChevronRight size={18} />
              </li>
            </NavLink>
          </ul>
        </div>
      )}

      {aboutModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg w-full max-w-lg mx-4 p-6 relative">
            <button 
              onClick={() => setAboutModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={20} />
            </button>
            
            <div className="flex items-center gap-2 mb-4">
              <div className="rounded-full">
                <img 
                  src="/maizewatchlogo.png" 
                  alt="Maize Watch Icon" 
                  className="h-10 w-10"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/24";
                  }}
                />
              </div>
              <span className="text-[#456C2D] font-bold uppercase tracking-wider">Maize Watch</span>
            </div>
            
            <div className="text-sm text-gray-700 mb-6">
              <p>
                Maize Watch empowers corn farmers to achieve higher yields and greater 
                profitability through data-driven insights. Comprehensive data visualizations 
                provide clarity on performance across all key health and environmental conditions, 
                enabling timely interventions and optimized resource allocation. Integrated 
                account management tools allow farmers to track and analyze sensor data, 
                identify areas for improvement, and implement best practices. The result is 
                increased agricultural efficiency, reduced costs, and improved overall farm 
                productivity.
              </p>
            </div>
            
            <div className="border-t pt-4">
              <div className="text-xs text-gray-500 mb-2">Contact us on:</div>
              <div className="flex gap-3">
            <img src="/footer/instagram.png" alt="Instagram" className="w-5 h-5 cursor-pointer" />
            <img src="/footer/github.png" alt="GitHub" className="w-5 h-5 cursor-pointer" />
            <img src="/footer/linkedin.png" alt="LinkedIn" className="w-5 h-5 cursor-pointer" />
            <img src="/footer/x.png" alt="X" className="w-4 h-4 cursor-pointer" />
          </div>
            </div>
          </div>
        </div>
      )}

      {/* Account Settings Modal */}
      {accountModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-[#EBEFDF] rounded-lg w-full max-w-md mx-4 p-6 relative">
            <button 
              onClick={() => setAccountModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={20} />
            </button>
            
            <h2 className="text-lg font-semibold text-gray-800 mb-6">Edit Account Information</h2>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm text-gray-700 mb-1">First Name:</label>
                <input
                  type="text"
                  name="firstName"
                  value={accountInfo.firstName}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md"
                />
              </div>
              
              <div>
                <label className="block text-sm text-gray-700 mb-1">Last Name:</label>
                <input
                  type="text"
                  name="lastName"
                  value={accountInfo.lastName}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md"
                />
              </div>
              
              <div>
                <label className="block text-sm text-gray-700 mb-1">Email:</label>
                <input
                  type="email"
                  name="email"
                  value={accountInfo.email}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md"
                />
              </div>
              
              <div className="pt-4">
                <button
                  onClick={handleSave}
                  className="bg-[#456C2D] text-white font-medium py-2 px-4 rounded-md w-full hover:bg-[#3A5C25] transition"
                >
                  Save
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      
    </header>
  );
};

export default Navbar;