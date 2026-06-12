import React from 'react';
import { X, WifiOff, AlertTriangle, RefreshCw } from 'lucide-react';

interface ErrorModalProps {
  isOpen: boolean;
  onClose: () => void;
  onRetry: () => void;
  error: {
    type: 'network' | 'backend' | 'auth' | 'general';
    message: string;
    details?: string;
  };
}

const ErrorModal: React.FC<ErrorModalProps> = ({ isOpen, onClose, onRetry, error }) => {
  if (!isOpen) return null;

  const getErrorIcon = () => {
    switch (error.type) {
      case 'network':
        return <WifiOff className="w-12 h-12 text-red-500" />;
      case 'backend':
        return <AlertTriangle className="w-12 h-12 text-orange-500" />;
      case 'auth':
        return <AlertTriangle className="w-12 h-12 text-yellow-500" />;
      default:
        return <AlertTriangle className="w-12 h-12 text-red-500" />;
    }
  };

  const getErrorTitle = () => {
    switch (error.type) {
      case 'network':
        return 'Connection Error';
      case 'backend':
        return 'Server Error';
      case 'auth':
        return 'Authentication Error';
      default:
        return 'Error';
    }
  };

  const getErrorDescription = () => {
    switch (error.type) {
      case 'network':
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      case 'backend':
        return 'The server is experiencing issues. Please try again in a few moments.';
      case 'auth':
        return 'Your session has expired. Please log in again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-xl max-w-md w-full p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-[#1E441E]">{getErrorTitle()}</h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        
        <div className="text-center mb-6">
          {getErrorIcon()}
          <p className="text-sm text-gray-600 mt-3">{getErrorDescription()}</p>
          {error.details && (
            <p className="text-xs text-gray-500 mt-2 font-mono bg-gray-100 p-2 rounded">
              {error.details}
            </p>
          )}
        </div>
        
        <div className="flex gap-3">
          <button
            onClick={onRetry}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-[#456C2D] text-white rounded-lg hover:bg-[#5A7A3A] transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            Retry
          </button>
          <button
            onClick={onClose}
            className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

export default ErrorModal; 