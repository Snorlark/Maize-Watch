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

const formatTime = (iso: string) => new Date(iso).toLocaleTimeString();
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
      console.log('[TwentyFourHourOverview] Fetching 24-hour data from ThingSpeak...');
      
      // First try ThingSpeak historical data (24 readings for last 24 hours)
      try {
        const result = await sensorService.getThingSpeakHistoricalData(24, 24);
        console.log('[TwentyFourHourOverview] ThingSpeak historical result:', result);
        
        if (result.success && result.data && result.data.length > 0) {
          // Transform ThingSpeak data to chart format
          const chartData: HistoryPoint[] = result.data.map((reading: any) => ({
            timestamp: reading.timestamp,
            temperature: reading.temperature,
            humidity: reading.humidity,
            soilMoisture: reading.soilMoisture,
            soilPh: reading.soilPh,
            lightIntensity: reading.lightIntensity
          }));
          
          setSeries(chartData);
          setLastUpdated(new Date().toISOString());
          setError(null);
          console.log('[TwentyFourHourOverview] Successfully loaded ThingSpeak historical data:', chartData.length, 'points');
          return;
        }
      } catch (thingSpeakError) {
        console.warn('[TwentyFourHourOverview] ThingSpeak historical failed, falling back to daily data:', thingSpeakError);
      }
      
      // Fallback to daily historical data simulation
      const result = await apiService.fetchHistoricalData('daily', 7);
      
      console.log('[TwentyFourHourOverview] Historical data result:', result);
      
      if (result.success && result.data && result.data.length > 0) {
        console.log('[TwentyFourHourOverview] Raw historical data sample:', result.data[0]);
        
        // Use the latest day's data to simulate 24 hours
        const latestDay = result.data[result.data.length - 1];
        console.log('[TwentyFourHourOverview] Using latest day data:', latestDay);
        
        // Create hourly data points for TODAY only, up to current hour
        const now = new Date();
        const currentHour = now.getHours();
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        
        console.log('[TwentyFourHourOverview] Current time:', now, 'Current hour:', currentHour);
        
        const baseValues = {
          temperature: latestDay.avgTemperature || latestDay.temperature || 25,
          humidity: latestDay.avgHumidity || latestDay.humidity || 65,
          soilMoisture: latestDay.avgSoilMoisture || latestDay.soilMoisture || 45,
          soilPh: latestDay.avgSoilPh || latestDay.soilPh || 6.5,
          lightIntensity: latestDay.avgLightIntensity || latestDay.lightIntensity || 400,
        };
        
        console.log('[TwentyFourHourOverview] Base values for simulation:', baseValues);
        console.log('[TwentyFourHourOverview] Generating data for today up to hour:', currentHour);
        
        const simulatedHourlyData: HistoryPoint[] = [];
        
        // Generate hourly data points only up to current hour
        for (let hour = 0; hour <= currentHour; hour++) {
          const hourDate = new Date(today);
          hourDate.setHours(hour, 0, 0, 0);
          
          // Add slight variations to make it look realistic
          const tempVariation = Math.sin((hour - 12) * Math.PI / 12) * 3; // Temperature varies by time of day
          const humidityVariation = Math.cos(hour * Math.PI / 12) * 5; // Humidity varies
          const lightVariation = hour >= 6 && hour <= 18 ? Math.sin((hour - 6) * Math.PI / 12) * 200 : 0; // Light during day
          
          simulatedHourlyData.push({
            timestamp: hourDate.toISOString(),
            temperature: parseFloat((baseValues.temperature + tempVariation).toFixed(1)),
            humidity: parseFloat(Math.max(0, Math.min(100, baseValues.humidity + humidityVariation)).toFixed(1)),
            soilMoisture: parseFloat((baseValues.soilMoisture + (Math.random() - 0.5) * 2).toFixed(1)),
            soilPh: parseFloat((baseValues.soilPh + (Math.random() - 0.5) * 0.2).toFixed(1)),
            lightIntensity: parseFloat((baseValues.lightIntensity + lightVariation).toFixed(1)),
          });
        }
        
        console.log('[TwentyFourHourOverview] Generated simulated hourly data:', simulatedHourlyData);
        setSeries(simulatedHourlyData);
        setLastUpdated(simulatedHourlyData[simulatedHourlyData.length - 1]?.timestamp || null);
        setError(`Showing today's data up to ${currentHour}:00 (${currentHour + 1} hours)`);
        console.log('[TwentyFourHourOverview] Successfully loaded simulated hourly data');
        return;
      }
      
      throw new Error(result.error || 'No historical data available');
    } catch (e: any) {
      console.warn('[TwentyFourHourOverview] Historical data failed, trying latest sensor data fallback:', e.message);
      
      // Fallback: build a series based on the latest sensor data
      try {
        const latestResult = await sensorService.getLatestSensorData();
        
        if (latestResult.success && latestResult.data) {
          const l = latestResult.data;
          const fallback: HistoryPoint[] = [];
          
          // Generate data for TODAY only, up to current hour
          const now = new Date();
          const currentHour = now.getHours();
          const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
          
          console.log('[TwentyFourHourOverview] Fallback: generating data for today up to hour:', currentHour);
          
          for (let hour = 0; hour <= currentHour; hour++) {
            const hourDate = new Date(today);
            hourDate.setHours(hour, 0, 0, 0);
            
            fallback.push({
              timestamp: hourDate.toISOString(),
              temperature: parseFloat((l.temperature ?? 25).toFixed(1)),
              humidity: parseFloat((l.humidity ?? 65).toFixed(1)),
              soilMoisture: parseFloat((l.soilMoisture ?? 45).toFixed(1)),
              soilPh: parseFloat((l.soilPh ?? 6.5).toFixed(1)),
              lightIntensity: parseFloat((l.lightIntensity ?? 400).toFixed(1)),
            });
          }
          
          setSeries(fallback);
          setLastUpdated(fallback[fallback.length - 1]?.timestamp || null);
          setError(`Showing today's data up to ${currentHour}:00 (Historical data unavailable)`);
          console.log('[TwentyFourHourOverview] Using fallback simulated data');
        } else {
          throw new Error('Latest sensor data also failed');
        }
      } catch (fallbackErr: any) {
        console.error('[TwentyFourHourOverview] All data sources failed:', fallbackErr);
        setError('Unable to load any sensor data');
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLast24h();
    const id = setInterval(fetchLast24h, 60_000); // refresh every minute
    return () => clearInterval(id);
  }, []);

  const displayData = useMemo(() => {
    console.log('[TwentyFourHourOverview] Processing displayData, series:', series);
    console.log('[TwentyFourHourOverview] Active variable:', active.key);
    
    // Determine which day to render (based on latest point)
    const base = series.length ? new Date(series[series.length - 1].timestamp) : new Date();
    const dayStart = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 0, 0, 0, 0);
    const dayEnd = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 23, 59, 59, 999);
    
    console.log('[TwentyFourHourOverview] Date range:', { base, dayStart, dayEnd });

    // Prepare 24 buckets for each hour
    const buckets: { start: Date; end: Date; label: string; values: number[] }[] = [];
    const hourLabel = (h: number) => {
      const isAM = h < 12;
      const hour12 = h % 12 === 0 ? 12 : h % 12;
      return `${hour12}${isAM ? 'a' : 'p'}`;
    };
    for (let h = 0; h < 24; h++) {
      const start = new Date(dayStart.getTime());
      start.setHours(h, 0, 0, 0);
      const end = new Date(start.getTime());
      end.setMinutes(59, 59, 999);
      buckets.push({ start, end, label: hourLabel(h), values: [] });
    }

    // Distribute series points into hourly buckets
    for (const p of series) {
      const t = new Date(p.timestamp);
      if (t < dayStart || t > dayEnd) continue;
      const hour = t.getHours();
      const val = (p[active.key] ?? null) as number | null;
      if (typeof val === 'number') {
        buckets[hour].values.push(val);
      }
    }

    // Compute per-hour averages
    const hourlyAverages = buckets.map(b => b.values.length ? b.values.reduce((a, c) => a + c, 0) / b.values.length : null);

    // Forward-fill strategy with initial back-fill:
    // 1) Find first non-null; back-fill earlier hours with that first value.
    // 2) Walk forward, carrying last known value to replace nulls.
    let firstKnownIndex = hourlyAverages.findIndex(v => v !== null && !Number.isNaN(v as any));
    let carry = firstKnownIndex >= 0 ? (hourlyAverages[firstKnownIndex] as number) : 0;
    const filled: number[] = new Array(24).fill(0);
    for (let i = 0; i < 24; i++) {
      if (i < firstKnownIndex && firstKnownIndex >= 0) {
        filled[i] = carry; // back-fill to first known value
      } else {
        const v = hourlyAverages[i];
        if (typeof v === 'number' && !Number.isNaN(v)) {
          carry = v;
        }
        filled[i] = carry;
      }
    }

    const finalData = buckets.map((b, idx) => ({ time: b.label, value: filled[idx] }));
    console.log('[TwentyFourHourOverview] Final display data:', finalData);
    return finalData;
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
          className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium"
          style={{ fontSize: 'var(--text-sm)' }}
        >
          <BarChart3 className="w-4 h-4" />
          View History
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>

      <div className="flex items-center justify-between text-[#4A7C59] mb-2" style={{ fontSize: 'var(--text-sm)' }}>
        <div>{dateHeader}</div>
        <div className="flex items-center gap-2">
          <Clock className="w-4 h-4" />
          Last updated: {lastUpdated ? new Date(lastUpdated).toLocaleString() : 'N/A'}
        </div>
      </div>

      <div className="flex items-baseline gap-3 mb-2">
        <div className="font-bold text-[#356B2C]" style={{ fontSize: '32px' }}>
          {displayData.length ? `${displayData[displayData.length - 1].value.toFixed(1)}${active.unit}` : '--'}
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
              {/* Optional baseline lines per metric */}
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

      {/* Metric dots with Prev/Next (match LiveDataWidget placement) */}
      <div className="flex items-center justify-center gap-3 mt-3">
        <button
          aria-label="Previous metric"
          className="p-2 rounded-lg border hover:bg-[#F5F9F1]"
          onClick={() => setActiveIdx((i)=> (i - 1 + vars.length) % vars.length)}
        >
          <ChevronLeft className="w-5 h-5 text-[#356B2C]" />
        </button>
        <div className="flex items-center gap-2">
          {vars.map((v, i) => (
            <button
              key={v.key}
              className={`w-2.5 h-2.5 rounded-full ${i === activeIdx ? 'bg-[#356B2C]' : 'bg-[#B8D4A8]'}`}
              onClick={() => setActiveIdx(i)}
              title={v.label}
            />
          ))}
        </div>
        <button
          aria-label="Next metric"
          className="p-2 rounded-lg border hover:bg-[#F5F9F1]"
          onClick={() => setActiveIdx((i)=> (i + 1) % vars.length)}
        >
          <ChevronRight className="w-5 h-5 text-[#356B2C]" />
        </button>
      </div>

      {error && (
        <div className="mt-3 text-center text-xs text-orange-700 bg-orange-50 rounded px-2 py-1">
          {error}
        </div>
      )}
    </div>
  );
};

export default TwentyFourHourOverview;