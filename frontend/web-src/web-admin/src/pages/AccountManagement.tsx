import { useState, useEffect } from "react";
import { PlusCircle, Users, Sprout, MapPin, Calendar, Search, RefreshCw, Eye, UserCheck, Loader2, ArrowUpDown, ChevronUp, ChevronDown } from "lucide-react";
import { Navigate } from "react-router-dom";
import Footer from "../components/Footer";
import UserTable from "../components/UserTable";
import UserForm from "../components/UserForm";
import DeleteConfirmation from "../components/DeleteConfirmation";
import ErrorModal from "../components/ErrorModal";
import FarmReassignmentModal from "../components/FarmReassignmentModal";
import FarmDetailsModal from "../components/FarmDetailsModal";
import { User } from "../api/services/authService";
import { CurrentFarm, farmService } from "../api/services/farmService";
import { useUserContext } from "../contexts/UserContext";

interface UserFormData extends Omit<User, '_id'> {
  password?: string;
}

type SortDirection = 'asc' | 'desc' | null;
type SortField = 'farmName' | 'location' | 'assignedUser' | 'fieldsCount' | 'updatedAt' | null;
type ActiveTab = 'users' | 'farms';

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
  
  // State for tab management
  const [activeTab, setActiveTab] = useState<ActiveTab>('users');
  
  // State for user modals
  const [isFormModalOpen, setIsFormModalOpen] = useState<boolean>(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState<boolean>(false);
  const [formMode, setFormMode] = useState<'create' | 'edit'>('create');
  const [currentEditUser, setCurrentEditUser] = useState<User | null>(null);
  const [actionLoading, setActionLoading] = useState<boolean>(false);
  const [authChecked, setAuthChecked] = useState<boolean>(false);

  // State for farm management
  const [farms, setFarms] = useState<CurrentFarm[]>([]);
  const [farmLoading, setFarmLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedFarm, setSelectedFarm] = useState<CurrentFarm | null>(null);
  const [showReassignModal, setShowReassignModal] = useState(false);
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [farmActionLoading, setFarmActionLoading] = useState(false);
  const [sortField, setSortField] = useState<SortField>(null);
  const [sortDirection, setSortDirection] = useState<SortDirection>(null);

  // Check if user has regional_admin, admin or super_admin role
  const hasAdminAccess = currentUser?.role === 'regional_admin' || currentUser?.role === 'admin' || currentUser?.role === 'super_admin';

  // Create a map of users for quick lookup
  const userMap = new Map(users.map(user => [user._id || '', user]));

  // Get user display name
  const getUserDisplayName = (userId: string): string => {
    const user = userMap.get(userId);
    return user ? user.fullName || user.username : 'Unknown User';
  };

  // Fetch farms
  const fetchFarms = async () => {
    setFarmLoading(true);
    try {
      const farmData = await farmService.getAllFarmsWithUsers();
      setFarms(farmData);
    } catch (error) {
      console.error('Error fetching farms:', error);
    } finally {
      setFarmLoading(false);
    }
  };

  // Fetch users on component mount and check authentication
  useEffect(() => {
    // First set authChecked to true to indicate we've performed the check
    setAuthChecked(true);
    
    // Only fetch users if the user has admin access
    if (hasAdminAccess) {
      fetchUsers();
      // Regional admin and above can access Farm Assignment
      fetchFarms();
    }
  }, [hasAdminAccess]); // Removed fetchUsers from dependencies to prevent infinite loop

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

  // Farm Management Functions
  // Filter farms based on search term
  const filteredFarms = farms.filter(farm => 
    (farm.farmName || farm.fieldName || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (farm.location || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (getUserDisplayName(farm.userId) || '').toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Sort farms
  const sortedFarms = [...filteredFarms].sort((a, b) => {
    if (sortField === null || sortDirection === null) return 0;
    
    let valueA: string | number;
    let valueB: string | number;
    
    switch (sortField) {
      case 'farmName':
        valueA = (a.farmName || a.fieldName || '').toLowerCase();
        valueB = (b.farmName || b.fieldName || '').toLowerCase();
        break;
      case 'location':
        valueA = (a.location || '').toLowerCase();
        valueB = (b.location || '').toLowerCase();
        break;
      case 'assignedUser':
        valueA = (getUserDisplayName(a.userId) || '').toLowerCase();
        valueB = (getUserDisplayName(b.userId) || '').toLowerCase();
        break;
      case 'fieldsCount':
        valueA = (a.fields || []).length;
        valueB = (b.fields || []).length;
        break;
      case 'updatedAt':
        valueA = new Date(a.updatedAt || 0).getTime();
        valueB = new Date(b.updatedAt || 0).getTime();
        break;
      default:
        return 0;
    }
    
    if (typeof valueA === 'string' && typeof valueB === 'string') {
      return sortDirection === 'asc' ? valueA.localeCompare(valueB) : valueB.localeCompare(valueA);
    } else {
      return sortDirection === 'asc' ? (valueA as number) - (valueB as number) : (valueB as number) - (valueA as number);
    }
  });

  // Handle column sort
  const handleSort = (field: SortField) => {
    if (sortField === field) {
      if (sortDirection === 'asc') {
        setSortDirection('desc');
      } else if (sortDirection === 'desc') {
        setSortField(null);
        setSortDirection(null);
      }
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  // Get sort icon for a column
  const getSortIcon = (field: SortField) => {
    if (sortField !== field) {
      return <ArrowUpDown className="w-4 h-4 ml-1" />;
    }
    if (sortDirection === 'asc') {
      return <ChevronUp className="w-4 h-4 ml-1" />;
    }
    if (sortDirection === 'desc') {
      return <ChevronDown className="w-4 h-4 ml-1" />;
    }
    return <ArrowUpDown className="w-4 h-4 ml-1" />;
  };

  // Handle farm reassignment
  const handleReassign = (farm: CurrentFarm) => {
    setSelectedFarm(farm);
    setShowReassignModal(true);
  };

  // Handle view details
  const handleViewDetails = (farm: CurrentFarm) => {
    setSelectedFarm(farm);
    setShowDetailsModal(true);
  };

  // Handle reassignment confirmation
  const handleReassignConfirm = async (newUserId: string) => {
    if (!selectedFarm) return;

    setFarmActionLoading(true);
    try {
      await farmService.reassignFarm(selectedFarm._id, newUserId);
      await fetchFarms(); // Refresh the farms list
      setShowReassignModal(false);
      setSelectedFarm(null);
    } catch (error) {
      console.error('Error reassigning farm:', error);
      alert('Failed to reassign farm. Please try again.');
    } finally {
      setFarmActionLoading(false);
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
            Manage farmer accounts, user permissions, and farm assignments
          </p>
          <div className="mt-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#456C2D] text-[#F5F5DC]" style={{ fontSize: 'var(--text-sm)' }}>
            {currentUser?.role === 'super_admin' ? 'Super Admin Access' : 
             currentUser?.role === 'regional_admin' ? 'Regional Admin Access' : 'Admin Access'}
            </span>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="mb-6">
          <div className="flex space-x-1 bg-white rounded-lg p-1 shadow-sm">
            <button
              onClick={() => setActiveTab('users')}
              className={`flex items-center gap-2 px-4 py-2 rounded-md font-medium transition-colors cursor-pointer ${
                activeTab === 'users'
                  ? 'bg-[#456C2D] text-white shadow-sm'
                  : 'text-[#456C2D] hover:bg-[#F0F8E8]'
              }`}
              style={{ fontSize: 'var(--text-sm)' }}
            >
              <Users className="w-4 h-4" />
              User Management
            </button>
            {/* Regional admin and above can access Farm Assignment */}
            {hasAdminAccess && (
              <button
                onClick={() => setActiveTab('farms')}
                className={`flex items-center gap-2 px-4 py-2 rounded-md font-medium transition-colors cursor-pointer ${
                  activeTab === 'farms'
                    ? 'bg-[#456C2D] text-white shadow-sm'
                    : 'text-[#456C2D] hover:bg-[#F0F8E8]'
                }`}
                style={{ fontSize: 'var(--text-sm)' }}
              >
                <Sprout className="w-4 h-4" />
                Farm Assignments
              </button>
            )}
          </div>
        </div>

        {/* Tab Content */}
        {activeTab === 'users' ? (
          <>
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
                className="flex items-center gap-2 px-6 py-3 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium cursor-pointer"
                style={{ fontSize: 'var(--text-base)' }}
              >
                <PlusCircle className="w-5 h-5" />
                Create New Account
              </button>
            </div>
          </>
        ) : (
          <>
            {/* Farm Assignment Controls */}
            <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
              <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
                {/* Search */}
                <div className="flex-1 max-w-md">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-[#456C2D] w-4 h-4" />
                    <input
                      type="text"
                      placeholder="Search farms, locations, or users..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="w-full pl-10 pr-4 py-2 border border-[#B8D4A8] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#8B4513] focus:border-transparent"
                    />
                  </div>
                </div>

                {/* Refresh Button */}
                <button
                  onClick={fetchFarms}
                  disabled={farmLoading}
                  className="flex items-center gap-2 px-4 py-2 bg-[#456C2D] text-white rounded-lg hover:bg-[#5A7A3A] transition-colors disabled:opacity-50 cursor-pointer disabled:cursor-not-allowed"
                >
                  <RefreshCw className={`w-4 h-4 ${farmLoading ? 'animate-spin' : ''}`} />
                  Refresh
                </button>
              </div>

              {/* Stats */}
              <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="bg-[#F5F9E8] p-4 rounded-lg">
                  <div className="text-2xl font-bold text-[#1E441E]">{farms.length}</div>
                  <div className="text-sm text-[#456C2D]">Total Farms</div>
                </div>
                <div className="bg-[#F5F9E8] p-4 rounded-lg">
                  <div className="text-2xl font-bold text-[#1E441E]">
                    {farms.reduce((acc, farm) => acc + (farm.fields || []).length, 0)}
                  </div>
                  <div className="text-sm text-[#456C2D]">Total Fields</div>
                </div>
              </div>
            </div>

            {/* Farm Table */}
            <div className="bg-white rounded-xl shadow-lg overflow-hidden">
              <div className="p-6 border-b border-[#E6F0D3]">
                <h2 className="text-lg font-semibold text-[#1E441E]">Farm Assignments</h2>
                <p className="text-sm text-[#456C2D] mt-1">
                  Showing {sortedFarms.length} of {farms.length} farms
                </p>
              </div>

              <div className="overflow-x-auto">
                <table className="min-w-full bg-white rounded-xl shadow-md overflow-hidden">
                  <thead className="bg-[#456C2D] text-[#F5F5DC]">
                    <tr>
                      <th 
                        className="px-6 py-3 text-left cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                        onClick={() => handleSort('farmName')}
                      >
                        <div className="flex items-center">
                          Farm Name
                          {getSortIcon('farmName')}
                        </div>
                      </th>
                      <th 
                        className="px-6 py-3 text-left cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                        onClick={() => handleSort('location')}
                      >
                        <div className="flex items-center">
                          Location
                          {getSortIcon('location')}
                        </div>
                      </th>
                      <th 
                        className="px-6 py-3 text-left cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                        onClick={() => handleSort('assignedUser')}
                      >
                        <div className="flex items-center">
                          Assigned User
                          {getSortIcon('assignedUser')}
                        </div>
                      </th>
                      <th 
                        className="px-6 py-3 text-left cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                        onClick={() => handleSort('fieldsCount')}
                      >
                        <div className="flex items-center">
                          Fields
                          {getSortIcon('fieldsCount')}
                        </div>
                      </th>
                      <th 
                        className="px-6 py-3 text-left cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                        onClick={() => handleSort('updatedAt')}
                      >
                        <div className="flex items-center">
                          Last Updated
                          {getSortIcon('updatedAt')}
                        </div>
                      </th>
                      <th className="px-6 py-3 text-left">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {farmLoading ? (
                      <tr>
                        <td colSpan={6} className="px-6 py-12 text-center">
                          <Loader2 className="w-8 h-8 mx-auto animate-spin text-[#456C2D] mb-2" />
                          <p className="text-[#456C2D]">Loading farms...</p>
                        </td>
                      </tr>
                    ) : sortedFarms.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="px-6 py-12 text-center">
                          <Sprout className="w-16 h-16 text-[#B8D4A8] mx-auto mb-4" />
                          <p className="text-[#456C2D] text-lg">No farms found</p>
                          <p className="text-[#7A8471] mt-2">
                            {searchTerm ? 'Try adjusting your search criteria' : 'No farms have been created yet'}
                          </p>
                        </td>
                      </tr>
                    ) : (
                      sortedFarms.map((farm) => (
                        <tr key={farm._id} className="border-b border-[#E6F0D3] hover:bg-[#F5F9E8] transition-colors">
                          <td className="px-6 py-4">
                            <div className="font-medium text-[#1E441E]">{farm.farmName || farm.fieldName || 'Unnamed Farm'}</div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-2 text-[#456C2D]">
                              <MapPin className="w-4 h-4" />
                              <span className="truncate max-w-xs">{farm.location || 'Location not specified'}</span>
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-2">
                              <Users className="w-4 h-4 text-[#456C2D]" />
                              <span className="text-[#1E441E] font-medium">
                                {getUserDisplayName(farm.userId)}
                              </span>
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-2">
                              <Sprout className="w-4 h-4 text-[#456C2D]" />
                              <span className="text-[#1E441E] font-medium">{(farm.fields || []).length}</span>
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-2 text-[#456C2D]">
                              <Calendar className="w-4 h-4" />
                              <span>{farm.updatedAt ? new Date(farm.updatedAt).toLocaleDateString() : 'N/A'}</span>
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="flex gap-2">
                              <button
                                onClick={() => handleViewDetails(farm)}
                                className="p-2 text-[#456C2D] hover:text-[#8B4513] hover:bg-[#F5F9E8] rounded-lg transition-colors cursor-pointer"
                                title="View Details"
                              >
                                <Eye className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => handleReassign(farm)}
                                className="p-2 text-[#8B4513] hover:text-[#A0522D] hover:bg-[#F5F9E8] rounded-lg transition-colors cursor-pointer"
                                title="Reassign Farm"
                              >
                                <UserCheck className="w-4 h-4" />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}

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

        {/* Farm Modals */}
        {showReassignModal && selectedFarm && (
          <FarmReassignmentModal
            farm={selectedFarm as any}
            users={users}
            currentUserId={selectedFarm.userId}
            isOpen={showReassignModal}
            onClose={() => {
              setShowReassignModal(false);
              setSelectedFarm(null);
            }}
            onConfirm={handleReassignConfirm}
            isLoading={farmActionLoading}
          />
        )}

        {showDetailsModal && selectedFarm && (
          <FarmDetailsModal
            farm={selectedFarm as any}
            assignedUser={userMap.get(selectedFarm.userId)}
            isOpen={showDetailsModal}
            onClose={() => {
              setShowDetailsModal(false);
              setSelectedFarm(null);
            }}
          />
        )}

        <Footer />
      </main>
    </div>
  );
}