import { useState, useEffect } from "react";
import { PlusCircle, Users } from "lucide-react";
import { Navigate } from "react-router-dom";
import Footer from "../components/Footer";
import UserTable from "../components/UserTable";
import UserForm from "../components/UserForm";
import DeleteConfirmation from "../components/DeleteConfirmation";
import ErrorModal from "../components/ErrorModal";
import { User } from "../api/services/authService";
import { useUserContext } from "../contexts/UserContext";

interface UserFormData extends Omit<User, '_id'> {
  password?: string;
}

export default function AccountManagement() {
  const { 
    users, 
    loading, 
    error, 
    errorType,
    fetchUsers, 
    addUser, 
    updateUserById, 
    deleteUserById,
    currentUser,
    clearError
  } = useUserContext();
  
  // State for modals
  const [isFormModalOpen, setIsFormModalOpen] = useState<boolean>(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState<boolean>(false);
  const [formMode, setFormMode] = useState<'create' | 'edit'>('create');
  const [currentEditUser, setCurrentEditUser] = useState<User | null>(null);
  const [actionLoading, setActionLoading] = useState<boolean>(false);
  const [authChecked, setAuthChecked] = useState<boolean>(false);

  // Check if user has regional_admin, admin or super_admin role
  const hasAdminAccess = currentUser?.role === 'regional_admin' || currentUser?.role === 'admin' || currentUser?.role === 'super_admin';

  // Fetch users on component mount and check authentication
  useEffect(() => {
    // First set authChecked to true to indicate we've performed the check
    setAuthChecked(true);
    
    // Only fetch users if the user has admin access
    if (hasAdminAccess) {
      fetchUsers();
    }
  }, [hasAdminAccess, fetchUsers]); // Add hasAdminAccess as a dependency to re-run if it changes

  // Open create user modal
  const handleOpenCreateModal = () => {
    setCurrentEditUser(null);
    setFormMode('create');
    setIsFormModalOpen(true);
  };

  // Open edit user modal
  const handleOpenEditModal = (user: User) => {
    setCurrentEditUser(user);
    setFormMode('edit');
    setIsFormModalOpen(true);
  };

  // Open delete confirmation modal
  const handleOpenDeleteModal = (user: User) => {
    setCurrentEditUser(user);
    setIsDeleteModalOpen(true);
  };

  // Handle user form submission (create or edit)
  const handleFormSubmit = async (formData: UserFormData) => {
    setActionLoading(true);
    try {
      if (formMode === 'create') {
        await addUser(formData);
      } else if (currentEditUser?._id) {
        await updateUserById(currentEditUser._id, formData);
      }
      setIsFormModalOpen(false);
      await fetchUsers(); // Refresh user list
    } catch (err) {
      console.error('Error in form submission:', err);
    } finally {
      setActionLoading(false);
    }
  };

  // Handle user deletion
  const handleDeleteConfirm = async () => {
    if (!currentEditUser?._id) return;

    console.log(' Attempting to delete user:', {
      userId: currentEditUser._id,
      username: currentEditUser.username,
      currentUserRole: currentUser?.role,
      hasAdminAccess
    });
    
    setActionLoading(true);
    try {
      await deleteUserById(currentEditUser._id);
      console.log('✅ User deleted successfully');
      setIsDeleteModalOpen(false);
      await fetchUsers(); // Refresh user list
    } catch (err: any) {
      console.error(' Error deleting user:', err);
      console.error('Error details:', {
        message: err.message,
        status: err.response?.status,
        data: err.response?.data,
        code: err.code
      });
      
      // Provide specific error messages based on error type
      let errorMessage = 'Failed to delete user';
      if (err.code === 'ECONNABORTED') {
        errorMessage = 'Request timed out - Backend server is slow or unresponsive. Please try again or contact admin.';
      } else if (err.response?.status === 404) {
        errorMessage = 'User not found or already deleted.';
      } else if (err.response?.status === 403) {
        errorMessage = 'Insufficient permissions to delete this user.';
      } else if (err.response?.data?.message) {
        errorMessage = err.response.data.message;
      } else {
        errorMessage = `${errorMessage}: ${err.message}`;
      }
      
      alert(errorMessage);
    } finally {
      setActionLoading(false);
    }
  };
  const handleErrorRetry = () => {
    if (hasAdminAccess) {
      fetchUsers();
    }
  };

  // Only redirect after we've confirmed the auth status
  if (authChecked && !hasAdminAccess) {
    return <Navigate to="/unauthorized" replace />;
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
      <main className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="font-bold text-[#1E441E] mb-2 flex items-center gap-3" style={{ fontSize: 'var(--text-xl)' }}>
            <Users className="w-8 h-8 sm:w-10 sm:h-10 text-[#456C2D]" />
            Account Management
          </h1>
          <p className="text-[#456C2D]" style={{ fontSize: 'var(--text-base)' }}>
            Manage farmer accounts and user permissions
          </p>
          <div className="mt-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#456C2D] text-[#F5F5DC]" style={{ fontSize: 'var(--text-sm)' }}>
            {currentUser?.role === 'super_admin' ? 'Super Admin Access' : 
             currentUser?.role === 'regional_admin' ? 'Regional Admin Access' : 'Admin Access'}
            </span>
          </div>
        </div>

        {/* User Table */}
        <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
        <UserTable 
          users={users} 
          loading={loading} 
          onEdit={handleOpenEditModal} 
          onDelete={handleOpenDeleteModal} 
        />
        </div>

        {/* Create New Account Button */}
        <div className="flex justify-center">
          <button
            onClick={handleOpenCreateModal}
            className="flex items-center gap-2 px-6 py-3 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium"
            style={{ fontSize: 'var(--text-base)' }}
          >
            <PlusCircle className="w-5 h-5" />
            Create New Account
          </button>
        </div>

        {/* User Form Modal */}
        {isFormModalOpen && (
          <UserForm
            mode={formMode}
            initialData={currentEditUser}
            onSubmit={handleFormSubmit}
            onCancel={() => setIsFormModalOpen(false)}
            isLoading={actionLoading}
          />
        )}

        {/* Delete Confirmation Modal */}
        {isDeleteModalOpen && currentEditUser && (
          <DeleteConfirmation
            user={currentEditUser}
            onConfirm={handleDeleteConfirm}
            onCancel={() => setIsDeleteModalOpen(false)}
            isLoading={actionLoading}
          />
        )}

        {/* Error Modal */}
        {error && (
          <ErrorModal
            isOpen={!!error}
            onClose={clearError}
            onRetry={handleErrorRetry}
            error={{
              type: errorType || 'general',
              message: error,
              details: errorType === 'network' ? 'Check your internet connection' : undefined
            }}
          />
        )}

        <Footer />
      </main>
    </div>
  );
}