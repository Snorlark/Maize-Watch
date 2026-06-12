import React, { useState } from 'react';
import { X, Users, MapPin, Sprout, Search, UserCheck, AlertTriangle, Loader2 } from 'lucide-react';
import { Farm } from '../api/services/farmService';
import { User } from '../api/services/authService';

interface FarmReassignmentModalProps {
  farm: Farm;
  users: User[];
  currentUserId: string;
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (newUserId: string) => void;
  isLoading: boolean;
}

const FarmReassignmentModal: React.FC<FarmReassignmentModalProps> = ({
  farm,
  users,
  currentUserId,
  isOpen,
  onClose,
  onConfirm,
  isLoading
}) => {
  const [selectedUserId, setSelectedUserId] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');

  // Get current user details
  const currentUser = users.find(user => user._id === currentUserId);

  // Filter users based on search term and exclude current user
  const filteredUsers = users.filter(user => 
    user._id !== currentUserId &&
    (user.fullName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
     user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
     user.email?.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  // Handle confirmation
  const handleConfirm = () => {
    if (selectedUserId) {
      onConfirm(selectedUserId);
    }
  };

  // Get user display info
  const getUserDisplayInfo = (user: User) => {
    const name = user.fullName || user.username;
    const location = typeof user.address === 'object' && user.address 
      ? `${user.address.municipality}, ${user.address.province}` 
      : user.address || 'Location not specified';
    return { name, location };
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-[#8B4513] text-white p-6 flex items-center justify-between">
          <div>
            <h2 className="text-xl font-bold">Reassign Farm</h2>
            <p className="text-[#F5F5DC] mt-1">Change the assigned user for this farm</p>
          </div>
          <button
            onClick={onClose}
            className="text-white hover:text-[#F5F5DC] transition-colors"
            disabled={isLoading}
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6 max-h-[calc(90vh-180px)] overflow-y-auto">
          {/* Farm Information */}
          <div className="bg-[#F5F9E8] rounded-lg p-4 mb-6">
            <h3 className="font-semibold text-[#1E441E] mb-3">Farm Details</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-2">
                <Sprout className="w-4 h-4 text-[#456C2D]" />
                <span className="font-medium text-[#1E441E]">{farm.farmName || 'Unnamed Farm'}</span>
              </div>
              <div className="flex items-center gap-2">
                <MapPin className="w-4 h-4 text-[#456C2D]" />
                <span className="text-[#456C2D] text-sm truncate">{farm.location || 'Location not specified'}</span>
              </div>
              <div className="flex items-center gap-2">
                <Users className="w-4 h-4 text-[#456C2D]" />
                <span className="text-[#456C2D] text-sm">{(farm.fields || []).length} Fields</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-[#456C2D] text-sm">
                  {(farm.fields || []).reduce((acc, field) => acc + (field.sensors || []).length, 0)} Sensors
                </span>
              </div>
            </div>
          </div>

          {/* Current Assignment */}
          <div className="bg-[#FFF3CD] border border-[#FFEAA7] rounded-lg p-4 mb-6">
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-[#856404] mt-0.5" />
              <div>
                <h4 className="font-medium text-[#856404] mb-1">Current Assignment</h4>
                <p className="text-[#856404] text-sm">
                  This farm is currently assigned to <strong>{currentUser?.fullName || currentUser?.username || 'Unknown User'}</strong>
                </p>
              </div>
            </div>
          </div>

          {/* User Search */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-[#1E441E] mb-2">
              Search for New User
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-[#456C2D] w-4 h-4" />
              <input
                type="text"
                placeholder="Search by name, username, or email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-[#B8D4A8] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#8B4513] focus:border-transparent"
                disabled={isLoading}
              />
            </div>
          </div>

          {/* User Selection */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-[#1E441E] mb-2">
              Select New User ({filteredUsers.length} available)
            </label>
            <div className="max-h-64 overflow-y-auto border border-[#B8D4A8] rounded-lg">
              {filteredUsers.length === 0 ? (
                <div className="p-4 text-center text-[#456C2D]">
                  {searchTerm ? 'No users found matching your search' : 'No other users available'}
                </div>
              ) : (
                filteredUsers.map((user) => {
                  const { name, location } = getUserDisplayInfo(user);
                  return (
                    <div
                      key={user._id}
                      className={`p-3 border-b border-[#E6F0D3] last:border-b-0 cursor-pointer transition-colors ${
                        selectedUserId === user._id
                          ? 'bg-[#8B4513] text-white'
                          : 'hover:bg-[#F5F9E8]'
                      }`}
                      onClick={() => setSelectedUserId(user._id || '')}
                    >
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="font-medium">{name}</div>
                          <div className={`text-sm ${selectedUserId === user._id ? 'text-[#F5F5DC]' : 'text-[#456C2D]'}`}>
                            {user.email}
                          </div>
                          <div className={`text-sm ${selectedUserId === user._id ? 'text-[#F5F5DC]' : 'text-[#7A8471]'}`}>
                            {location}
                          </div>
                        </div>
                        {selectedUserId === user._id && (
                          <UserCheck className="w-5 h-5" />
                        )}
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>

          {/* Selected User Preview */}
          {selectedUserId && (
            <div className="bg-[#E8F5E8] border border-[#C3E6C3] rounded-lg p-4 mb-6">
              <h4 className="font-medium text-[#1E441E] mb-2">New Assignment Preview</h4>
              <div className="text-[#456C2D] text-sm">
                Farm <strong>{farm.farmName || 'Unnamed Farm'}</strong> will be reassigned to{' '}
                <strong>
                  {getUserDisplayInfo(filteredUsers.find(u => u._id === selectedUserId)!).name}
                </strong>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="bg-[#F5F9E8] px-6 py-4 flex gap-3 justify-end border-t border-[#E6F0D3]">
          <button
            onClick={onClose}
            className="px-4 py-2 border border-[#B8D4A8] text-[#456C2D] rounded-lg hover:bg-[#F5F9E8] transition-colors"
            disabled={isLoading}
          >
            Cancel
          </button>
          <button
            onClick={handleConfirm}
            className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-white rounded-lg hover:bg-[#A0522D] transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={!selectedUserId || isLoading}
          >
            {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
            Confirm Reassignment
          </button>
        </div>
      </div>
    </div>
  );
};

export default FarmReassignmentModal;
