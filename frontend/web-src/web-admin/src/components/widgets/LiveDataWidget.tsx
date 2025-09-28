import React, { useEffect, useMemo, useState } from 'react';
import { sensorService } from '../../api/config';
import { Thermometer, Droplets, Sun, TestTube, Activity, ChevronLeft, ChevronRight, RefreshCw, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

// Types for latest sensor API
interface LatestApiData {
  success: boolean;
  data?: {
    timestamp: string;
    temperature: number | null;
    humidity: number | null;
    soilMoisture: number | null;
    soilPh: number | null;
    lightIntensity: number | null;
  };
  message?: string;
}

// Widget variable definition
type VariableKey = 'temperature' | 'soil_moisture' | 'humidity' | 'light_level' | 'soil_ph';
interface VariableConfig {
  key: VariableKey;
  label: string;
  unit: string;
  color: string; // text color
  bg: string;    // bg badge color
  icon: React.ReactNode;
  valueExtractor: (raw: LatestApiData['data']) => number;
}

const LiveDataWidget: React.FC = () => {
  const navigate = useNavigate();
  const [activeIdx, setActiveIdx] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<string | null>(null);
  const [values, setValues] = useState<Record<VariableKey, number>>({
    temperature: 0,
    soil_moisture: 0,
    humidity: 0,
    light_level: 0,
    soil_ph: 0,
  });

  const variables: VariableConfig[] = useMemo(() => ([
    {
      key: 'temperature',
      label: 'Temperature',
      unit: '°C',
      color: 'text-orange-600',
      bg: 'bg-orange-50',
      icon: <Thermometer className="w-6 h-6 text-orange-600" />,
      valueExtractor: (raw) => (raw?.temperature ?? 0),
    },
    {
      key: 'soil_moisture',
      label: 'Soil Moisture',
      unit: '%',
      color: 'text-emerald-600',
      bg: 'bg-emerald-50',
      icon: <Droplets className="w-6 h-6 text-emerald-600" />,
      valueExtractor: (raw) => (raw?.soilMoisture ?? 0),
    },
    {
      key: 'humidity',
      label: 'Humidity',
      unit: '%',
      color: 'text-blue-600',
      bg: 'bg-blue-50',
      icon: <Droplets className="w-6 h-6 text-blue-600" />,
      valueExtractor: (raw) => (raw?.humidity ?? 0),
    },
    {
      key: 'light_level',
      label: 'Light Intensity',
      unit: 'LUX',
      color: 'text-amber-600',
      bg: 'bg-amber-50',
      icon: <Sun className="w-6 h-6 text-amber-600" />,
      valueExtractor: (raw) => (raw?.lightIntensity ?? 0),
    },
    {
      key: 'soil_ph',
      label: 'Soil pH Level',
      unit: '',
      color: 'text-sky-700',
      bg: 'bg-sky-50',
      icon: <TestTube className="w-6 h-6 text-sky-700" />,
      valueExtractor: (raw) => (raw?.soilPh ?? 0),
    },
  ]), []);

  const fetchLatest = async () => {
    try {
      console.log('[LiveDataWidget] Fetching latest sensor data using sensorService...');
      
      // Use the same sensorService as LiveData.tsx (prioritizes test endpoint)
      const result = await sensorService.getLatestSensorData();
      
      console.log('[LiveDataWidget] Sensor service result:', result);

      if (result.success && result.data) {
        const raw = result.data;
        
        const nextValues: Record<VariableKey, number> = {
          temperature: raw.temperature ?? 0,
          humidity: raw.humidity ?? 0,
          soil_moisture: raw.soilMoisture ?? 0,
          soil_ph: raw.soilPh ?? 0,
          light_level: raw.lightIntensity ?? 0,
        };
        
        setValues(nextValues);
        setLastUpdated(raw.timestamp ?? null);
        
        // Show a subtle indicator if using test data
        if (result.message?.includes('test data') || result.message?.includes('Test')) {
          setError('Using test data (Demo mode)');
        } else {
          setError(null);
        }
        
        console.log('[LiveDataWidget] Successfully updated sensor data:', nextValues);
      } else {
        throw new Error(result.error || 'Failed to fetch sensor data');
      }
    } catch (e: any) {
      console.error('[LiveDataWidget] Error fetching sensor data:', e);
      
      // Final fallback to mock data
      const mockValues: Record<VariableKey, number> = {
        temperature: 25.5,
        humidity: 65,
        soil_moisture: 45,
        soil_ph: 6.8,
        light_level: 750,
      };
      
      setValues(mockValues);
      setLastUpdated(new Date().toISOString());
      setError('Using fallback data (All endpoints failed)');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLatest();
    // Use 30-second interval like LiveData.tsx for consistency
    const id = setInterval(fetchLatest, 30000);
    return () => clearInterval(id);
  }, []);

  const onPrev = () => setActiveIdx((idx) => (idx - 1 + variables.length) % variables.length);
  const onNext = () => setActiveIdx((idx) => (idx + 1) % variables.length);

  const active = variables[activeIdx];
  const value = values[active.key];

  // Threshold/badge helpers per metric
  const getBadge = (key: VariableKey, v: number) => {
    switch (key) {
      case 'temperature': {
        // Mirror Dashboard's getTemperatureStatus logic
        if (v < 20) return { text: 'Too Cold', cls: 'bg-blue-100 text-blue-800' };
        if (v > 35) return { text: 'Critical', cls: 'bg-red-100 text-red-800' };
        if (v > 30) return { text: 'Too Hot', cls: 'bg-orange-100 text-orange-800' };
        return { text: 'Normal', cls: 'bg-green-100 text-green-800' };
      }
      case 'soil_moisture': {
        // Use chart thresholds: min 20 optimal start; >80 too wet; >90 critical
        if (v >= 90) return { text: 'Critical', cls: 'bg-red-100 text-red-800' };
        if (v > 80) return { text: 'Too Wet', cls: 'bg-blue-100 text-blue-800' };
        if (v >= 20) return { text: 'Optimal', cls: 'bg-green-100 text-green-800' };
        return { text: 'Too Dry', cls: 'bg-yellow-100 text-yellow-800' };
      }
      case 'humidity': {
        // Use chart thresholds: min 40 optimal start; >80 too humid; >90 critical
        if (v >= 90) return { text: 'Critical', cls: 'bg-red-100 text-red-800' };
        if (v > 80) return { text: 'Too Humid', cls: 'bg-orange-100 text-orange-800' };
        if (v >= 40) return { text: 'Optimal', cls: 'bg-green-100 text-green-800' };
        return { text: 'Too Dry', cls: 'bg-blue-100 text-blue-800' };
      }
      case 'light_level': {
        // Use chart thresholds: min 5000; >10000 too high; >12000 critical
        if (v >= 12000) return { text: 'Critical', cls: 'bg-red-100 text-red-800' };
        if (v > 10000) return { text: 'Too High', cls: 'bg-orange-100 text-orange-800' };
        if (v >= 5000) return { text: 'Optimal', cls: 'bg-green-100 text-green-800' };
        return { text: 'Too Low', cls: 'bg-yellow-100 text-yellow-800' };
      }
      case 'soil_ph': {
        // Use chart thresholds: optimal 5.5 - 7.5; >8.0 critical
        if (v >= 8.0) return { text: 'Critical', cls: 'bg-red-100 text-red-800' };
        if (v > 7.5) return { text: 'Too Alkaline', cls: 'bg-blue-100 text-blue-800' };
        if (v >= 5.5) return { text: 'Optimal', cls: 'bg-green-100 text-green-800' };
        return { text: 'Too Acidic', cls: 'bg-orange-100 text-orange-800' };
      }
    }
  };

  return (
    <div className="bg-white rounded-xl shadow-lg p-6 h-full">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className={`p-2 ${active.bg} rounded-lg`}>
            {active.icon}
          </div>
          <h2 className="font-semibold text-[#1E441E]" style={{ fontSize: 'var(--text-xl)' }}>
            Sensor Data
          </h2>
        </div>
        <button
          onClick={() => navigate('/admin-portal-xyz123/livedata')}
          className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium"
          style={{ fontSize: 'var(--text-sm)' }}
        >
          <Activity className="w-4 h-4" />
          View Live Data
        </button>
      </div>

      {/* Content */}
      {loading ? (
        <div className="flex items-center justify-center py-8 text-[#4A7C59]">
          <RefreshCw className="w-5 h-5 animate-spin mr-2" />
          <span>Loading live data...</span>
        </div>
      ) : error ? (
        <div className="bg-red-50 text-red-700 px-4 py-3 rounded-lg">
          {error}
        </div>
      ) : (
        <div className="text-center">
          <div className="mb-2 inline-flex items-center gap-2">
            <span className={`font-medium ${active.color}`}>{active.label}</span>
          </div>

          <div className="font-bold text-[#356B2C] mb-3" style={{ fontSize: '48px' }}>
            {value}{active.unit}
          </div>

          {/* Status badge derived from thresholds */}
          {(() => { const badge = getBadge(active.key, value); return (
            <div className="mb-4">
              <span className={`inline-block px-3 py-1 rounded-full font-medium ${badge?.cls || ''}`} style={{ fontSize: 'var(--text-xs)' }}>
                {badge?.text || '—'}
              </span>
            </div>
          ); })()}

          <div className="flex items-center justify-center gap-3 mb-4">
            <button
              aria-label="Previous metric"
              onClick={onPrev}
              className="p-2 rounded-lg border hover:bg-[#F5F9F1]"
            >
              <ChevronLeft className="w-5 h-5 text-[#356B2C]" />
            </button>
            <div className="flex items-center gap-2">
              {variables.map((v, i) => (
                <span
                  key={v.key}
                  className={`w-2 h-2 rounded-full ${i === activeIdx ? 'bg-[#356B2C]' : 'bg-[#B8D4A8]'}`}
                  title={v.label}
                />
              ))}
            </div>
            <button
              aria-label="Next metric"
              onClick={onNext}
              className="p-2 rounded-lg border hover:bg-[#F5F9F1]"
            >
              <ChevronRight className="w-5 h-5 text-[#356B2C]" />
            </button>
          </div>

          <div className="flex justify-center items-center gap-2 text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>
            <Clock className="w-4 h-4" />
            Last updated: {lastUpdated ? new Date(lastUpdated).toLocaleString() : 'N/A'}
          </div>
        </div>
      )}
    </div>
  );
};

export default LiveDataWidget;
