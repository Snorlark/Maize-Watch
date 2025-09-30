import React, { useState, useEffect } from "react";
import { X, Loader2 } from 'lucide-react';
import { User } from '../api/services/authService';
import { useAuth } from '../contexts/AuthContext';

interface UserFormProps {
  mode: 'create' | 'edit';
  initialData?: User | null;
  onSubmit: (data: Omit<User, '_id'> & { password?: string }) => Promise<void>;
  onCancel: () => void;
  isLoading: boolean;
}

interface FormData {
  username: string;
  email: string;
  password?: string;
  fullName: string;
  contactNumber: string;
  address: string;
  region: string;
  province: string;
  municipality: string;
  barangay: string;
  role: string;
  isActive: boolean;
  createdAt: string;
  lastLogin?: string;
}

const UserForm: React.FC<UserFormProps> = ({
  mode,
  initialData,
  onSubmit,
  onCancel,
  isLoading
}) => {
  const { user: currentUser } = useAuth();
  
  // Set default region for regional admins
  const getDefaultRegion = () => {
    if (currentUser?.role === 'regional_admin' && currentUser?.assignedRegion) {
      return currentUser.assignedRegion;
    }
    return '';
  };

  const [formData, setFormData] = useState<FormData>({
    username: '',
    email: '',
    password: '',
    fullName: '',
    contactNumber: '',
    address: '',
    region: getDefaultRegion(),
    province: '',
    municipality: '',
    barangay: '',
    role: 'user',
    isActive: true,
    createdAt: new Date().toISOString(),
  });

  // Reset form data when mode changes to create
  useEffect(() => {
    if (mode === 'create' && !initialData) {
      setFormData({
        username: '',
        email: '',
        password: '',
        fullName: '',
        contactNumber: '',
        address: '',
        region: getDefaultRegion(),
        province: '',
        municipality: '',
        barangay: '',
        role: 'user',
        isActive: true,
        createdAt: new Date().toISOString(),
      });
    }
  }, [mode, initialData, currentUser]);

  useEffect(() => {
    if (initialData && mode === 'edit') {
      // Handle both old string address format and new object format
      const addressData = typeof initialData.address === 'object' && initialData.address ? {
        address: `${initialData.address.barangay}, ${initialData.address.municipality}, ${initialData.address.province}, ${initialData.address.region}`,
        region: initialData.address.region,
        province: initialData.address.province,
        municipality: initialData.address.municipality,
        barangay: initialData.address.barangay,
      } : {
        address: initialData.address || '',
        region: initialData.region || '',
        province: initialData.province || '',
        municipality: initialData.municipality || '',
        barangay: initialData.barangay || '',
      };

      setFormData({
        username: initialData.username || '',
        email: initialData.email || '',
        password: '', // Password is not included when editing
        fullName: initialData.fullName || '',
        contactNumber: initialData.contactNumber || '',
        ...addressData,
        role: initialData.role || 'user',
        isActive: initialData.isActive ?? true,
        createdAt: initialData.createdAt || new Date().toISOString(),
        lastLogin: initialData.lastLogin,
      });
    }
  }, [initialData, mode]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Transform form data to match backend expected format
    const { region, province, municipality, barangay, address, ...otherData } = formData;
    
    const submitData = {
      ...otherData,
      address: {
        region: region || '',
        province: province || '',
        municipality: municipality || '',
        barangay: barangay || ''
      }
    };
    
    // For edit mode, if password is empty, remove it
    if (mode === 'edit' && !submitData.password) {
      delete submitData.password;
    }
    
    // Debug logging
    console.log('UserForm submitData:', JSON.stringify(submitData, null, 2));
    
    await onSubmit(submitData);
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 backdrop-blur-sm flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-2xl p-6 relative max-h-[90vh] overflow-y-auto">
        <button 
          className="absolute top-4 right-4 text-gray-500 hover:text-gray-700 cursor-pointer"
          onClick={onCancel}
        >
          <X className="w-5 h-5" />
        </button>
        
        <h2 className="text-xl font-semibold mb-4">
          {mode === 'create' ? 'Create New Account' : 'Edit Account'}
        </h2>
        
        <form onSubmit={handleSubmit}>
          <div className="grid grid-cols-2 gap-4 mb-4">
            
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Username</label>
              <input
                type="text"
                name="username"
                value={formData.username}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            
            {mode === 'create' && (
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Password
                  <span className="text-xs text-gray-500 ml-1">(min 8 characters)</span>
                </label>
                <input
                  type="password"
                  name="password"
                  value={formData.password || ''}
                  onChange={handleInputChange}
                  required={mode === 'create'}
                  minLength={8}
                  placeholder="Enter password (min 8 characters)"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
                />
              </div>
            )}
            {mode === 'edit' && (
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  New Password (leave blank to keep unchanged)
                </label>
                <input
                  type="password"
                  name="password"
                  value={formData.password || ''}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
                />
              </div>
            )}
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input
                type="text"
                name="fullName"
                value={formData.fullName || ''}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
           
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Number
                <span className="text-xs text-gray-500 ml-1">(Format: 09xxxxxxxxx)</span>
              </label>
              <input
                type="text"
                name="contactNumber"
                value={formData.contactNumber || ''}
                onChange={handleInputChange}
                placeholder="09123456789"
                required
                pattern="^(09\d{9}|\+639\d{9})$"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Region</label>
              <input
                type="text"
                name="region"
                value={formData.region || ''}
                onChange={handleInputChange}
                required
                readOnly={currentUser?.role === 'regional_admin'}
                placeholder={currentUser?.role === 'regional_admin' ? '(Auto-assigned)' : 'Enter region'}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Province</label>
              <input
                type="text"
                name="province"
                value={formData.province || ''}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Municipality</label>
              <input
                type="text"
                name="municipality"
                value={formData.municipality || ''}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Barangay</label>
              <input
                type="text"
                name="barangay"
                value={formData.barangay || ''}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
              <select
                name="role"
                value={formData.role}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              >
                <option value="user">User</option>
                <option value="admin">Admin</option>
                <option value="super_admin">Super Admin</option>
              </select>
            </div>
            
          </div>
          
          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={onCancel}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 cursor-pointer"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-md hover:bg-[#A0522D] disabled:opacity-50 disabled:cursor-not-allowed transition-colors cursor-pointer"
            >
              {isLoading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
              {mode === 'create' ? 'Create Account' : 'Save Changes'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default UserForm;