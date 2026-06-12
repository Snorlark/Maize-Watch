import React, { useState, useEffect } from 'react';
import { X, User, Phone, MapPin, Save, Loader2, CheckCircle } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { userService } from '../api/client';

interface AccountSettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const AccountSettingsModal: React.FC<AccountSettingsModalProps> = ({ isOpen, onClose }) => {
  const { user, refreshUserData } = useAuth();
  const [isSaving, setIsSaving] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    username: '',
    fullName: '',
    contactNumber: '',
    address: '',
    email: ''
  });

  // Load user data when modal opens
  useEffect(() => {
    if (isOpen && user) {
      // Handle address field - convert object to string if needed
      let addressString = '';
      if (typeof user.address === 'string') {
        addressString = user.address;
      } else if (user.address && typeof user.address === 'object') {
        // Convert address object to string format
        const addr = user.address as { region?: string; province?: string; municipality?: string; barangay?: string };
        const parts = [addr.barangay, addr.municipality, addr.province, addr.region].filter(Boolean);
        addressString = parts.join(', ');
      }
      
      setFormData({
        username: user.username || '',
        fullName: user.fullName || '',
        contactNumber: user.contactNumber || '',
        address: addressString,
        email: user.email || ''
      });
      setError(null);
      setShowSuccess(false);
    }
  }, [isOpen, user]);

  // Handle input changes
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Clear error when user starts typing
    if (error) setError(null);
  };

  // Handle form submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setError(null);

    try {
      // Validate required fields
      if (!formData.fullName || !formData.contactNumber || !formData.address) {
        throw new Error('Please fill in all required fields');
      }

      // Validate phone number format (Philippine mobile number)
      const phoneRegex = /^(09\d{9}|\+639\d{9})$/;
      if (!phoneRegex.test(formData.contactNumber)) {
        throw new Error('Please enter a valid Philippine mobile number');
      }

      // Update user profile
      const updateData = {
        fullName: formData.fullName,
        contactNumber: formData.contactNumber,
        address: formData.address,
        email: formData.email
      };

      await userService.updateProfile(updateData);
      
      // Refresh user data in context
      refreshUserData();
      
      setShowSuccess(true);
      setTimeout(() => {
        setShowSuccess(false);
        onClose();
      }, 2000);

    } catch (err: any) {
      setError(err.message || 'Failed to update profile. Please try again.');
    } finally {
      setIsSaving(false);
    }
  };

  // Handle backdrop click
  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  if (!isOpen) return null;

  return (
    <div 
      className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4"
      onClick={handleBackdropClick}
    >
      <div className="bg-white rounded-xl shadow-xl w-full max-w-sm transform transition-all duration-300 scale-100 max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-100">
          <div className="flex items-center gap-2">
            <div className="p-1.5 bg-green-100 rounded-md">
              <User className="w-4 h-4 text-green-600" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-gray-900">Account Settings</h2>
              <p className="text-xs text-gray-500">Update your profile</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-gray-100 rounded-md transition-colors"
          >
            <X className="w-4 h-4 text-gray-500" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          {/* Username (Read-only) */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Username
            </label>
            <input
              type="text"
              value={formData.username}
              disabled
              className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-md text-sm text-gray-500 cursor-not-allowed"
            />
            <p className="text-xs text-gray-400 mt-0.5">Cannot be changed</p>
          </div>

          {/* Full Name */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Full Name <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <input
                type="text"
                name="fullName"
                value={formData.fullName}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 pl-9 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors"
                placeholder="Enter your full name"
              />
              <User className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
            </div>
          </div>

          {/* Contact Number */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Contact Number <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <input
                type="tel"
                name="contactNumber"
                value={formData.contactNumber}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 pl-9 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors"
                placeholder="09XXXXXXXXX"
              />
              <Phone className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
            </div>
            <p className="text-xs text-gray-400 mt-0.5">Format: 09XXXXXXXXX</p>
          </div>

          {/* Address */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Address <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <input
                type="text"
                name="address"
                value={formData.address}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 pl-9 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors"
                placeholder="Enter your address"
              />
              <MapPin className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
            </div>
          </div>

          {/* Email */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Email (optional)
            </label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors"
              placeholder="Enter your email"
            />
          </div>

          {/* Error Message */}
          {error && (
            <div className="p-2 bg-red-50 border border-red-200 rounded-md">
              <p className="text-xs text-red-600">{error}</p>
            </div>
          )}

          {/* Success Message */}
          {showSuccess && (
            <div className="p-2 bg-green-50 border border-green-200 rounded-md flex items-center gap-1">
              <CheckCircle className="w-4 h-4 text-green-600" />
              <p className="text-xs text-green-600">Profile updated successfully!</p>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex gap-2 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-3 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 transition-colors text-sm"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSaving}
              className="flex-1 px-3 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-md hover:bg-[#A0522D] disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-1 text-sm"
            >
              {isSaving ? (
                <>
                  <Loader2 className="w-3 h-3 animate-spin" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="w-3 h-3" />
                  Save
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AccountSettingsModal;