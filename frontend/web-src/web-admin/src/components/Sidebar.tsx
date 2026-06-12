import React, { useState, useEffect, useRef } from "react";
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { User } from '../api/services/authService';
import { 
  Menu, 
  X, 
  ChevronRight, 
  LayoutDashboard, 
  Activity, 
  Users, 
  Settings, 
  Info, 
  LogOut, 
  ScrollText, 
  ChevronDown,
  ChevronLeft
} from "lucide-react";
import AccountSettingsModal from './AccountSettingsModal';
import AboutModal from './AboutModal';
import LogoutConfirmationModal from './LogoutConfirmationModal';

// Create a global state object to persist sidebar states
const globalSidebarState = {
  mobile: false,
  desktopCollapsed: false
};

// Helper function to get sidebar state from memory
const getSidebarState = () => {
  return globalSidebarState.mobile;
};

// Helper function to save sidebar state to memory
const setSidebarState = (isOpen: boolean) => {
  globalSidebarState.mobile = isOpen;
};

// Helper function to get desktop collapsed state from memory
const getDesktopCollapsedState = () => {
  return globalSidebarState.desktopCollapsed;
};

// Helper function to save desktop collapsed state to memory
const setDesktopCollapsedState = (isCollapsed: boolean) => {
  globalSidebarState.desktopCollapsed = isCollapsed;
};

