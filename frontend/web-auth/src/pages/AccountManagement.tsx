import { useState, useEffect } from "react";
import { PlusCircle, Users } from "lucide-react";
import { Navigate } from "react-router-dom";
import Footer from "../components/Footer";
import UserTable from "../components/UserTable";
import UserForm from "../components/UserForm";
import DeleteConfirmation from "../components/DeleteConfirmation";
import { User } from "../api/services/authService";
import { useUserContext } from "../contexts/UserContext";

export default function AccountManagement() {
  const { 
    users, 
    loading, 
    error, 
    fetchUsers, 
    addUser, 
    updateUserById, 
    deleteUserById,
    currentUser
  } = useUserContext();
  
  // State for modals
  const [isFormModalOpen, setIsFormModalOpen] = useState<boolean>(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState<boolean>(false);
  const [formMode, setFormMode] = useState<'create' | 'edit'>('create');
  const [currentEditUser, setCurrentEditUser] = useState<User | null>(null);
  const [actionLoading, setActionLoading] = useState<boolean>(false);
  const [authChecked, setAuthChecked] = useState<boolean>(false);

  // Check if user has admin or super_admin role
  const hasAdminAccess = currentUser?.role === 'admin' || currentUser?.role === 'super_admin';

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
  const handleFormSubmit = async (formData: Omit<User, '_id'>) => {
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
      console.error('Error submitting form:', err);
    } finally {
      setActionLoading(false);
    }
  };

  // Handle user deletion
  const handleDeleteConfirm = async () => {
    if (!currentEditUser?._id) return;
    
    setActionLoading(true);
    try {
      await deleteUserById(currentEditUser._id);
      setIsDeleteModalOpen(false);
      await fetchUsers(); // Refresh user list
    } catch (err) {
      console.error('Error deleting user:', err);
    } finally {
      setActionLoading(false);
    }
  };

  // Only redirect after we've confirmed the auth status
  if (authChecked && !hasAdminAccess) {
    return <Navigate to="/unauthorized" replace />;
  }

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
      <main className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#1E441E] mb-2 flex items-center gap-3">
            <Users className="w-8 h-8 sm:w-10 sm:h-10 text-[#456C2D]" />
            Account Management
          </h1>
          <p className="text-[#456C2D] text-sm sm:text-base">
            Manage farmer accounts and user permissions
          </p>
          <div className="mt-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full text-xs sm:text-sm font-medium bg-[#456C2D] text-[#F5F5DC]">
              {currentUser?.role === 'super_admin' ? 'Super Admin Access' : 'Admin Access'}
            </span>
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
            <div className="flex items-center justify-between">
              <span className="font-medium">Error: {error}</span>
              <button
                onClick={() => fetchUsers()}
                className="px-3 py-1 bg-red-600 text-white text-sm rounded-md hover:bg-red-700 transition-colors"
              >
                Retry
              </button>
            </div>
          </div>
        )}

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
            className="flex items-center gap-2 px-6 py-3 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium shadow-md hover:shadow-lg"
          >
            <PlusCircle className="w-5 h-5" />
            <span>Create New Account</span>
          </button>
        </div>
      </main>

      <Footer />

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
      {isDeleteModalOpen && (
        <DeleteConfirmation
          user={currentEditUser}
          onConfirm={handleDeleteConfirm}
          onCancel={() => setIsDeleteModalOpen(false)}
          isLoading={actionLoading}
        />
      )}
    </div>
  );
}