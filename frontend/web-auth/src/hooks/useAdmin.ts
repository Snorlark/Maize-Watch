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

      // Check if user is admin
      const user = authService.getCurrentUser();
      const hasAdminRole = user?.role === 'admin';
      
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

export default useAdmin;