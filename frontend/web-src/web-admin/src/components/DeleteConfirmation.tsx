import React, { useState } from 'react';
import { Loader2 } from 'lucide-react';
import { User } from '../api/services/authService';

interface DeleteConfirmationProps {
  user: User | null;
  onConfirm: (reason?: string) => Promise<void>;
  onCancel: () => void;
  isLoading: boolean;
  isRegionalAdmin?: boolean;
}

const DeleteConfirmation: React.FC<DeleteConfirmationProps> = ({
  user,
  onConfirm,
  onCancel,
  isLoading,
  isRegionalAdmin = false
}) => {
  const [reason, setReason] = useState('');

  if (!user) {
    return null;
  }

  const handleConfirm = async () => {
    await onConfirm(isRegionalAdmin ? reason : undefined);
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-md p-6">
        <h2 className="text-xl font-semibold mb-4">
          {isRegionalAdmin ? 'Request User Deletion' : 'Confirm Deletion'}
        </h2>
        <p className="mb-4">
          Are you sure you want to delete the account for{' '}
          <span className="font-semibold">{user.fullName}</span>?
          {isRegionalAdmin ? ' This will submit a deletion request for super admin approval.' : ' This action cannot be undone.'}
        </p>
        
        {isRegionalAdmin && (
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Reason for Deletion <span className="text-red-500">*</span>
            </label>
            <textarea
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#456C2D] resize-none"
              rows={4}
              placeholder="Please provide a reason for this deletion request..."
              required
            />
          </div>
        )}
        
        <div className="flex justify-end gap-2">
          <button
            onClick={onCancel}
            className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
            disabled={isLoading}
          >
            Cancel
          </button>
          <button
            onClick={handleConfirm}
            disabled={isLoading || (isRegionalAdmin && !reason.trim())}
            className="px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-md hover:bg-[#A0522D] disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center"
          >
            {isLoading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
            {isRegionalAdmin ? 'Submit Request' : 'Delete'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeleteConfirmation;