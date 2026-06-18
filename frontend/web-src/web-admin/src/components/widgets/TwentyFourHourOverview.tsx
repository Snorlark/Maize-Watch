import React, { useEffect, useMemo, useState } from 'react';
import { apiService, sensorService } from '../../api/config';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, ReferenceLine } from 'recharts';
import { Thermometer, Droplets, Sun, TestTube, Clock, ChevronLeft, ChevronRight, BarChart3 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

// Types for chart data
interface HistoryPoint {
  timestamp: string; // ISO
  temperature?: number | null;
  humidity?: number | null;
  soilMoisture?: number | null;
  soilPh?: number | null;
  lightIntensity?: number | null;
}

type VariableKey = 'temperature' | 'soilMoisture' | 'humidity' | 'lightIntensity' | 'soilPh';
interface VariableConfig {
  key: VariableKey;
  label: string;
  unit: string;
  color: string;
  icon: React.ReactNode;
  domain: [number, number] | [number, number | 'dataMax'] | ['dataMin', 'dataMax'];
}

const vars: VariableConfig[] = [
  { key: 'temperature', label: 'Temperature', unit: '°C', color: '#FB923C', icon: <Thermometer className="w-5 h-5 text-orange-600" />, domain: [0, 50] },
  { key: 'soilMoisture', label: 'Soil Moisture', unit: '%', color: '#22C55E', icon: <Droplets className="w-5 h-5 text-emerald-600" />, domain: [0, 100] },
  { key: 'humidity', label: 'Humidity', unit: '%', color: '#3B82F6', icon: <Droplets className="w-5 h-5 text-blue-600" />, domain: [0, 100] },
  { key: 'lightIntensity', label: 'Light Intensity', unit: 'LUX', color: '#F59E0B', icon: <Sun className="w-5 h-5 text-amber-600" />, domain: ['dataMin', 'dataMax'] },
  { key: 'soilPh', label: 'Soil pH', unit: '', color: '#0EA5E9', icon: <TestTube className="w-5 h-5 text-sky-600" />, domain: [0, 14] },
];

const formatDayDate = (d: Date) => d.toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

const TwentyFourHourOverview: React.FC = () => {
  const [activeIdx, setActiveIdx] = useState(0);
  const [series, setSeries] = useState<HistoryPoint[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<string | null>(null);
  const navigate = useNavigate();

  const active = vars[activeIdx];

  const fetchLast24h = async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await sensorService.getThingSpeakHistoricalData(24, 24);
      if (result.success && result.data && result.data.length > 0) {
        const chartData: HistoryPoint[] = result.data.map((reading: any) => {
          let actualTimestamp = reading.created_at || reading.timestamp || new Date().toISOString();
          return {
            timestamp: actualTimestamp,
            temperature: reading.temperature,
            humidity: reading.humidity,
            soilMoisture: reading.soilMoisture,
            soilPh: reading.soilPh,
            lightIntensity: reading.lightIntensity
          };
        });
        const latestReading = chartData[chartData.length - 1];
        const currentTime = new Date();
        const dataTime = new Date(latestReading.timestamp);
        const timeDiffMinutes = (currentTime.getTime() - dataTime.getTime()) / (1000 * 60);
        const timeDiffHours = timeDiffMinutes / 60;

        setSeries(chartData);
        setLastUpdated(latestReading.timestamp);

        if (timeDiffHours > 1) {
          setError(`ThingSpeak data is ${timeDiffHours.toFixed(1)} hours old`);
        } else if (timeDiffMinutes > 30) {
          setError(`ThingSpeak data is ${timeDiffMinutes.toFixed(0)} minutes old`);
        } else {
          setError(null);
        }
      } else {
        throw new Error(result.error || 'No historical data returned from ThingSpeak');
      }
    } catch (err: any) {
      console.error('Error fetching 24h data:', err);
      setError(err.message || 'Unable to load 24-hour sensor data from ThingSpeak');
      setSeries([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLast24h();
    const id = setInterval(fetchLast24h, 60_000);
    return () => clearInterval(id);
  }, []);

  const currentDisplayValue = useMemo(() => {
    for (let i = series.length - 1; i >= 0; i--) {
      const point = series[i];
      if (point.timestamp) {
        const value = (point[active.key] ?? null) as number | null;
        if (typeof value === 'number' && !isNaN(value)) {
          return value;
        }
      }
    }
    return null;
  }, [series, active.key]);

  const displayData = useMemo(() => {
    const base = series.length ? new Date(series[series.length - 1].timestamp) : new Date();
    const dayStart = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 0, 0, 0, 0);

    const hourlyData: { time: string; value: number; hour: number }[] = [];
    const hourLabel = (h: number) => {
      if (h === 0) return '12am';
      if (h === 12) return '12pm';
      if (h < 12) return `${h}am`;
      return `${h - 12}pm`;
    };

    for (let hour = 0; hour < 24; hour++) {
      const hourStart = new Date(dayStart.getTime());
      hourStart.setHours(hour, 0, 0, 0);
      const hourEnd = new Date(dayStart.getTime());
      hourEnd.setHours(hour, 59, 59, 999);
      const hourDataPoints: number[] = [];
      for (const point of series) {
        if (!point.timestamp) continue;
        const pointTime = new Date(point.timestamp);
        if (pointTime >= hourStart && pointTime <= hourEnd) {
          const value = (point[active.key] ?? null) as number | null;
          if (typeof value === 'number' && !isNaN(value)) {
            hourDataPoints.push(value);
          }
        }
      }
      let hourValue: number;
      if (hourDataPoints.length > 0) {
        hourValue = hourDataPoints.reduce((sum, val) => sum + val, 0) / hourDataPoints.length;
        hourValue = parseFloat(hourValue.toFixed(1));
      } else {
        hourValue = 0;
      }
      hourlyData.push({ time: hourLabel(hour), value: hourValue, hour });
    }
    return hourlyData.map(({ time, value }) => ({ time, value }));
  }, [series, active.key]);

  const dateHeader = useMemo(() => {
    if (series.length === 0) return '';
    const last = new Date(series[series.length - 1].timestamp);
    return formatDayDate(last);
  }, [series]);

  return (
    <div className="bg-white rounded-xl shadow-lg p-6 h-full">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          {active.icon}
          <h2 className="font-semibold text-[#1E441E]" style={{ fontSize: 'var(--text-xl)' }}>
            24-hour Overview
          </h2>
        </div>
        <button 
          onClick={() => navigate('/admin-portal-xyz123/datahistory')}
          className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium cursor-pointer"
          style={{ fontSize: 'var(--text-sm)' }}
        >
          <BarChart3 className="w-4 h-4" />
          View History
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>

      <div className="flex items-center justify-between text-[#4A7C59] mb-2" style={{ fontSize: 'var(--text-sm)' }}>
        <div>{dateHeader}</div>
      </div>

      <div className="flex items-baseline gap-3 mb-2">
        <div className="font-bold text-[#356B2C]" style={{ fontSize: '32px' }}>
          {currentDisplayValue !== null ? `${currentDisplayValue.toFixed(1)}${active.unit}` : '--'}
        </div>
        <div className="text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>{active.label}</div>
      </div>

      {loading ? (
        <div className="h-40 flex items-center justify-center text-[#4A7C59]">
          Loading 24-hour data...
        </div>
      ) : (
        <div className="h-48 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={displayData} margin={{ top: 10, right: 20, left: 10, bottom: 30 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey="time"
                angle={-45}
                textAnchor="end"
                height={60}
                interval={0}
                padding={{ left: 10, right: 10 }}
              />
              <YAxis domain={active.domain as any} width={60} tickFormatter={(v) => `${Number(v).toFixed(1)}${active.unit}`} />
              <Tooltip formatter={(value: any) => [`${Number(value).toFixed(1)}${active.unit}`, active.label]} labelFormatter={(label) => `Time: ${label}`} />
              <Legend />
              <Line type="monotone" dataKey="value" name={active.label} stroke={active.color} strokeWidth={2} dot={{ r: 2 }} activeDot={{ r: 4 }} connectNulls />
              {active.key === 'temperature' && (
                <>
                  <ReferenceLine y={20} stroke="#3B82F6" strokeDasharray="3 3" />
                  <ReferenceLine y={30} stroke="#F59E0B" strokeDasharray="3 3" />
                  <ReferenceLine y={35} stroke="#EF4444" strokeDasharray="3 3" />
                </>
              )}
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}

      <div className="flex items-center justify-center gap-3 mt-3">
        <button
          aria-label="Previous metric"
          className="p-2 rounded-lg border hover:bg-[#F5F9F1] cursor-pointer"
          onClick={() => setActiveIdx((i)=> (i - 1 + vars.length) % vars.length)}
        >
          <ChevronLeft className="w-5 h-5 text-[#356B2C]" />
        </button>
        <div className="flex items-center gap-2">
          {vars.map((v, i) => (
            <button
              key={v.key}
              className={`w-2.5 h-2.5 rounded-full cursor-pointer ${i === activeIdx ? 'bg-[#356B2C]' : 'bg-[#B8D4A8]'}`}
              onClick={() => setActiveIdx(i)}
              aria-label={`View ${v.label}`}
              title={v.label}
            />
          ))}
        </div>
        <button
          aria-label="Next metric"
          className="p-2 rounded-lg border hover:bg-[#F5F9F1] cursor-pointer"
          onClick={() => setActiveIdx((i)=> (i + 1) % vars.length)}
        >
          <ChevronRight className="w-5 h-5 text-[#356B2C]" />
        </button>
      </div>

      {/* Last updated and data age info */}
      <div className="flex flex-col items-center gap-1 text-[#4A7C59] mt-3" style={{ fontSize: 'var(--text-sm)' }}>
        <div className="flex items-center gap-2">
          <Clock className="w-4 h-4" />
          <span>Last updated: {lastUpdated ? new Date(lastUpdated).toLocaleString('en-US', {
            year: 'numeric',
            month: '2-digit', 
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            timeZoneName: 'short'
          }) : 'Never'}</span>
        </div>
        {lastUpdated && (() => {
          const now = new Date();
          const dataTime = new Date(lastUpdated);
          const diffMinutes = (now.getTime() - dataTime.getTime()) / (1000 * 60);
          const diffHours = diffMinutes / 60;
          
          if (diffMinutes < 60) {
            return (
              <div className="text-xs text-gray-500">
                Data age: {diffMinutes.toFixed(0)} minutes ago
              </div>
            );
          } else {
            return (
              <div className="text-xs text-red-500">
                Data age: {diffHours.toFixed(1)} hours ago
              </div>
            );
          }
        })()}
      </div>

      {error && !error.includes('hours old') && !error.includes('minutes old') && (
        <div className="mt-3 text-center text-xs text-orange-700 bg-orange-50 rounded px-2 py-1">
          {error}
        </div>
      )}
    </div>
  );
};

export default TwentyFourHourOverview;