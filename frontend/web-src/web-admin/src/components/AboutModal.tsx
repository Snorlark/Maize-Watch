import React from 'react';
import { X, Leaf, BarChart3, Users, Shield, Zap, Globe } from 'lucide-react';

interface AboutModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const AboutModal: React.FC<AboutModalProps> = ({ isOpen, onClose }) => {
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
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-100 p-6 rounded-t-2xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-green-100 rounded-xl">
                <img 
                  src="/maizewatchlogo.png" 
                  alt="Maize Watch Logo" 
                  className="h-20 w-20"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/32";
                  }}
                />
              </div>
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Maize Watch</h2>
                <p className="text-sm text-gray-500">Empowering Smart Agriculture</p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <X className="w-6 h-6 text-gray-500" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 space-y-8">
          {/* Mission Statement */}
          <div className="text-center">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">Our Mission</h3>
            <p className="text-gray-700 leading-relaxed">
              Maize Watch empowers corn farmers to achieve higher yields and greater 
              profitability through data-driven insights and smart agricultural technology. 
              We provide comprehensive monitoring solutions that transform traditional 
              farming into precision agriculture.
            </p>
          </div>

          {/* Features Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="p-6 bg-green-50 rounded-xl border border-green-100">
              <div className="flex items-center gap-3 mb-3">
                <div className="p-2 bg-green-100 rounded-lg">
                  <BarChart3 className="w-5 h-5 text-green-600" />
                </div>
                <h4 className="font-semibold text-gray-900">Real-time Monitoring</h4>
              </div>
              <p className="text-sm text-gray-600">
                Continuous monitoring of soil moisture, temperature, humidity, pH levels, 
                and light intensity with instant alerts and notifications.
              </p>
            </div>

            <div className="p-6 bg-blue-50 rounded-xl border border-blue-100">
              <div className="flex items-center gap-3 mb-3">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <Leaf className="w-5 h-5 text-blue-600" />
                </div>
                <h4 className="font-semibold text-gray-900">Crop Health Insights</h4>
              </div>
              <p className="text-sm text-gray-600">
                Advanced analytics and visualizations to identify crop health issues, 
                optimize irrigation, and improve overall farm productivity.
              </p>
            </div>

            <div className="p-6 bg-purple-50 rounded-xl border border-purple-100">
              <div className="flex items-center gap-3 mb-3">
                <div className="p-2 bg-purple-100 rounded-lg">
                  <Users className="w-5 h-5 text-purple-600" />
                </div>
                <h4 className="font-semibold text-gray-900">User Management</h4>
              </div>
              <p className="text-sm text-gray-600">
                Comprehensive account management with role-based access control for 
                farmers, administrators, and super administrators.
              </p>
            </div>

            <div className="p-6 bg-orange-50 rounded-xl border border-orange-100">
              <div className="flex items-center gap-3 mb-3">
                <div className="p-2 bg-orange-100 rounded-lg">
                  <Zap className="w-5 h-5 text-orange-600" />
                </div>
                <h4 className="font-semibold text-gray-900">Smart Alerts</h4>
              </div>
              <p className="text-sm text-gray-600">
                Intelligent alert system that notifies users of critical conditions, 
                maintenance requirements, and optimal farming actions.
              </p>
            </div>
          </div>

          {/* Key Benefits */}
          <div className="bg-gray-50 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Key Benefits</h3>
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 bg-green-500 rounded-full mt-2 flex-shrink-0"></div>
                <p className="text-sm text-gray-700">
                  <strong>Increased Yields:</strong> Data-driven insights help optimize growing conditions and resource allocation
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 bg-green-500 rounded-full mt-2 flex-shrink-0"></div>
                <p className="text-sm text-gray-700">
                  <strong>Cost Reduction:</strong> Efficient resource management reduces water, fertilizer, and energy costs
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 bg-green-500 rounded-full mt-2 flex-shrink-0"></div>
                <p className="text-sm text-gray-700">
                  <strong>Risk Mitigation:</strong> Early detection of issues prevents crop damage and financial losses
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 bg-green-500 rounded-full mt-2 flex-shrink-0"></div>
                <p className="text-sm text-gray-700">
                  <strong>Sustainability:</strong> Precision agriculture practices promote environmental conservation
                </p>
              </div>
            </div>
          </div>

          {/* Technology Stack */}
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Technology Stack</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="text-center p-4 bg-white border border-gray-200 rounded-lg">
                <div className="w-8 h-8 bg-blue-100 rounded-lg mx-auto mb-2 flex items-center justify-center">
                  <Globe className="w-4 h-4 text-blue-600" />
                </div>
                <p className="text-xs font-medium text-gray-700">IoT Sensors</p>
              </div>
              <div className="text-center p-4 bg-white border border-gray-200 rounded-lg">
                <div className="w-8 h-8 bg-green-100 rounded-lg mx-auto mb-2 flex items-center justify-center">
                  <BarChart3 className="w-4 h-4 text-green-600" />
                </div>
                <p className="text-xs font-medium text-gray-700">Data Analytics</p>
              </div>
              <div className="text-center p-4 bg-white border border-gray-200 rounded-lg">
                <div className="w-8 h-8 bg-purple-100 rounded-lg mx-auto mb-2 flex items-center justify-center">
                  <Shield className="w-4 h-4 text-purple-600" />
                </div>
                <p className="text-xs font-medium text-gray-700">Cloud Security</p>
              </div>
              <div className="text-center p-4 bg-white border border-gray-200 rounded-lg">
                <div className="w-8 h-8 bg-orange-100 rounded-lg mx-auto mb-2 flex items-center justify-center">
                  <Zap className="w-4 h-4 text-orange-600" />
                </div>
                <p className="text-xs font-medium text-gray-700">Real-time API</p>
              </div>
            </div>
          </div>

          {/* Contact Information */}
          <div className="border-t border-gray-100 pt-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Connect With Us</h3>
            <div className="flex items-center justify-center gap-6">
              <a 
                href="#" 
                className="p-3 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
                title="Instagram"
              >
                <img src="/footer/instagram.png" alt="Instagram" className="w-6 h-6" />
              </a>
              <a 
                href="#" 
                className="p-3 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
                title="GitHub"
              >
                <img src="/footer/github.png" alt="GitHub" className="w-6 h-6" />
              </a>
              <a 
                href="#" 
                className="p-3 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
                title="LinkedIn"
              >
                <img src="/footer/linkedin.png" alt="LinkedIn" className="w-6 h-6" />
              </a>
              <a 
                href="#" 
                className="p-3 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
                title="X (Twitter)"
              >
                <img src="/footer/x.png" alt="X" className="w-5 h-5" />
              </a>
            </div>
            <p className="text-center text-sm text-gray-500 mt-4">
              © 2024 Maize Watch. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AboutModal; 