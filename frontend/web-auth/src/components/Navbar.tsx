import React, { useState, useEffect, useRef } from "react";
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { User } from '../api/services/authService';
import { Menu, X, ChevronRight, LayoutDashboard, Activity, Users, Settings, Info, LogOut, ScrollText, ChevronDown } from "lucide-react";
import AccountSettingsModal from './AccountSettingsModal';
import AboutModal from './AboutModal';
import LogoutConfirmationModal from './LogoutConfirmationModal';

const Navbar: React.FC = () => {
  const [menuOpen, setMenuOpen] = useState(false);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);
  const [accountModalOpen, setAccountModalOpen] = useState(false);
  const [logoutModalOpen, setLogoutModalOpen] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const userDropdownRef = useRef<HTMLDivElement>(null);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  // Handle click outside to close menu
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setMenuOpen(false);
      }
      if (userDropdownRef.current && !userDropdownRef.current.contains(event.target as Node)) {
        setUserDropdownOpen(false);
      }
    };

    if (menuOpen || userDropdownOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      // Prevent body scroll when menu is open
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.body.style.overflow = 'unset';
    };
  }, [menuOpen, userDropdownOpen]);

  // Helper function to display user identifier
  const getUserDisplayName = (user: User | null) => {
    if (!user) return '';
    return user.fullName || user.username || 'User';
  };

  // Helper function to get user initials
  const getUserInitials = (user: User | null) => {
    if (!user) return 'U';
    const name = user.fullName || user.username || 'User';
    return name.split(' ').map(n => n.charAt(0).toUpperCase()).join('').slice(0, 2);
  };

  // Handle logout confirmation
  const handleLogoutConfirm = async () => {
    setIsLoggingOut(true);
    try {
      logout();
      navigate('/login');
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      setIsLoggingOut(false);
      setLogoutModalOpen(false);
    }
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

          {(user?.role === 'admin' || user?.role === 'super_admin') && (
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

        {/* User Menu */}
        <div className="flex items-center gap-4">
          {/* Desktop User Profile - Clickable with Dropdown */}
          <div className="hidden md:block relative" ref={userDropdownRef}>
            <button
              onClick={() => setUserDropdownOpen(!userDropdownOpen)}
              className="flex items-center gap-2 hover:bg-[#F5F9E8] p-2 rounded-lg transition-colors cursor-pointer"
            >
              <div className="w-8 h-8 bg-[#456C2D] rounded-full flex items-center justify-center">
                <span className="text-white text-sm font-medium">
                  {getUserInitials(user)}
                </span>
              </div>
              <span className="text-sm font-medium text-[#1E441E]">{getUserDisplayName(user)}</span>
              <ChevronDown className={`w-4 h-4 text-[#1E441E] transition-transform ${userDropdownOpen ? 'rotate-180' : ''}`} />
            </button>

            {/* Desktop User Dropdown Menu */}
            {userDropdownOpen && (
              <div className="absolute right-0 top-full mt-3 w-72 bg-white rounded-xl shadow-2xl border border-gray-200 py-3 z-50">
                <div className="px-6 py-4 border-b border-gray-100">
                  <p className="text-lg font-semibold text-gray-900">{getUserDisplayName(user)}</p>
                  <p className="text-sm text-gray-500 capitalize mt-1">{user?.role?.replace('_', ' ')}</p>
                </div>
                
                <div className="py-2">
                  <button
                    onClick={() => {
                      setAccountModalOpen(true);
                      setUserDropdownOpen(false);
                    }}
                    className="flex items-center w-full px-6 py-4 text-base text-gray-700 hover:bg-[#8B4513] hover:text-[#F5F5DC] transition-colors cursor-pointer"
                  >
                    <Settings className="w-5 h-5 mr-4" />
                    Account Settings
                  </button>
                  
                  <button
                    onClick={() => {
                      setAboutModalOpen(true);
                      setUserDropdownOpen(false);
                    }}
                    className="flex items-center w-full px-6 py-4 text-base text-gray-700 hover:bg-[#8B4513] hover:text-[#F5F5DC] transition-colors cursor-pointer"
                  >
                    <Info className="w-5 h-5 mr-4" />
                    About
                  </button>
                  
                  <div className="border-t border-gray-100 my-2"></div>
                  
                  <button
                    onClick={() => {
                      setLogoutModalOpen(true);
                      setUserDropdownOpen(false);
                    }}
                    className="flex items-center w-full px-6 py-4 text-base text-red-600 hover:bg-red-50 transition-colors cursor-pointer"
                  >
                    <LogOut className="w-5 h-5 mr-4" />
                    Logout
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Mobile Menu Button */}
        <button 
            onClick={() => setMenuOpen(!menuOpen)}
            className="md:hidden p-2 hover:bg-[#F5F9E8] rounded-lg transition-colors"
            aria-label="Toggle menu"
        >
            {menuOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {menuOpen && (
        <div className="md:hidden fixed inset-0 bg-white z-50">
          <div ref={menuRef} className="h-full flex flex-col">
            {/* Mobile Menu Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-[#456C2D] rounded-full flex items-center justify-center">
                  <span className="text-white text-lg font-medium">
                    {getUserInitials(user)}
                  </span>
                </div>
                <div>
                  <p className="text-lg font-semibold text-gray-900">{getUserDisplayName(user)}</p>
                  <p className="text-sm text-gray-500 capitalize">{user?.role?.replace('_', ' ')}</p>
                </div>
              </div>
                <button 
                  onClick={() => setMenuOpen(false)} 
                className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  <X size={24} />
                </button>
              </div>

            {/* Mobile Navigation */}
            <nav className="flex-1 p-6">
              <div className="space-y-3">
                  <NavLink
                    to="/dashboard"
                    onClick={() => setMenuOpen(false)}
                    className={({ isActive }) =>
                    `flex items-center px-6 py-4 rounded-xl transition-all duration-200 ${
                        isActive 
                        ? "bg-[#E6F0D3] text-[#456C2D] font-semibold" 
                          : "text-[#1E441E] hover:bg-[#F5F9E8]"
                      }`
                    }
                  >
                  <LayoutDashboard size={24} className="mr-4" />
                  <span className="text-lg">Dashboard</span>
                  </NavLink>

                  <NavLink
                    to="/livedata"
                    onClick={() => setMenuOpen(false)}
                    className={({ isActive }) =>
                    `flex items-center px-6 py-4 rounded-xl transition-all duration-200 ${
                        isActive 
                        ? "bg-[#E6F0D3] text-[#456C2D] font-semibold" 
                          : "text-[#1E441E] hover:bg-[#F5F9E8]"
                      }`
                    }
                  >
                  <Activity size={24} className="mr-4" />
                  <span className="text-lg">Live Data</span>
                  </NavLink>

                  {(user?.role === 'admin' || user?.role === 'super_admin') && (
                    <NavLink
                      to="/accountmanagement"
                      onClick={() => setMenuOpen(false)}
                      className={({ isActive }) =>
                      `flex items-center px-6 py-4 rounded-xl transition-all duration-200 ${
                          isActive 
                          ? "bg-[#E6F0D3] text-[#456C2D] font-semibold" 
                            : "text-[#1E441E] hover:bg-[#F5F9E8]"
                        }`
                      }
                    >
                    <Users size={24} className="mr-4" />
                    <span className="text-lg">Account Management</span>
                    </NavLink>
                  )}

                {(user?.role === 'admin' || user?.role === 'super_admin') && (
                    <NavLink
                      to="/admin/activity-logs"
                      onClick={() => setMenuOpen(false)}
                      className={({ isActive }) =>
                      `flex items-center px-6 py-4 rounded-xl transition-all duration-200 ${
                          isActive 
                          ? "bg-[#E6F0D3] text-[#456C2D] font-semibold" 
                            : "text-[#1E441E] hover:bg-[#F5F9E8]"
                        }`
                      }
                    >
                    <ScrollText size={24} className="mr-4" />
                    <span className="text-lg">Activity Log</span>
                    </NavLink>
                  )}
                </div>
              </nav>

            {/* Mobile Menu Actions */}
              <div className="p-6 border-t border-gray-100 bg-gray-50">
              <div className="space-y-3">
                  <button 
                  className="flex items-center justify-between w-full px-6 py-4 text-[#1E441E] hover:bg-[#8B4513] hover:text-[#F5F5DC] rounded-xl transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:ring-opacity-50 cursor-pointer"
                    onClick={() => {
                      setAccountModalOpen(true);
                      setMenuOpen(false);
                    }}
                  >
                    <div className="flex items-center">
                    <Settings size={24} className="mr-4" />
                    <span className="text-lg">Account Settings</span>
                    </div>
                  <ChevronRight size={20} />
                  </button>

                  <button 
                  className="flex items-center justify-between w-full px-6 py-4 text-[#1E441E] hover:bg-[#8B4513] hover:text-[#F5F5DC] rounded-xl transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:ring-opacity-50 cursor-pointer"
                    onClick={() => {
                      setAboutModalOpen(true);
                      setMenuOpen(false);
                    }}
                  >
                    <div className="flex items-center">
                    <Info size={24} className="mr-4" />
                    <span className="text-lg">About</span>
                    </div>
                  <ChevronRight size={20} />
                  </button>

                  <button
                    onClick={() => {
                    setLogoutModalOpen(true);
                      setMenuOpen(false);
                    }}
                  className="flex items-center justify-between w-full px-6 py-4 text-red-600 hover:bg-red-50 rounded-xl transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-opacity-50 cursor-pointer"
                >
                  <div className="flex items-center">
                    <LogOut size={24} className="mr-4" />
                    <span className="text-lg">Log out</span>
              </div>
                  <ChevronRight size={20} />
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Account Settings Modal */}
      <AccountSettingsModal
        isOpen={accountModalOpen}
        onClose={() => setAccountModalOpen(false)}
      />

      {/* About Modal */}
      <AboutModal
        isOpen={aboutModalOpen}
        onClose={() => setAboutModalOpen(false)}
      />

      {/* Logout Confirmation Modal */}
      <LogoutConfirmationModal
        isOpen={logoutModalOpen}
        onClose={() => setLogoutModalOpen(false)}
        onConfirm={handleLogoutConfirm}
        isLoading={isLoggingOut}
      />
    </header>
  );
};

export default Navbar;