import React, { useEffect, useMemo, useState } from 'react';
import axios from 'axios';
import apiClient from '../../api/client';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, ReferenceLine } from 'recharts';
import { Thermometer, Droplets, Sun, TestTube, Clock, ChevronLeft, ChevronRight, BarChart3 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

// Types for API
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

interface HistoryPoint {
  timestamp: string; // ISO
  temperature?: number | null;
  humidity?: number | null;
  soilMoisture?: number | null;
  soilPh?: number | null;
  lightIntensity?: number | null;
}

interface Last24hApi {
  success: boolean;
  data?: HistoryPoint[];
  message?: string;
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
      // Attempt to fetch a 24h history from backend
      const resp = await apiClient.get<Last24hApi>('/api/sensors/last24h');
      if (resp.data?.success && Array.isArray(resp.data.data)) {
        const data = resp.data.data
          .filter(p => p && p.timestamp)
          .sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
        setSeries(data);
        const last = data[data.length - 1];
        setLastUpdated(last?.timestamp || null);
        setLoading(false);
        return;
      }
      throw new Error(resp.data?.message || 'No 24h history available');
    } catch (e) {
      // Fallback: build a tiny series based on the latest endpoint so the widget stays functional
      try {
        const latest = await axios.get<LatestApiData>('https://maize-watch.onrender.com/api/sensors/latest');
        if (latest.data?.success && latest.data.data) {
          const l = latest.data.data;
          const nowIso = l.timestamp;
          const fallback: HistoryPoint[] = [];
          // Generate last 2 hours at 10-minute steps as a minimal preview
          const now = nowIso ? new Date(nowIso) : new Date();
          for (let i = 12; i >= 0; i--) {
            const t = new Date(now.getTime() - i * 10 * 60 * 1000);
            fallback.push({
              timestamp: t.toISOString(),
              temperature: l.temperature ?? null,
              humidity: l.humidity ?? null,
              soilMoisture: l.soilMoisture ?? null,
              soilPh: l.soilPh ?? null,
              lightIntensity: l.lightIntensity ?? null,
            });
          }
          setSeries(fallback);
          setLastUpdated(nowIso || null);
          setError('Showing a short preview. 24h endpoint not available.');
        } else {
          setError('Failed to fetch live data');
        }
      } catch (err: any) {
        setError(err.message || 'Failed to fetch data');
      } finally {
        setLoading(false);
      }
    }
  };

  useEffect(() => {
    fetchLast24h();
    const id = setInterval(fetchLast24h, 60_000); // refresh every minute
    return () => clearInterval(id);
  }, []);

  const displayData = useMemo(() => {
    // Determine which day to render (based on latest point)
    const base = series.length ? new Date(series[series.length - 1].timestamp) : new Date();
    const dayStart = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 0, 0, 0, 0);
    const dayEnd = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 23, 59, 59, 999);

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

    return buckets.map((b, idx) => ({ time: b.label, value: filled[idx] }));
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
          {displayData.length ? `${displayData[displayData.length - 1].value}${active.unit}` : '--'}
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
              <YAxis domain={active.domain as any} width={60} tickFormatter={(v) => `${v}${active.unit}`} />
              <Tooltip formatter={(value: any) => [`${value}${active.unit}`, active.label]} labelFormatter={(label) => `Time: ${label}`} />
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
