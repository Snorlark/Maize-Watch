import { useState, useEffect } from 'react';
import { Users, MapPin, Calendar, Sprout, Search, RefreshCw, Eye, UserCheck, Loader2, ArrowUpDown, ChevronUp, ChevronDown } from 'lucide-react';
import { Navigate } from 'react-router-dom';
import Footer from '../components/Footer';
import { CurrentFarm, farmService } from '../api/services/farmService';
import authService from '../api/services/authService';
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
    (farm.farmName || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
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
        valueA = (a.farmName || '').toLowerCase();
        valueB = (b.farmName || '').toLowerCase();
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
  const handleReassign = (farm: Farm) => {
    setSelectedFarm(farm);
    setShowReassignModal(true);
  };

  // Handle view details
  const handleViewDetails = (farm: Farm) => {
    setSelectedFarm(farm);
    setShowDetailsModal(true);
  };

  // Handle reassignment confirmation
  const handleReassignConfirm = async (newUserId: string) => {
    if (!selectedFarm) return;

    setActionLoading(true);
    try {
      console.log('Attempting to reassign farm:', {
        farmId: selectedFarm._id,
        currentUserId: selectedFarm.userId,
        newUserId: newUserId
      });
      
      // Test basic connectivity first
      console.log('Testing basic connectivity...');
      try {
        // Test if we can reach the backend at all with a simple request
        const response = await fetch('http://localhost:8080/api/farms', {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${authService.getToken()}`,
            'Content-Type': 'application/json'
          }
        });
        console.log('Basic connectivity test:', response.status, response.statusText);
        
        if (response.ok) {
          console.log('✅ Backend is reachable');
          
          // First, let's see what farms are actually available
          const farmsData = await response.json();
          console.log('Available farms:', farmsData);
          
          if (farmsData.data && farmsData.data.farms && farmsData.data.farms.length > 0) {
            console.log('First farm ID in list:', farmsData.data.farms[0]._id);
            console.log('Selected farm ID:', selectedFarm._id);
            console.log('Farm ID match?', farmsData.data.farms.some((f: any) => f._id === selectedFarm._id));
          }
          
          // Now test the specific farm endpoint
          console.log('Testing specific farm endpoint...');
          
          // First test the debug-auth route
          console.log('Testing debug-auth route...');
          const debugAuthResponse = await fetch(`http://localhost:8080/api/farms/debug-auth/${selectedFarm._id}`, {
            method: 'GET',
            headers: {
              'Authorization': `Bearer ${authService.getToken()}`,
              'Content-Type': 'application/json'
            }
          });
          console.log('Debug-auth test:', debugAuthResponse.status, debugAuthResponse.statusText);
          if (debugAuthResponse.ok) {
            const debugData = await debugAuthResponse.json();
            console.log('Debug-auth data:', debugData);
          }
          
          // Then test the regular farm endpoint
          const farmResponse = await fetch(`http://localhost:8080/api/farms/${selectedFarm._id}`, {
            method: 'GET',
            headers: {
              'Authorization': `Bearer ${authService.getToken()}`,
              'Content-Type': 'application/json'
            }
          });
          console.log('Farm endpoint test:', farmResponse.status, farmResponse.statusText);
          
          if (farmResponse.ok) {
            console.log('✅ Farm endpoint is reachable');
            const farmData = await farmResponse.json();
            console.log('Farm data:', farmData);
          } else {
            console.log('❌ Farm endpoint failed:', await farmResponse.text());
          }
        } else {
          console.log('❌ Backend not reachable:', await response.text());
        }
      } catch (connectError) {
        console.error('❌ Connectivity test failed:', connectError);
      }
      
      const result = await farmService.reassignFarm(selectedFarm._id, newUserId);
      console.log('Reassignment successful:', result);
      
      await fetchFarms(); // Refresh the list
      setShowReassignModal(false);
      setSelectedFarm(null);
      alert('Farm reassigned successfully!');
    } catch (error: any) {
      console.error('Error reassigning farm:', error);
      console.error('Error details:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status
      });
      
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
              className="flex items-center gap-2 px-4 py-2 bg-[#456C2D] text-white rounded-lg hover:bg-[#5A7A3A] transition-colors disabled:opacity-50"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              Refresh
            </button>
          </div>

          {/* Stats */}
          <div className="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-4">
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
            <div className="bg-[#F5F9E8] p-4 rounded-lg">
              <div className="text-2xl font-bold text-[#1E441E]">
                {new Set(farms.map(farm => farm.userId).filter(Boolean)).size}
              </div>
              <div className="text-sm text-[#456C2D]">Active Users</div>
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
            <table className="min-w-full">
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
                {loading ? (
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
                        <div className="font-medium text-[#1E441E]">{farm.farmName || 'Unnamed Farm'}</div>
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
                            className="p-2 text-[#456C2D] hover:text-[#8B4513] hover:bg-[#F5F9E8] rounded-lg transition-colors"
                            title="View Details"
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleReassign(farm)}
                            className="p-2 text-[#8B4513] hover:text-[#A0522D] hover:bg-[#F5F9E8] rounded-lg transition-colors"
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

        {/* Modals */}
        {showReassignModal && selectedFarm && (
          <FarmReassignmentModal
            farm={selectedFarm}
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
            farm={selectedFarm}
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
