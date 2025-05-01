import { useState, useEffect } from "react";
import { PlusCircle } from "lucide-react";
import { Navigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import UserTable from "../components/UserTable";
import UserForm from "../components/UserForm";
import DeleteConfirmation from "../components/DeleteConfirmation";
import { User } from "../api/client";
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
    currentUser,
    isAdmin
  } = useUserContext();
  
  // State for modals
  const [isFormModalOpen, setIsFormModalOpen] = useState<boolean>(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState<boolean>(false);
  const [formMode, setFormMode] = useState<'create' | 'edit'>('create');
  const [currentEditUser, setCurrentEditUser] = useState<User | null>(null);
  const [actionLoading, setActionLoading] = useState<boolean>(false);

  // Check if user is admin, redirect if not
  if (!isAdmin) {
    return <Navigate to="/unauthorized" replace />;
  }

  // Fetch users on component mount
  useEffect(() => {
    fetchUsers();
  }, []);

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

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <Navbar />

      <main className="flex-grow container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-semibold">Account Management</h1>
          <div className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">
            Admin Access
          </div>
        </div>

        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            {error}
          </div>
        )}

        <UserTable 
          users={users} 
          loading={loading} 
          onEdit={handleOpenEditModal} 
          onDelete={handleOpenDeleteModal} 
        />

        <div 
          className="mt-6 flex items-center text-green-700 cursor-pointer hover:underline"
          onClick={handleOpenCreateModal}
        >
          <PlusCircle className="w-5 h-5 mr-2" />
          <span>Create new account</span>
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

