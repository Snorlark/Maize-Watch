import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

interface ProtectedRouteProps {
  requireAdmin?: boolean;
  requireRegionalAdmin?: boolean;
  // Regional admin ONLY (plus super admin). Does NOT include admin.
  requireRegionalAdminOnly?: boolean;
  requireSuperAdmin?: boolean;
  redirectPath?: string;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  requireAdmin = false,
  requireRegionalAdmin = false,
  requireRegionalAdminOnly = false,
  requireSuperAdmin = false,
  redirectPath = '/admin-portal-xyz123/login'
}) => {
  const { user, isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to={redirectPath} replace />;
  }

  // Super Admin check
  if (requireSuperAdmin && user?.role !== 'super_admin') {
    return <Navigate to="/unauthorized" replace />;
  }

  // Regional Admin ONLY check (allows regional_admin and super_admin roles)
  if (
    requireRegionalAdminOnly &&
    user?.role !== 'regional_admin' &&
    user?.role !== 'super_admin'
  ) {
    return <Navigate to="/unauthorized" replace />;
  }

  // Regional Admin check (allows regional_admin, admin, and super_admin roles)
  if (requireRegionalAdmin && 
      user?.role !== 'regional_admin' && 
      user?.role !== 'admin' && 
      user?.role !== 'super_admin') {
    return <Navigate to="/unauthorized" replace />;
  }

  // Admin check (allows both admin and super_admin roles)
  if (requireAdmin && user?.role !== 'admin' && user?.role !== 'super_admin') {
    return <Navigate to="/unauthorized" replace />;
  }

  return <Outlet />;
};

export default ProtectedRoute;
