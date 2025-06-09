import React, { useState, useEffect, useRef } from "react";
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { User } from '../api/services/authService';
import { Menu, X, ChevronRight, LayoutDashboard, Activity, Users, Settings, Info, LogOut, ScrollText } from "lucide-react";

const Navbar: React.FC = () => {
  const [menuOpen, setMenuOpen] = useState(false);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);
  const [accountModalOpen, setAccountModalOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  // Handle click outside to close menu
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setMenuOpen(false);
      }
    };

    if (menuOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      // Prevent body scroll when menu is open
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.body.style.overflow = 'unset';
    };
  }, [menuOpen]);

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

        {/* Desktop Navigation */}
        <nav className="hidden md:flex mt-3 gap-10 items-center text-[#1E441E] text-sm font-medium">
          <NavLink
            to="/dashboard"
            className={({ isActive }) =>
              isActive 
                ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D] transition-all duration-300"
                : "hover:text-[#347928] transition-colors duration-200"
            }
          >
            Dashboard
          </NavLink>

          <NavLink
            to="/livedata"
            className={({ isActive }) =>
              isActive 
                ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D] transition-all duration-300"
                : "hover:text-[#347928] transition-colors duration-200"
            }
          >
            Live Data
          </NavLink>

          {(user?.role === 'admin' || user?.role === 'super_admin') && (
            <NavLink
              to="/accountmanagement"
              className={({ isActive }) =>
                isActive 
                  ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D] transition-all duration-300"
                  : "hover:text-[#347928] transition-colors duration-200"
              }
            >
              Account Management
            </NavLink>
          )}
          {user?.role === 'super_admin' && (
            <NavLink 
              to="/admin/activity-logs" 
              className={({ isActive }) =>
                isActive 
                  ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D] transition-all duration-300"
                  : "hover:text-[#347928] transition-colors duration-200"
              }
            >
              Activity Log
            </NavLink>
          )}
        </nav>

        {/* Menu Button */}
        <button 
          onClick={() => setMenuOpen(true)} 
          className="text-[#1E441E] p-2 hover:bg-[#E6F0D3] rounded-md transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:ring-opacity-50"
          aria-label="Open menu"
        >
          <Menu size={28} />
        </button>
      </div>

      {/* Menu Overlay */}
      {menuOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 backdrop-blur-sm z-50 transition-opacity duration-300">
          <div 
            ref={menuRef}
            className="absolute top-0 right-0 h-full w-80 bg-white shadow-2xl transform transition-transform duration-300 ease-in-out"
          >
            <div className="flex flex-col h-full">
              {/* Header */}
              <div className="flex justify-between items-center p-6 border-b border-gray-100">
                <h2 className="text-xl font-semibold text-[#1E441E]">Menu</h2>
                <button 
                  onClick={() => setMenuOpen(false)} 
                  className="text-[#1E441E] p-2 hover:bg-[#E6F0D3] rounded-md transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:ring-opacity-50"
                  aria-label="Close menu"
                >
                  <X size={24} />
                </button>
              </div>

              {/* Mobile Navigation Links - Only visible on mobile */}
              <nav className="flex-1 overflow-y-auto p-6 md:hidden">
                <div className="space-y-2">
                  <NavLink
                    to="/dashboard"
                    onClick={() => setMenuOpen(false)}
                    className={({ isActive }) =>
                      `flex items-center px-4 py-3 rounded-lg transition-all duration-200 ${
                        isActive 
                          ? "bg-[#E6F0D3] text-[#456C2D] font-medium" 
                          : "text-[#1E441E] hover:bg-[#F5F9E8]"
                      }`
                    }
                  >
                    <LayoutDashboard size={20} className="mr-3" />
                    Dashboard
                  </NavLink>

                  <NavLink
                    to="/livedata"
                    onClick={() => setMenuOpen(false)}
                    className={({ isActive }) =>
                      `flex items-center px-4 py-3 rounded-lg transition-all duration-200 ${
                        isActive 
                          ? "bg-[#E6F0D3] text-[#456C2D] font-medium" 
                          : "text-[#1E441E] hover:bg-[#F5F9E8]"
                      }`
                    }
                  >
                    <Activity size={20} className="mr-3" />
                    Live Data
                  </NavLink>

                  {(user?.role === 'admin' || user?.role === 'super_admin') && (
                    <NavLink
                      to="/accountmanagement"
                      onClick={() => setMenuOpen(false)}
                      className={({ isActive }) =>
                        `flex items-center px-4 py-3 rounded-lg transition-all duration-200 ${
                          isActive 
                            ? "bg-[#E6F0D3] text-[#456C2D] font-medium" 
                            : "text-[#1E441E] hover:bg-[#F5F9E8]"
                        }`
                      }
                    >
                      <Users size={20} className="mr-3" />
                      Account Management
                    </NavLink>
                  )}

                  {user?.role === 'super_admin' && (
                    <NavLink
                      to="/admin/activity-logs"
                      onClick={() => setMenuOpen(false)}
                      className={({ isActive }) =>
                        `flex items-center px-4 py-3 rounded-lg transition-all duration-200 ${
                          isActive 
                            ? "bg-[#E6F0D3] text-[#456C2D] font-medium" 
                            : "text-[#1E441E] hover:bg-[#F5F9E8]"
                        }`
                      }
                    >
                      <ScrollText size={20} className="mr-3" />
                      Activity Log
                    </NavLink>
                  )}
                </div>
              </nav>

              {/* Menu Actions - Visible on both mobile and desktop */}
              <div className="p-6 border-t border-gray-100 bg-gray-50">
                <div className="space-y-2">
                  <button 
                    className="flex items-center justify-between w-full px-4 py-3 text-[#1E441E] hover:bg-[#E6F0D3] rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:ring-opacity-50"
                    onClick={() => {
                      setAccountModalOpen(true);
                      setMenuOpen(false);
                    }}
                  >
                    <div className="flex items-center">
                      <Settings size={20} className="mr-3" />
                      Account Setting
                    </div>
                    <ChevronRight size={18} />
                  </button>

                  <button 
                    className="flex items-center justify-between w-full px-4 py-3 text-[#1E441E] hover:bg-[#E6F0D3] rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:ring-opacity-50"
                    onClick={() => {
                      setAboutModalOpen(true);
                      setMenuOpen(false);
                    }}
                  >
                    <div className="flex items-center">
                      <Info size={20} className="mr-3" />
                      About
                    </div>
                    <ChevronRight size={18} />
                  </button>

                  <button
                    onClick={() => {
                      handleLogout();
                      setMenuOpen(false);
                    }}
                    className="flex items-center justify-between w-full px-4 py-3 text-[#1E441E] hover:bg-[#E6F0D3] rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:ring-opacity-50"
                  >
                    <div className="flex items-center">
                      <LogOut size={20} className="mr-3" />
                      Log out
                    </div>
                    <ChevronRight size={18} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {aboutModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-red rounded-lg w-full max-w-lg mx-4 p-6 relative">
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

// Add this to your global CSS or Tailwind config
const styles = `
@keyframes slide-in {
  from {
    transform: translateX(100%);
  }
  to {
    transform: translateX(0);
  }
}

.animate-slide-in {
  animation: slide-in 0.3s ease-out;
}
`;

export default Navbar;