const Sidebar: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false); // Always start closed
  const [aboutModalOpen, setAboutModalOpen] = useState(false);
  const [accountModalOpen, setAccountModalOpen] = useState(false);
  const [logoutModalOpen, setLogoutModalOpen] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);
  const [isDesktopCollapsed, setIsDesktopCollapsed] = useState(false);
  const sidebarRef = useRef<HTMLDivElement>(null);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  // Initialize states from memory on component mount
  useEffect(() => {
    const savedSidebarState = getSidebarState();
    const savedDesktopState = getDesktopCollapsedState();
    
    setSidebarOpen(savedSidebarState);
    setIsDesktopCollapsed(savedDesktopState);
  }, []);

  // Add body margin based on sidebar state
  useEffect(() => {
    const body = document.body;
    const sidebarWidth = isDesktopCollapsed ? '4rem' : '16rem'; // 64px collapsed, 256px expanded
    
    // Only apply margin on desktop screens
    const mediaQuery = window.matchMedia('(min-width: 1024px)');
    
    const updateBodyMargin = () => {
      if (mediaQuery.matches) {
        body.style.marginLeft = sidebarWidth;
      } else {
        body.style.marginLeft = '0';
      }
    };
    
    updateBodyMargin();
    mediaQuery.addEventListener('change', updateBodyMargin);
    
    return () => {
      mediaQuery.removeEventListener('change', updateBodyMargin);
      body.style.marginLeft = '0';
    };
  }, [isDesktopCollapsed]);

  // Update sidebar open state handler
  const handleSetSidebarOpen = (isOpen: boolean) => {
    setSidebarOpen(isOpen);
    setSidebarState(isOpen);
  };

  // Update desktop collapsed state handler
  const handleSetDesktopCollapsed = (isCollapsed: boolean) => {
    setIsDesktopCollapsed(isCollapsed);
    setDesktopCollapsedState(isCollapsed);
  };

  // Handle click outside to close sidebar on mobile
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (sidebarRef.current && !sidebarRef.current.contains(event.target as Node)) {
        handleSetSidebarOpen(false);
        setUserDropdownOpen(false);
      }
    };

    if (sidebarOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      // Prevent body scroll when sidebar is open on mobile
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.body.style.overflow = 'unset';
    };
  }, [sidebarOpen]);

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
      // Clear sidebar states on logout
      globalSidebarState.mobile = false;
      globalSidebarState.desktopCollapsed = false;
      navigate('/login');
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      setIsLoggingOut(false);
      setLogoutModalOpen(false);
    }
  };

  const navItems = [
    { to: "/admin-portal-xyz123/dashboard", icon: LayoutDashboard, label: "Dashboard" },
    { to: "/admin-portal-xyz123/datahistory", icon: ScrollText, label: "Data History" },
    { to: "/admin-portal-xyz123/livedata", icon: Activity, label: "Live Data" },
    ...(user?.role === 'admin' || user?.role === 'super_admin' ? [
      { to: "/admin-portal-xyz123/accountmanagement", icon: Users, label: "Account Management" },
      { to: "/admin-portal-xyz123/activity-logs", icon: ScrollText, label: "Activity Log" }
    ] : [])
  ];

  return (
    <>
      {/* Mobile Header */}
      <div className="lg:hidden bg-[#E6F0D3] p-3 sticky top-0 z-50">
        <button 
          onClick={() => handleSetSidebarOpen(true)}
          className="p-2 hover:bg-[#F5F9E8] rounded-lg transition-colors"
          aria-label="Open sidebar"
        >
          <Menu size={20} className="text-[#1E441E]" />
        </button>
      </div>

      {/* Desktop Sidebar */}
      <div 
        className={`hidden lg:flex fixed left-0 top-0 h-full bg-[#E6F0D3] border-r border-[#D1E7BC] transition-all duration-300 z-40 ${
          isDesktopCollapsed ? 'w-16' : 'w-64'
        }`}
      >
        <div className="flex flex-col w-full">
          {/* Logo Section */}
          <div className="p-4 border-b border-[#D1E7BC]">
            <div className="flex items-center justify-between">
              {!isDesktopCollapsed && (
                <img
                  src="/web-admin/public/maizewatch.png"
                  alt="Maize Watch Logo"
                  className="h-10 w-auto max-w-full"
                />
              )}
              <button
                onClick={() => handleSetDesktopCollapsed(!isDesktopCollapsed)}
                className="p-1.5 hover:bg-[#F5F9E8] rounded-lg transition-colors"
              >
                {isDesktopCollapsed ? 
                  <ChevronRight size={16} className="text-[#1E441E]" /> : 
                  <ChevronLeft size={16} className="text-[#1E441E]" />
                }
              </button>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-3">
            <div className="space-y-1">
              {navItems.map((item) => (
                <NavLink
                  key={item.to}
                  to={item.to}
                  className={({ isActive }) =>
                    `flex items-center px-3 py-2.5 rounded-lg transition-all duration-200 group ${
                      isActive 
                        ? "bg-[#456C2D] text-white shadow-md" 
                        : "text-[#1E441E] hover:bg-[#F5F9E8]"
                    }`
                  }
                  title={isDesktopCollapsed ? item.label : undefined}
                >
                  <item.icon size={18} className="flex-shrink-0" />
                  {!isDesktopCollapsed && (
                    <span className="ml-3 text-xs font-medium">{item.label}</span>
                  )}
                </NavLink>
              ))}
            </div>
          </nav>

          {/* User Profile Section */}
          <div className="border-t border-[#D1E7BC] p-3">
            <div className="relative">
              <button
                onClick={() => setUserDropdownOpen(!userDropdownOpen)}
                className={`flex items-center w-full p-2.5 hover:bg-[#F5F9E8] rounded-lg transition-colors ${
                  isDesktopCollapsed ? 'justify-center' : ''
                }`}
                title={isDesktopCollapsed ? getUserDisplayName(user) : undefined}
              >
                <div className="w-8 h-8 bg-[#456C2D] rounded-full flex items-center justify-center flex-shrink-0">
                  <span className="text-white text-xs font-medium">
                    {getUserInitials(user)}
                  </span>
                </div>
                {!isDesktopCollapsed && (
                  <>
                    <div className="ml-2.5 flex-1 text-left">
                      <p className="text-xs font-medium text-[#1E441E] truncate">{getUserDisplayName(user)}</p>
                      <p className="text-[10px] text-[#456C2D] capitalize">{user?.role?.replace('_', ' ')}</p>
                    </div>
                    <ChevronDown className={`w-3 h-3 text-[#1E441E] transition-transform ${userDropdownOpen ? 'rotate-180' : ''}`} />
                  </>
                )}
              </button>

              {/* Desktop User Dropdown */}
              {userDropdownOpen && (
                <div className={`absolute ${isDesktopCollapsed ? 'left-full ml-2' : 'right-0'} bottom-full mb-2 w-56 bg-white rounded-lg shadow-2xl border border-gray-200 py-1 z-50`}>
                  <div className="px-3 py-2.5 border-b border-gray-100">
                    <p className="font-medium text-sm text-gray-900">{getUserDisplayName(user)}</p>
                    <p className="text-xs text-gray-500 capitalize">{user?.role?.replace('_', ' ')}</p>
                  </div>
                  
                  <button
                    onClick={() => {
                      setAccountModalOpen(true);
                      setUserDropdownOpen(false);
                    }}
                    className="flex items-center w-full px-3 py-2.5 text-xs text-gray-700 hover:bg-[#8B4513] hover:text-[#F5F5DC] transition-colors"
                  >
                    <Settings className="w-3.5 h-3.5 mr-2.5" />
                    Account Settings
                  </button>
                  
                  <button
                    onClick={() => {
                      setAboutModalOpen(true);
                      setUserDropdownOpen(false);
                    }}
                    className="flex items-center w-full px-3 py-2.5 text-xs text-gray-700 hover:bg-[#8B4513] hover:text-[#F5F5DC] transition-colors"
                  >
                    <Info className="w-3.5 h-3.5 mr-2.5" />
                    About
                  </button>
                  
                  <div className="border-t border-gray-100 my-1"></div>
                  
                  <button
                    onClick={() => {
                      setLogoutModalOpen(true);
                      setUserDropdownOpen(false);
                    }}
                    className="flex items-center w-full px-3 py-2.5 text-xs text-red-600 hover:bg-red-50 transition-colors"
                  >
                    <LogOut className="w-3.5 h-3.5 mr-2.5" />
                    Logout
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Mobile Sidebar Overlay */}
      <div className={`lg:hidden fixed inset-0 bg-black transition-all duration-300 z-50 ${
        sidebarOpen ? 'bg-opacity-50 visible' : 'bg-opacity-0 invisible'
      }`}>
        <div 
          ref={sidebarRef}
          className={`fixed left-0 top-0 h-full w-72 bg-[#E6F0D3] transition-all duration-300 ease-in-out ${
            sidebarOpen ? 'transform translate-x-0' : 'transform -translate-x-full'
          }`}
        >
            <div className="flex flex-col h-full">
              {/* Mobile Header */}
              <div className="flex items-center justify-between p-4 border-b border-[#D1E7BC]">
                <img
                  src="/web-admin/public/maizewatch.png"
                  alt="Maize Watch Logo"
                  className="h-10 w-auto max-w-[180px]"
                />
                <button 
                  onClick={() => handleSetSidebarOpen(false)}
                  className="p-2 hover:bg-[#F5F9E8] rounded-lg transition-colors"
                >
                  <X size={20} className="text-[#1E441E]" />
                </button>
              </div>

              {/* User Profile */}
              <div className="p-4 border-b border-[#D1E7BC]">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-[#456C2D] rounded-full flex items-center justify-center">
                    <span className="text-white text-sm font-medium">
                      {getUserInitials(user)}
                    </span>
                  </div>
                  <div>
                    <p className="font-medium text-sm text-[#1E441E]">{getUserDisplayName(user)}</p>
                    <p className="text-xs text-[#456C2D] capitalize">{user?.role?.replace('_', ' ')}</p>
                  </div>
                </div>
              </div>

              {/* Mobile Navigation */}
              <nav className="flex-1 p-3">
                <div className="space-y-1">
                  {navItems.map((item) => (
                    <NavLink
                      key={item.to}
                      to={item.to}
                      onClick={() => handleSetSidebarOpen(false)}
                      className={({ isActive }) =>
                        `flex items-center px-3 py-2.5 rounded-lg transition-all duration-200 ${
                          isActive 
                            ? "bg-[#456C2D] text-white shadow-md" 
                            : "text-[#1E441E] hover:bg-[#F5F9E8]"
                        }`
                      }
                    >
                      <item.icon size={18} className="mr-3" />
                      <span className="font-medium text-sm">{item.label}</span>
                    </NavLink>
                  ))}
                </div>
              </nav>

              {/* Mobile Actions */}
              <div className="p-3 border-t border-[#D1E7BC] bg-[#F5F9E8]">
                <div className="space-y-1">
                  <button 
                    className="flex items-center justify-between w-full px-3 py-2.5 text-[#1E441E] hover:bg-[#8B4513] hover:text-[#F5F5DC] rounded-lg transition-colors"
                    onClick={() => {
                      setAccountModalOpen(true);
                      handleSetSidebarOpen(false);
                    }}
                  >
                    <div className="flex items-center">
                      <Settings size={16} className="mr-2.5" />
                      <span className="text-sm">Account Settings</span>
                    </div>
                    <ChevronRight size={14} />
                  </button>

                  <button 
                    className="flex items-center justify-between w-full px-3 py-2.5 text-[#1E441E] hover:bg-[#8B4513] hover:text-[#F5F5DC] rounded-lg transition-colors"
                    onClick={() => {
                      setAboutModalOpen(true);
                      handleSetSidebarOpen(false);
                    }}
                  >
                    <div className="flex items-center">
                      <Info size={16} className="mr-2.5" />
                      <span className="text-sm">About</span>
                    </div>
                    <ChevronRight size={14} />
                  </button>

                  <button
                    onClick={() => {
                      setLogoutModalOpen(true);
                      handleSetSidebarOpen(false);
                    }}
                    className="flex items-center justify-between w-full px-3 py-2.5 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                  >
                    <div className="flex items-center">
                      <LogOut size={16} className="mr-2.5" />
                      <span className="text-sm">Logout</span>
                    </div>
                    <ChevronRight size={14} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

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
    </>
  );
};

export default Sidebar;