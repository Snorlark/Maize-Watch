import React, { useState, useEffect } from 'react';
import { X, Loader2 } from 'lucide-react';
import { User } from '../api/userService';

interface UserFormProps {
  mode: 'create' | 'edit';
  initialData?: User | null;
  onSubmit: (data: Omit<User, '_id'>) => Promise<void>;
  onCancel: () => void;
  isLoading: boolean;
}

const UserForm: React.FC<UserFormProps> = ({
  mode,
  initialData,
  onSubmit,
  onCancel,
  isLoading
}) => {
  const [formData, setFormData] = useState<Omit<User, '_id'>>({
    username: '',
    password: '',
    fullName: '',
    contactNumber: '',
    address: '',
    role: 'farmer',
    email: '',
    lot: 0,
  });

  useEffect(() => {
    if (initialData && mode === 'edit') {
      setFormData({
        username: initialData.username,
        password: '', // Password is not included when editing
        fullName: initialData.fullName,
        contactNumber: initialData.contactNumber,
        address: initialData.address,
        role: initialData.role,
        email: initialData.email || '',
        lot: initialData.lot || 0,
      });
    }
  }, [initialData, mode]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === 'lot' ? Number(value) : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // For edit mode, if password is empty, create a copy without it
    const submitData = { ...formData };
    if (mode === 'edit' && !submitData.password) {
      delete submitData.password;
    }
    
    await onSubmit(submitData);
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-md p-6 relative">
        <button 
          className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
          onClick={onCancel}
        >
          <X className="w-5 h-5" />
        </button>
        
        <h2 className="text-xl font-semibold mb-4">
          {mode === 'create' ? 'Create New Account' : 'Edit Account'}
        </h2>
        
        <form onSubmit={handleSubmit}>
          <div className="grid grid-cols-2 gap-4 mb-4">
            <div className="col-span-1">
              <label className="block text-sm font-medium text-gray-700 mb-1">Lot #</label>
              <input
                type="number"
                name="lot"
                value={formData.lot}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            <div className="col-span-1">
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
            {mode === 'create' && (
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <input
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleInputChange}
                  required={mode === 'create'}
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
                value={formData.fullName}
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
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Contact Number</label>
              <input
                type="text"
                name="contactNumber"
                value={formData.contactNumber}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
              />
            </div>
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
              <input
                type="text"
                name="address"
                value={formData.address}
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
                <option value="farmer">Farmer</option>
                <option value="admin">Admin</option>
                <option value="user">User</option>
              </select>
            </div>
          </div>
          
          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={onCancel}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
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