import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../api/services/authService';

/**
 * Hook to check if the current user has admin privileges
 * @param redirectOnFailure If true, redirects to /unauthorized when user is not admin
 * @returns Object containing isAdmin status and loading state
 */
export const useAdmin = (redirectOnFailure = true) => {
  const [isAdmin, setIsAdmin] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(true);
  const navigate = useNavigate();

  useEffect(() => {
    const checkAdminStatus = () => {
      // First check if user is authenticated
      if (!authService.isAuthenticated()) {
        setLoading(false);
        if (redirectOnFailure) {
          navigate('/login');
        }
        return;
      }

      // Check if user is regional_admin, admin or super_admin
      const user = authService.getCurrentUser();
      const hasAdminRole = user?.role === 'regional_admin' || user?.role === 'admin' || user?.role === 'super_admin';
      
      setIsAdmin(hasAdminRole);
      setLoading(false);

      // Redirect if not admin and redirectOnFailure is true
      if (!hasAdminRole && redirectOnFailure) {
        navigate('/unauthorized');
      }
    };

    checkAdminStatus();
  }, [navigate, redirectOnFailure]);

  return { isAdmin, loading };
};
// Add to your existing auth utilities
export const hasRole = (userRole: string, requiredRole: string): boolean => {
  const roleHierarchy: Record<string, number> = {
    'user': 1,
    'farmer': 1,
    'regional_admin': 2,
    'admin': 3,
    'super_admin': 4
  };
  
  const userLevel = roleHierarchy[userRole] || 0;
  const requiredLevel = roleHierarchy[requiredRole] || 0;
  
  return userLevel >= requiredLevel;
};

export const isSuperAdmin = (userRole: string): boolean => {
  return userRole === 'super_admin';
};

export default useAdmin;