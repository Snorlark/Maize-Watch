import React, { useState, useEffect } from 'react';
import { AlertTriangle, Clock, LogOut, RefreshCw, X } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

interface SessionExpirationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onExtendSession: () => void;
  onLogout: () => void;
  timeRemaining: number; // in seconds
}

const SessionExpirationModal: React.FC<SessionExpirationModalProps> = ({
  isOpen,
  onClose,
  onExtendSession,
  onLogout,
  timeRemaining
}) => {
  const [countdown, setCountdown] = useState(timeRemaining);
  const { user } = useAuth();

  // Only show for admin or super_admin users
  const shouldShowModal = user?.role === 'admin' || user?.role === 'super_admin';

  useEffect(() => {
    if (!isOpen || !shouldShowModal) return;

    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          onLogout();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [isOpen, shouldShowModal, onLogout]);

  useEffect(() => {
    setCountdown(timeRemaining);
  }, [timeRemaining]);

  const formatTime = (seconds: number): string => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  if (!isOpen || !shouldShowModal) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-md w-full mx-4">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-red-100 rounded-lg">
              <AlertTriangle className="w-6 h-6 text-red-600" />
            </div>
            <div>
              <h2 className="text-xl font-semibold text-[#1E441E]">Session Expiring</h2>
              <p className="text-sm text-[#4A7C59]">Your session will expire soon</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6">
          <div className="text-center mb-6">
            <div className="flex items-center justify-center gap-2 mb-4">
              <Clock className="w-5 h-5 text-[#456C2D]" />
              <span className="text-lg font-medium text-[#356B2C]">
                Time Remaining: {formatTime(countdown)}
              </span>
            </div>
            <p className="text-[#4A7C59] mb-4">
              Your session will expire in <span className="font-semibold">{formatTime(countdown)}</span>. 
              Would you like to extend your session or logout?
            </p>
          </div>

          {/* Progress bar */}
          <div className="w-full bg-gray-200 rounded-full h-2 mb-6">
            <div 
              className="bg-red-500 h-2 rounded-full transition-all duration-1000"
              style={{ 
                width: `${(countdown / timeRemaining) * 100}%`,
                backgroundColor: countdown < 30 ? '#EF4444' : countdown < 60 ? '#F59E0B' : '#10B981'
              }}
            />
          </div>

          {/* Actions */}
          <div className="flex flex-col gap-3">
            <button
              onClick={onExtendSession}
              className="flex items-center justify-center gap-2 w-full px-4 py-3 bg-[#456C2D] text-white rounded-lg hover:bg-[#356B2C] transition-colors font-medium"
            >
              <RefreshCw className="w-5 h-5" />
              Extend Session
            </button>
            
            <button
              onClick={onLogout}
              className="flex items-center justify-center gap-2 w-full px-4 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              <LogOut className="w-5 h-5" />
              Logout Now
            </button>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-gray-50 rounded-b-xl">
          <p className="text-xs text-center text-[#4A7C59]">
            Session will automatically expire if no action is taken
          </p>
        </div>
      </div>
    </div>
  );
};

export default SessionExpirationModal; 