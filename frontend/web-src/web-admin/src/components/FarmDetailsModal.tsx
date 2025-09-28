import React from 'react';
import { X, MapPin, Calendar, Sprout, Users, Activity, Thermometer, Droplets, Sun, TestTube } from 'lucide-react';
import { Farm } from '../api/services/farmService';
import { User } from '../api/services/authService';

interface FarmDetailsModalProps {
  farm: Farm;
  assignedUser?: User;
  isOpen: boolean;
  onClose: () => void;
}

const FarmDetailsModal: React.FC<FarmDetailsModalProps> = ({
  farm,
  assignedUser,
  isOpen,
  onClose
}) => {
  // Get growth stage description
  const getGrowthStageDescription = (stage: string) => {
    const stages: Record<string, string> = {
      'VE': 'Emergence',
      'V1': 'First leaf',
      'V2': 'Second leaf',
      'V3': 'Third leaf',
      'V4': 'Fourth leaf',
      'V5': 'Fifth leaf',
      'V6': 'Sixth leaf',
      'V7': 'Seventh leaf',
      'V8': 'Eighth leaf',
      'VT': 'Tasseling',
      'R1': 'Silking',
      'R2': 'Blister',
      'R3': 'Milk',
      'R4': 'Dough',
      'R5': 'Dent',
      'R6': 'Physiological maturity'
    };
    return stages[stage] || stage;
  };

  // Format date
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  // Get sensor reading color based on value ranges
  const getSensorColor = (type: string, value: number) => {
    switch (type) {
      case 'soilMoisture':
        if (value < 30) return 'text-red-600';
        if (value > 70) return 'text-blue-600';
        return 'text-green-600';
      case 'temperature':
        if (value < 15 || value > 35) return 'text-red-600';
        return 'text-green-600';
      case 'humidity':
        if (value < 40 || value > 80) return 'text-orange-600';
        return 'text-green-600';
      case 'soilPh':
        if (value < 6 || value > 7.5) return 'text-orange-600';
        return 'text-green-600';
      default:
        return 'text-gray-600';
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-[#456C2D] text-white p-6 flex items-center justify-between">
          <div>
            <h2 className="text-xl font-bold">{farm.farmName}</h2>
            <p className="text-[#E6F0D3] mt-1">Farm Details and Field Information</p>
          </div>
          <button
            onClick={onClose}
            className="text-white hover:text-[#E6F0D3] transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6 max-h-[calc(90vh-120px)] overflow-y-auto">
          {/* Farm Overview */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            {/* Basic Information */}
            <div className="bg-[#F5F9E8] rounded-lg p-4">
              <h3 className="font-semibold text-[#1E441E] mb-4 flex items-center gap-2">
                <Sprout className="w-5 h-5" />
                Farm Information
              </h3>
              <div className="space-y-3">
                <div className="flex items-start gap-2">
                  <MapPin className="w-4 h-4 text-[#456C2D] mt-0.5" />
                  <div>
                    <div className="text-sm text-[#456C2D]">Location</div>
                    <div className="text-[#1E441E] font-medium">{farm.location}</div>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <Calendar className="w-4 h-4 text-[#456C2D] mt-0.5" />
                  <div>
                    <div className="text-sm text-[#456C2D]">Created</div>
                    <div className="text-[#1E441E] font-medium">{formatDate(farm.createdAt)}</div>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <Activity className="w-4 h-4 text-[#456C2D] mt-0.5" />
                  <div>
                    <div className="text-sm text-[#456C2D]">Last Updated</div>
                    <div className="text-[#1E441E] font-medium">{formatDate(farm.updatedAt)}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Assigned User */}
            <div className="bg-[#F5F9E8] rounded-lg p-4">
              <h3 className="font-semibold text-[#1E441E] mb-4 flex items-center gap-2">
                <Users className="w-5 h-5" />
                Assigned User
              </h3>
              {assignedUser ? (
                <div className="space-y-3">
                  <div>
                    <div className="text-sm text-[#456C2D]">Name</div>
                    <div className="text-[#1E441E] font-medium">{assignedUser.fullName || assignedUser.username}</div>
                  </div>
                  <div>
                    <div className="text-sm text-[#456C2D]">Email</div>
                    <div className="text-[#1E441E] font-medium">{assignedUser.email || 'Not provided'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-[#456C2D]">Contact</div>
                    <div className="text-[#1E441E] font-medium">{assignedUser.contactNumber || 'Not provided'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-[#456C2D]">Role</div>
                    <div className="text-[#1E441E] font-medium capitalize">{assignedUser.role}</div>
                  </div>
                </div>
              ) : (
                <div className="text-[#456C2D]">User information not available</div>
              )}
            </div>
          </div>

          {/* Fields */}
          <div>
            <h3 className="font-semibold text-[#1E441E] mb-4 flex items-center gap-2">
              <Sprout className="w-5 h-5" />
              Fields ({(farm.fields || []).length})
            </h3>
            
            <div className="space-y-6">
              {(farm.fields || []).map((field) => (
                <div key={field._id} className="border border-[#B8D4A8] rounded-lg p-4">
                  {/* Field Header */}
                  <div className="flex items-center justify-between mb-4">
                    <h4 className="font-medium text-[#1E441E] text-lg">{field.fieldName}</h4>
                    <span className="px-2 py-1 bg-[#E8F5E8] text-[#456C2D] rounded-full text-sm">
                      {(field.sensors || []).length} Sensor{(field.sensors || []).length !== 1 ? 's' : ''}
                    </span>
                  </div>

                  {/* Field Info */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div className="flex items-center gap-2">
                      <Calendar className="w-4 h-4 text-[#456C2D]" />
                      <div>
                        <span className="text-sm text-[#456C2D]">Planted: </span>
                        <span className="text-[#1E441E] font-medium">{formatDate(field.plantingDate)}</span>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Sprout className="w-4 h-4 text-[#456C2D]" />
                      <div>
                        <span className="text-sm text-[#456C2D]">Stage: </span>
                        <span className="text-[#1E441E] font-medium">
                          {field.growthStage} - {getGrowthStageDescription(field.growthStage)}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Sensors */}
                  {(field.sensors || []).length > 0 && (
                    <div>
                      <h5 className="font-medium text-[#1E441E] mb-3">Sensors</h5>
                      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                        {(field.sensors || []).map((sensor) => (
                          <div key={sensor._id} className="bg-[#F8F9FA] rounded-lg p-4">
                            <div className="flex items-center justify-between mb-3">
                              <h6 className="font-medium text-[#1E441E]">{sensor.sensorName}</h6>
                              <span className="text-xs text-[#456C2D] bg-[#E6F0D3] px-2 py-1 rounded">
                                ID: {sensor.deviceID}
                              </span>
                            </div>
                            
                            <div className="text-sm text-[#456C2D] mb-3">{sensor.description}</div>
                            
                            <div className="text-sm text-[#456C2D] mb-3">
                              <strong>Soil Type:</strong> {sensor.soilType}
                            </div>

                            {/* Sensor Readings */}
                            <div className="grid grid-cols-2 gap-3">
                              <div className="flex items-center gap-2">
                                <Droplets className="w-4 h-4 text-blue-500" />
                                <div>
                                  <div className="text-xs text-[#456C2D]">Soil Moisture</div>
                                  <div className={`font-medium ${getSensorColor('soilMoisture', sensor.readings.soilMoisture)}`}>
                                    {sensor.readings.soilMoisture}%
                                  </div>
                                </div>
                              </div>
                              
                              <div className="flex items-center gap-2">
                                <Thermometer className="w-4 h-4 text-red-500" />
                                <div>
                                  <div className="text-xs text-[#456C2D]">Temperature</div>
                                  <div className={`font-medium ${getSensorColor('temperature', sensor.readings.temperature)}`}>
                                    {sensor.readings.temperature}°C
                                  </div>
                                </div>
                              </div>
                              
                              <div className="flex items-center gap-2">
                                <Droplets className="w-4 h-4 text-cyan-500" />
                                <div>
                                  <div className="text-xs text-[#456C2D]">Humidity</div>
                                  <div className={`font-medium ${getSensorColor('humidity', sensor.readings.humidity)}`}>
                                    {sensor.readings.humidity}%
                                  </div>
                                </div>
                              </div>
                              
                              <div className="flex items-center gap-2">
                                <Sun className="w-4 h-4 text-yellow-500" />
                                <div>
                                  <div className="text-xs text-[#456C2D]">Light</div>
                                  <div className="font-medium text-[#1E441E]">
                                    {sensor.readings.lightIntensity.toLocaleString()} lux
                                  </div>
                                </div>
                              </div>
                              
                              <div className="flex items-center gap-2 col-span-2">
                                <TestTube className="w-4 h-4 text-purple-500" />
                                <div>
                                  <div className="text-xs text-[#456C2D]">Soil pH</div>
                                  <div className={`font-medium ${getSensorColor('soilPh', sensor.readings.soilPh)}`}>
                                    {sensor.readings.soilPh}
                                  </div>
                                </div>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-[#F5F9E8] px-6 py-4 flex justify-end border-t border-[#E6F0D3]">
          <button
            onClick={onClose}
            className="px-6 py-2 bg-[#456C2D] text-white rounded-lg hover:bg-[#5A7A3A] transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

export default FarmDetailsModal;
