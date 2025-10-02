import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Thermometer, 
  RefreshCw
} from 'lucide-react';
import authService from '../api/services/authService';
import { userService } from '../api/client';
import TwentyFourHourOverview from '../components/widgets/TwentyFourHourOverview';
import LiveDataWidget from '../components/widgets/LiveDataWidget';
import RecentActivityWidget from '../components/widgets/RecentActivityWidget'; // Import the new widget
import { farmService } from "../api/services/farmService";

const AdminDashboard = () => {
  const [loading, setLoading] = useState(true);
  const [currentTime, setCurrentTime] = useState(new Date());
  const [currentAdmin, setCurrentAdmin] = useState<any>(null);
const [totalUsers, setTotalUsers] = useState<number | null>(null);
  const [totalFarms, setTotalFarms] = useState<number | null>(null);

  useEffect(() => {
    const fetchCurrentUser = async () => {
      try {
        let user = authService.getCurrentUser();
        
        if (!user) {
          // If no user data in localStorage, try to refresh from API
          user = await authService.refreshUserData();
        }
        
        setCurrentAdmin(user);
      } catch (error) {
        console.error('Error fetching current user:', error);
        // Fallback to basic user info from token
        const user = authService.getCurrentUser();
        setCurrentAdmin(user);
      }
    };

    fetchCurrentUser();
  }, []);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const count = await userService.getTotalUsers();
        setTotalUsers(count);
      } catch (err) {
        console.error("❌ Error fetching users:", err);
      }
    };
    fetchUsers();
  }, []);

  useEffect(() => {
    const fetchFarms = async () => {
      try {
        const count = await farmService.getTotalFarms();
        setTotalFarms(count);
      } catch (err) {
        console.error("❌ Error fetching farms:", err);
      }
    };
    fetchFarms();
  }, []);

  useEffect(() => {
    // Load dashboard data
    const loadDashboard = async () => {
      setLoading(true);
      
      // Simulate loading dashboard data
      setTimeout(() => {
        setLoading(false);
      }, 1000);
    };

    loadDashboard();
  }, []);

  useEffect(() => {
    // Update current time every second
    const interval = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  // Get admin display name
  const getAdminDisplayName = () => {
    if (!currentAdmin) return 'Administrator';
    return currentAdmin.fullName || currentAdmin.name || currentAdmin.username || 'Administrator';
  };

  if (loading) {
    return (
      <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C]"></div>
            <span className="ml-3" style={{ fontSize: 'var(--text-lg)' }}>Loading dashboard...</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div 
      className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8" 
      style={{ 
        '--text-xs': '12px', 
        '--text-sm': '14px', 
        '--text-base': '16px', 
        '--text-lg': '18px', 
        '--text-xl': '20px' 
      } as React.CSSProperties}
    >
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="font-bold text-[#1E441E] mb-2" style={{ fontSize: 'var(--text-xl)' }}>
            Welcome, Admin {getAdminDisplayName()}
          </h1>
          <p className="text-[#456C2D]" style={{ fontSize: 'var(--text-base)' }}>
            System overview and monitoring dashboard - {currentTime.toLocaleString()}
          </p>
          <div className="mt-3 flex items-center gap-3">
            <span 
              className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#456C2D] text-[#F5F5DC]" 
              style={{ fontSize: 'var(--text-sm)' }}
            >
              Admin Dashboard
            </span>
            <div className="flex items-center gap-2 text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>
              <RefreshCw className="w-4 h-4" />
              <span>Real-time monitoring</span>
            </div>
          </div>
        </div>

        {/* Stats Overview - Now using real user data */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-6 mb-8">
          {[
            { 
              label: "Total Users", 
              value: totalUsers !== null ? totalUsers : "Loading...",
              icon: <Users className="w-6 h-6 text-blue-600" />, 
              bg: "bg-blue-50" 
            },
            { 
              label: "Total Prototypes", 
              value: totalFarms !== null ? totalFarms : "Loading...", 
              icon: <Thermometer className="w-6 h-6 text-purple-600" />, 
              bg: "bg-purple-50" 
            }
          ].map((stat, i) => (
            <div key={i} className="bg-white rounded-xl shadow-lg p-6">
              <div className="flex items-center justify-between mb-4">
                <p style={{ fontSize: 'var(--text-lg)' }} className="text-[#4A7C59] font-medium">{stat.label}</p>
                <div className={`pl-3 ${stat.bg} rounded-lg`}>
                  {stat.icon}
                </div>
              </div>
              <div className="font-bold text-[#356B2C] mb-1 ml-1 text-5xl">{stat.value}</div>
            </div>
          ))}
        </div>

        {/* Live Data Widget + 24-hour Overview */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
          {/* Live Data Widget (toggle metrics) - smaller column */}
          <div className="lg:col-span-1">
            <LiveDataWidget />
          </div>
          {/* 24-hour Overview Widget - take more space */}
          <div className="lg:col-span-2">
            <TwentyFourHourOverview />
          </div>
        </div>

        {/* Recent Activity Widget */}
        <div className="mb-8">
          <RecentActivityWidget maxItems={5} refreshInterval={15000} />
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;