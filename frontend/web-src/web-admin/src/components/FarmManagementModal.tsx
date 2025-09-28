import React, { useState, useEffect } from 'react';
import { X, Plus, Trash2, Edit3, MapPin, Calendar, Sprout, Loader2 } from 'lucide-react';
import { Farm, FarmAssignmentData, farmService } from '../api/services/farmService';
import { User } from '../api/services/authService';

interface FarmManagementModalProps {
  user: User;
  isOpen: boolean;
  onClose: () => void;
  onUpdate: () => void;
}

interface FarmFormData extends FarmAssignmentData {
  _id?: string;
}

const FarmManagementModal: React.FC<FarmManagementModalProps> = ({
  user,
  isOpen,
  onClose,
  onUpdate
}) => {
  const [farms, setFarms] = useState<Farm[]>([]);
  const [loading, setLoading] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [editingFarm, setEditingFarm] = useState<Farm | null>(null);
  const [formData, setFormData] = useState<FarmFormData>({
    fieldName: '',
    location: '',
    soilType: 'Loam',
    plantingDate: '',
    growthStage: 'VE'
  });
  const [actionLoading, setActionLoading] = useState(false);

  // Growth stages for corn
  const growthStages = [
    'VE', 'V1', 'V2', 'V3', 'V4', 'V5', 'V6', 'VT', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6'
  ];

  // Soil types
  const soilTypes = [
    'Clay', 'Sandy', 'Loam', 'Silt', 'Peat', 'Chalk'
  ];

  // Fetch user's farms
  const fetchFarms = async () => {
    if (!user._id) return;
    
    setLoading(true);
    try {
      const userFarms = await farmService.getFarmsByUserId(user._id);
      setFarms(userFarms);
    } catch (error) {
      console.error('Error fetching farms:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isOpen && user._id) {
      fetchFarms();
    }
  }, [isOpen, user._id]);

  // Handle form submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user._id) return;

    setActionLoading(true);
    try {
      if (editingFarm) {
        // Update existing farm
        await farmService.updateFarm(editingFarm._id, formData);
      } else {
        // Create new farm
        await farmService.assignFarmToUser(user._id, formData);
      }
      
      await fetchFarms();
      setShowForm(false);
      setEditingFarm(null);
      resetForm();
      onUpdate();
    } catch (error) {
      console.error('Error saving farm:', error);
      alert('Failed to save farm. Please try again.');
    } finally {
      setActionLoading(false);
    }
  };

  // Handle farm deletion
  const handleDelete = async (farmId: string) => {
    if (!confirm('Are you sure you want to delete this farm?')) return;

    setActionLoading(true);
    try {
      await farmService.deleteFarm(farmId);
      await fetchFarms();
      onUpdate();
    } catch (error) {
      console.error('Error deleting farm:', error);
      alert('Failed to delete farm. Please try again.');
    } finally {
      setActionLoading(false);
    }
  };

  // Reset form
  const resetForm = () => {
    setFormData({
      fieldName: '',
      location: '',
      soilType: 'Loam',
      plantingDate: '',
      growthStage: 'VE'
    });
  };

  // Handle edit
  const handleEdit = (farm: Farm) => {
    setEditingFarm(farm);
    setFormData({
      fieldName: farm.fieldName,
      location: farm.location,
      soilType: farm.soilType,
      plantingDate: farm.plantingDate.split('T')[0], // Format for date input
      growthStage: farm.growthStage
    });
    setShowForm(true);
  };

  // Handle add new
  const handleAddNew = () => {
    setEditingFarm(null);
    resetForm();
    setShowForm(true);
  };

  // Handle close
  const handleClose = () => {
    setShowForm(false);
    setEditingFarm(null);
    resetForm();
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-[#456C2D] text-white p-6 flex items-center justify-between">
          <div>
            <h2 className="text-xl font-bold">Farm Management</h2>
            <p className="text-[#E6F0D3] mt-1">
              Managing farms for: <span className="font-semibold">{user.fullName}</span>
            </p>
          </div>
          <button
            onClick={handleClose}
            className="text-white hover:text-[#E6F0D3] transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6 max-h-[calc(90vh-120px)] overflow-y-auto">
          {!showForm ? (
            // Farm List View
            <div>
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-semibold text-[#1E441E]">
                  Assigned Farms ({farms.length})
                </h3>
                <button
                  onClick={handleAddNew}
                  className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-white rounded-lg hover:bg-[#A0522D] transition-colors"
                >
                  <Plus className="w-4 h-4" />
                  Add Farm
                </button>
              </div>

              {loading ? (
                <div className="flex items-center justify-center py-12">
                  <Loader2 className="w-8 h-8 animate-spin text-[#456C2D]" />
                  <span className="ml-2 text-[#456C2D]">Loading farms...</span>
                </div>
              ) : farms.length === 0 ? (
                <div className="text-center py-12">
                  <Sprout className="w-16 h-16 text-[#B8D4A8] mx-auto mb-4" />
                  <p className="text-[#456C2D] text-lg">No farms assigned</p>
                  <p className="text-[#7A8471] mt-2">Click "Add Farm" to assign a farm to this user</p>
                </div>
              ) : (
                <div className="grid gap-4">
                  {farms.map((farm) => (
                    <div
                      key={farm._id}
                      className="border border-[#B8D4A8] rounded-lg p-4 hover:shadow-md transition-shadow"
                    >
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <h4 className="font-semibold text-[#1E441E] text-lg mb-2">
                            {farm.fieldName}
                          </h4>
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                            <div className="flex items-center gap-2 text-[#456C2D]">
                              <MapPin className="w-4 h-4" />
                              <span>{farm.location}</span>
                            </div>
                            <div className="flex items-center gap-2 text-[#456C2D]">
                              <Calendar className="w-4 h-4" />
                              <span>Planted: {new Date(farm.plantingDate).toLocaleDateString()}</span>
                            </div>
                            <div className="flex items-center gap-2 text-[#456C2D]">
                              <Sprout className="w-4 h-4" />
                              <span>Stage: {farm.growthStage}</span>
                            </div>
                            <div className="flex items-center gap-2 text-[#456C2D]">
                              <span>Soil: {farm.soilType}</span>
                            </div>
                          </div>
                        </div>
                        <div className="flex gap-2 ml-4">
                          <button
                            onClick={() => handleEdit(farm)}
                            className="p-2 text-[#456C2D] hover:text-[#8B4513] hover:bg-[#F5F9E8] rounded-lg transition-colors"
                            title="Edit Farm"
                          >
                            <Edit3 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleDelete(farm._id)}
                            className="p-2 text-red-600 hover:text-red-800 hover:bg-red-50 rounded-lg transition-colors"
                            title="Delete Farm"
                            disabled={actionLoading}
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ) : (
            // Farm Form View
            <div>
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-[#1E441E]">
                  {editingFarm ? 'Edit Farm' : 'Add New Farm'}
                </h3>
                <p className="text-[#456C2D] mt-1">
                  {editingFarm ? 'Update farm information' : 'Create a new farm assignment'}
                </p>
              </div>

              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Field Name */}
                  <div>
                    <label className="block text-sm font-medium text-[#1E441E] mb-2">
                      Field Name *
                    </label>
                    <input
                      type="text"
                      value={formData.fieldName}
                      onChange={(e) => setFormData({ ...formData, fieldName: e.target.value })}
                      className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#8B4513] focus:border-transparent"
                      placeholder="e.g., North Field, Main Plot"
                      required
                    />
                  </div>

                  {/* Location */}
                  <div>
                    <label className="block text-sm font-medium text-[#1E441E] mb-2">
                      Location *
                    </label>
                    <input
                      type="text"
                      value={formData.location}
                      onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                      className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#8B4513] focus:border-transparent"
                      placeholder="e.g., Barangay, Municipality, Province"
                      required
                    />
                  </div>

                  {/* Soil Type */}
                  <div>
                    <label className="block text-sm font-medium text-[#1E441E] mb-2">
                      Soil Type *
                    </label>
                    <select
                      value={formData.soilType}
                      onChange={(e) => setFormData({ ...formData, soilType: e.target.value })}
                      className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#8B4513] focus:border-transparent"
                      required
                    >
                      {soilTypes.map((type) => (
                        <option key={type} value={type}>{type}</option>
                      ))}
                    </select>
                  </div>

                  {/* Planting Date */}
                  <div>
                    <label className="block text-sm font-medium text-[#1E441E] mb-2">
                      Planting Date *
                    </label>
                    <input
                      type="date"
                      value={formData.plantingDate}
                      onChange={(e) => setFormData({ ...formData, plantingDate: e.target.value })}
                      className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#8B4513] focus:border-transparent"
                      required
                    />
                  </div>

                  {/* Growth Stage */}
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-[#1E441E] mb-2">
                      Growth Stage *
                    </label>
                    <select
                      value={formData.growthStage}
                      onChange={(e) => setFormData({ ...formData, growthStage: e.target.value })}
                      className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#8B4513] focus:border-transparent"
                      required
                    >
                      {growthStages.map((stage) => (
                        <option key={stage} value={stage}>{stage}</option>
                      ))}
                    </select>
                    <p className="text-xs text-[#7A8471] mt-1">
                      VE = Emergence, V1-V6 = Vegetative stages, VT = Tasseling, R1-R6 = Reproductive stages
                    </p>
                  </div>
                </div>

                {/* Form Actions */}
                <div className="flex gap-3 pt-6 border-t border-[#E6F0D3]">
                  <button
                    type="button"
                    onClick={() => setShowForm(false)}
                    className="px-6 py-2 border border-[#B8D4A8] text-[#456C2D] rounded-lg hover:bg-[#F5F9E8] transition-colors"
                    disabled={actionLoading}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="flex items-center gap-2 px-6 py-2 bg-[#8B4513] text-white rounded-lg hover:bg-[#A0522D] transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    disabled={actionLoading}
                  >
                    {actionLoading && <Loader2 className="w-4 h-4 animate-spin" />}
                    {editingFarm ? 'Update Farm' : 'Add Farm'}
                  </button>
                </div>
              </form>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default FarmManagementModal;
