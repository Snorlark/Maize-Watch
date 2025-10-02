import { useState, useEffect } from 'react';
import { Sprout, Search, RefreshCw, Eye, UserCheck, Loader2, ArrowUpDown, ChevronUp, ChevronDown } from 'lucide-react';
import { Navigate } from 'react-router-dom';
import Footer from '../components/Footer';
import { CurrentFarm, Farm, farmService } from "../api/services/farmService";
import { useUserContext } from '../contexts/UserContext';
import FarmReassignmentModal from '../components/FarmReassignmentModal';
import FarmDetailsModal from '../components/FarmDetailsModal';

type SortDirection = 'asc' | 'desc' | null;
type SortField = 'farmName' | 'location' | 'assignedUser' | 'fieldsCount' | 'updatedAt' | null;

export default function FarmAssignmentManagement() {
  const { users, currentUser, fetchUsers } = useUserContext();
  const [farms, setFarms] = useState<CurrentFarm[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedFarm, setSelectedFarm] = useState<CurrentFarm | null>(null);
  const [showReassignModal, setShowReassignModal] = useState(false);
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [sortField, setSortField] = useState<SortField>(null);
  const [sortDirection, setSortDirection] = useState<SortDirection>(null);
  const [authChecked, setAuthChecked] = useState(false);

  // Check if user has admin access
  const hasAdminAccess = currentUser?.role === 'admin' || currentUser?.role === 'super_admin';

  // Create a map of users for quick lookup
  const userMap = new Map(users.map(user => [user._id || '', user]));

  // Get user display name
  const getUserDisplayName = (userId: string): string => {
    const user = userMap.get(userId);
    return user ? user.fullName || user.username : 'Unknown User';
  };

  // Fetch farms and users
  const fetchFarms = async () => {
    setLoading(true);
    try {
      const farmData = await farmService.getAllFarmsWithUsers();
      setFarms(farmData);
    } catch (error) {
      console.error('Error fetching farms:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    setAuthChecked(true);
    if (hasAdminAccess) {
      fetchUsers();
      fetchFarms();
    }
  }, [hasAdminAccess]);

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

    setActionLoading(true);
    try {
      await farmService.reassignFarm(selectedFarm._id, newUserId);
      await fetchFarms(); // Refresh the list
      setShowReassignModal(false);
      setSelectedFarm(null);
      alert('Farm reassigned successfully!');
    } catch (error: any) {
      console.error('Error reassigning farm:', error);
      let errorMessage = 'Failed to reassign farm. ';
      if (error.response?.data?.message) {
        errorMessage += error.response.data.message;
      } else if (error.message) {
        errorMessage += error.message;
      } else {
        errorMessage += 'Please try again.';
      }
      alert(errorMessage);
    } finally {
      setActionLoading(false);
    }
  };

  // Redirect if no admin access
  if (authChecked && !hasAdminAccess) {
    return <Navigate to="/unauthorized" replace />;
  }

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
      <main className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="font-bold text-[#1E441E] mb-2 flex items-center gap-3 text-xl">
            <Sprout className="w-8 h-8 sm:w-10 sm:h-10 text-[#456C2D]" />
            Farm Assignment Management
          </h1>
          <p className="text-[#456C2D] text-base">
            Manage farm assignments and reassign farms to different users
          </p>
          <div className="mt-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#456C2D] text-[#F5F5DC] text-sm">
              {currentUser?.role === 'super_admin' ? 'Super Admin Access' : 'Admin Access'}
            </span>
          </div>
        </div>

        {/* Controls */}
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
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 bg-[#456C2D] text-white rounded-lg hover:bg-[#5A7A3A] transition-colors disabled:opacity-50 cursor-pointer disabled:cursor-not-allowed"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
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
        <div className="overflow-x-auto">
          {/* Table Header */}
          <div className="flex justify-between mb-4 items-end">
            <div>
              <h2 className="text-xl font-semibold text-[#1E441E]">Farm Assignments</h2>
              <p className="text-sm text-[#456C2D] mt-1">
                Showing {sortedFarms.length} of {farms.length} farms
              </p>
            </div>
          </div>
          
          <table className="min-w-full bg-white rounded-xl shadow-md overflow-hidden">
            <thead className="bg-[#456C2D] text-[#F5F5DC] text-left">
              <tr>
                <th className="px-6 py-3 w-12">#</th>
                <th 
                  className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                  onClick={() => handleSort('farmName')}
                >
                  <div className="flex items-center justify-between">
                    Farm Name
                    {getSortIcon('farmName')}
                  </div>
                </th>
                <th 
                  className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                  onClick={() => handleSort('location')}
                >
                  <div className="flex items-center justify-between">
                    Location
                    {getSortIcon('location')}
                  </div>
                </th>
                <th 
                  className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                  onClick={() => handleSort('assignedUser')}
                >
                  <div className="flex items-center justify-between">
                    Assigned User
                    {getSortIcon('assignedUser')}
                  </div>
                </th>
                <th 
                  className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                  onClick={() => handleSort('fieldsCount')}
                >
                  <div className="flex items-center justify-between">
                    Fields
                    {getSortIcon('fieldsCount')}
                  </div>
                </th>
                <th 
                  className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
                  onClick={() => handleSort('updatedAt')}
                >
                  <div className="flex items-center justify-between">
                    Last Updated
                    {getSortIcon('updatedAt')}
                  </div>
                </th>
                <th className="px-6 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading && sortedFarms.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center">
                    <Loader2 className="w-6 h-6 mx-auto animate-spin" />
                    <p>Loading farms...</p>
                  </td>
                </tr>
              ) : sortedFarms.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center">No farms found</td>
                </tr>
              ) : (
                sortedFarms.map((farm, index) => (
                  <tr key={farm._id} className="border-b hover:bg-[#F5F9E8] transition-colors">
                    <td className="px-6 py-4 text-center font-medium text-[#456C2D]">
                      {index + 1}
                    </td>
                    <td className="px-6 py-4">{farm.farmName || farm.fieldName || 'Unnamed Farm'}</td>
                    <td className="px-6 py-4">
                      {farm.location || 'Location not specified'}
                    </td>
                    <td className="px-6 py-4">
                      {getUserDisplayName(farm.userId)}
                    </td>
                    <td className="px-6 py-4">
                      {(farm.fields || []).length}
                    </td>
                    <td className="px-6 py-4">
                      {farm.updatedAt ? new Date(farm.updatedAt).toLocaleDateString() : 'N/A'}
                    </td>
                    <td className="px-6 py-4 flex gap-2">
                      <Eye 
                        className="w-5 h-5 text-[#456C2D] cursor-pointer hover:text-[#8B4513] hover:scale-110 transition-all" 
                        onClick={() => handleViewDetails(farm)}
                      />
                      <UserCheck 
                        className="w-5 h-5 text-[#8B4513] cursor-pointer hover:text-[#A0522D] hover:scale-110 transition-all" 
                        onClick={() => handleReassign(farm)}
                      />
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
          
          {/* Sort Status Indicator */}
          {sortField && (
            <div className="mt-3 text-sm text-[#456C2D]">
              <span className="font-medium">Sorted by:</span> {sortField === 'farmName' ? 'Farm Name' : 
                                                              sortField === 'location' ? 'Location' : 
                                                              sortField === 'assignedUser' ? 'Assigned User' : 
                                                              sortField === 'fieldsCount' ? 'Fields' : 'Last Updated'} 
              ({sortDirection === 'asc' ? 'A to Z' : 'Z to A'})
            </div>
          )}
        </div>

        {/* Modals */}
        {showReassignModal && selectedFarm && (
          <FarmReassignmentModal
            farm={selectedFarm as Farm}
            users={users}
            currentUserId={selectedFarm.userId}
            isOpen={showReassignModal}
            onClose={() => {
              setShowReassignModal(false);
              setSelectedFarm(null);
            }}
            onConfirm={handleReassignConfirm}
            isLoading={actionLoading}
          />
        )}

        {showDetailsModal && selectedFarm && (
          <FarmDetailsModal
            farm={selectedFarm as Farm}
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
