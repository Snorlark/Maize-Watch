import React, { useState } from 'react';
import { Check, X, AlertCircle, Clock, User as UserIcon, Loader2 } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';

interface PendingDeletionUser {
  _id: string;
  username: string;
  email?: string;
  fullName: string;
  role: string;
  deletionRequestedAt: string;
  deletionReason?: string;
  deletionRequestedBy?: {
    _id: string;
    username: string;
    email?: string;
    fullName: string;
  };
}

interface PendingDeletionsTableProps {
  pendingDeletions: PendingDeletionUser[];
  loading: boolean;
  onApprove: (userId: string) => Promise<void>;
  onReject: (userId: string) => Promise<void>;
  isSuperAdmin: boolean;
}

const PendingDeletionsTable: React.FC<PendingDeletionsTableProps> = ({
  pendingDeletions,
  loading,
  onApprove,
  onReject,
  isSuperAdmin
}) => {
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [rejectionReason, setRejectionReason] = useState('');

  // Debug log
  console.log('PendingDeletionsTable render:', { isSuperAdmin, pendingDeletionsCount: pendingDeletions.length });

  const handleApprove = async (userId: string) => {
    if (!confirm('Are you sure you want to approve this deletion? This action cannot be undone.')) {
      return;
    }
    
    setProcessingId(userId);
    try {
      await onApprove(userId);
    } finally {
      setProcessingId(null);
    }
  };

  const handleRejectClick = (userId: string) => {
    setSelectedUserId(userId);
    setShowRejectModal(true);
  };

  const handleRejectSubmit = async () => {
    if (!selectedUserId) return;
    
    setProcessingId(selectedUserId);
    try {
      await onReject(selectedUserId);
      setShowRejectModal(false);
      setRejectionReason('');
      setSelectedUserId(null);
    } finally {
      setProcessingId(null);
    }
  };

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'super_admin':
        return 'bg-purple-100 text-purple-800 border-purple-200';
      case 'admin':
        return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'regional_admin':
        return 'bg-green-100 text-green-800 border-green-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const formatRoleName = (role: string) => {
    return role.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center py-12">
        <Loader2 className="w-8 h-8 animate-spin text-[#456C2D]" />
        <span className="ml-3 text-gray-600">Loading pending deletions...</span>
      </div>
    );
  }

  if (pendingDeletions.length === 0) {
    return (
      <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
        <AlertCircle className="w-12 h-12 text-gray-400 mx-auto mb-4" />
        <p className="text-gray-600">No pending deletion requests</p>
      </div>
    );
  }

  return (
    <>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Role
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Requested By
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Reason
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Requested At
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {pendingDeletions.map((deletion) => (
                <tr key={deletion._id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10 bg-gray-100 rounded-full flex items-center justify-center">
                        <UserIcon className="w-5 h-5 text-gray-600" />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{deletion.fullName}</div>
                        <div className="text-sm text-gray-500">{deletion.username}</div>
                        {deletion.email && (
                          <div className="text-xs text-gray-400">{deletion.email}</div>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getRoleColor(deletion.role)}`}>
                      {formatRoleName(deletion.role)}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {deletion.deletionRequestedBy ? (
                      <div className="text-sm">
                        <div className="text-gray-900">{deletion.deletionRequestedBy.fullName}</div>
                        <div className="text-gray-500 text-xs">{deletion.deletionRequestedBy.username}</div>
                      </div>
                    ) : (
                      <span className="text-gray-400 text-sm">Unknown</span>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900 max-w-xs truncate" title={deletion.deletionReason || 'No reason provided'}>
                      {deletion.deletionReason || 'No reason provided'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center text-sm text-gray-500">
                      <Clock className="w-4 h-4 mr-1" />
                      {formatDistanceToNow(new Date(deletion.deletionRequestedAt), { addSuffix: true })}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    {isSuperAdmin ? (
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleApprove(deletion._id)}
                          disabled={processingId === deletion._id}
                          className="inline-flex items-center px-3 py-1.5 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                          title="Approve deletion"
                        >
                          {processingId === deletion._id ? (
                            <Loader2 className="w-4 h-4 animate-spin" />
                          ) : (
                            <Check className="w-4 h-4" />
                          )}
                          <span className="ml-1">Approve</span>
                        </button>
                        <button
                          onClick={() => handleRejectClick(deletion._id)}
                          disabled={processingId === deletion._id}
                          className="inline-flex items-center px-3 py-1.5 bg-red-600 text-white rounded-md hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                          title="Reject deletion"
                        >
                          <X className="w-4 h-4" />
                          <span className="ml-1">Reject</span>
                        </button>
                      </div>
                    ) : (
                      <span className="text-xs text-gray-500 italic">Pending super admin approval</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Reject Modal */}
      {showRejectModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Reject Deletion Request</h3>
            <p className="text-sm text-gray-600 mb-4">
              Please provide a reason for rejecting this deletion request:
            </p>
            <textarea
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#456C2D] resize-none"
              rows={4}
              placeholder="Enter rejection reason (optional)"
            />
            <div className="flex justify-end gap-3 mt-6">
              <button
                onClick={() => {
                  setShowRejectModal(false);
                  setRejectionReason('');
                  setSelectedUserId(null);
                }}
                disabled={processingId !== null}
                className="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                onClick={handleRejectSubmit}
                disabled={processingId !== null}
                className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 disabled:opacity-50 flex items-center"
              >
                {processingId !== null && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                Reject Request
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default PendingDeletionsTable;

