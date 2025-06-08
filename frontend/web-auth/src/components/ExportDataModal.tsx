// components/ExportDataModal.tsx
import React, { useState, useEffect } from 'react';
import axios, { AxiosError } from 'axios';

interface ExportDataModalProps {
    isOpen: boolean;
    onClose: () => void;
    currentOverview?: string; // Current time period from the main dashboard
}

interface DataSummary {
    totalRecords: number;
    dateRange: {
        startDate: string;
        endDate: string;
    };
    timePeriod: string;
    statistics: {
        avgTemperature: number;
        avgHumidity: number;
        avgSoilMoisture: number;
        avgSoilPH: number;
        avgLightIntensity: number;
        minTimestamp: string;
        maxTimestamp: string;
    } | null;
}

const ExportDataModal: React.FC<ExportDataModalProps> = ({
    isOpen,
    onClose,
    currentOverview = 'days'
}) => {
    const [exportType, setExportType] = useState<'predefined' | 'custom'>('predefined');
    const [timeFrame, setTimeFrame] = useState<string>('current');
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');
    const [format, setFormat] = useState<'csv' | 'pdf' | 'svg'>('csv');
    const [selectedFields, setSelectedFields] = useState<string[]>([
        'timestamp', 'temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity'
    ]);
    const [isLoading, setIsLoading] = useState(false);
    const [summary, setSummary] = useState<DataSummary | null>(null);
    const [showPreview, setShowPreview] = useState(false);

    const availableFields = [
        { key: 'timestamp', label: 'Timestamp' },
        { key: 'field_id', label: 'Field ID' },
        { key: 'temperature', label: 'Temperature (°C)' },
        { key: 'humidity', label: 'Humidity (%)' },
        { key: 'soil_moisture', label: 'Soil Moisture' },
        { key: 'soil_ph', label: 'Soil pH' },
        { key: 'light_intensity', label: 'Light Intensity' }
    ];

    // Helper function to safely extract error message
    const getErrorMessage = (error: unknown): string => {
        if (axios.isAxiosError(error)) {
            return error.response?.data?.message || error.message || 'An error occurred';
        }
        if (error instanceof Error) {
            return error.message;
        }
        return 'An unknown error occurred';
    };

    // Set timeFrame to current overview when modal opens
    useEffect(() => {
        if (isOpen) {
            setTimeFrame('current');
            setExportType('predefined');
        }
    }, [isOpen, currentOverview]);

    // Function to get date range based on predefined time frame
    const getDateRangeForTimeFrame = (frame: string): { startDate: string; endDate: string } => {
        const now = new Date();
        const endDate = now.toISOString();
        let startDate: string;

        switch (frame) {
            case 'current':
            case 'days':
                // Last 7 days (handles both 'current' and 'days')
                const daysAgo = new Date(now);
                daysAgo.setDate(now.getDate() - 7);
                startDate = daysAgo.toISOString();
                break;

            case 'weeks':
                // Last 4 weeks
                const weeksAgo = new Date(now);
                weeksAgo.setDate(now.getDate() - 28);
                startDate = weeksAgo.toISOString();
                break;

            case 'months':
                // Last 12 months
                const monthsAgo = new Date(now);
                monthsAgo.setMonth(now.getMonth() - 12);
                startDate = monthsAgo.toISOString();
                break;

            default:
                // Default to last 7 days for any unrecognized frame
                const defaultAgo = new Date(now);
                defaultAgo.setDate(now.getDate() - 7);
                startDate = defaultAgo.toISOString();
                break;
        }

        return { startDate, endDate };
    };

    // Function to get time period based on frame
    const getTimePeriodForFrame = (frame: string): string => {
        switch (frame) {
            case 'current':
                return getTimePeriodForFrame(currentOverview);
            case 'days':
                return 'days';
            case 'weeks':
                return 'weeks';
            case 'months':
                return 'months';
            default:
                return 'raw'; // Default to raw sensor data
        }
    };

    const handleFieldToggle = (fieldKey: string) => {
        setSelectedFields(prev =>
            prev.includes(fieldKey)
                ? prev.filter(f => f !== fieldKey)
                : [...prev, fieldKey]
        );
    };

    const fetchPreview = async () => {
        let dateRange;
        let timePeriod;

        if (exportType === 'predefined') {
            dateRange = getDateRangeForTimeFrame(timeFrame);
            timePeriod = getTimePeriodForFrame(timeFrame);
        } else {
            if (!startDate || !endDate) {
                alert('Please select both start and end dates');
                return;
            }
            dateRange = {
                startDate: new Date(startDate).toISOString(),
                endDate: new Date(endDate).toISOString()
            };
            timePeriod = 'raw'; // Custom ranges use raw data
        }

        setIsLoading(true);
        try {
            const response = await axios.get('/api/export/summary', {
                params: {
                    startDate: dateRange.startDate,
                    endDate: dateRange.endDate,
                    timePeriod
                }
            });

            if (response.data.success) {
                setSummary(response.data.summary);
                setShowPreview(true);
            } else {
                alert('Error fetching preview: ' + response.data.message);
            }
        } catch (error) {
            console.error('Preview error:', error);
            const errorMessage = getErrorMessage(error);
            alert('Error fetching preview: ' + errorMessage);
        } finally {
            setIsLoading(false);
        }
    };

    const handleExport = async () => {
        let dateRange;
        let timePeriod;

        if (exportType === 'predefined') {
            dateRange = getDateRangeForTimeFrame(timeFrame);
            timePeriod = getTimePeriodForFrame(timeFrame);
        } else {
            if (!startDate || !endDate) {
                alert('Please select both start and end dates');
                return;
            }
            dateRange = {
                startDate: new Date(startDate).toISOString(),
                endDate: new Date(endDate).toISOString()
            };
            timePeriod = 'raw'; // Custom ranges use raw data
        }

        if (selectedFields.length === 0) {
            alert('Please select at least one field to export');
            return;
        }

        setIsLoading(true);
        try {
            const params = {
                startDate: dateRange.startDate,
                endDate: dateRange.endDate,
                format,
                fields: selectedFields.join(','),
                timePeriod // Include timePeriod parameter
            };

            const response = await axios.get('/api/export', {
                params,
                responseType: 'blob'
            });

            const mimeTypes = {
                csv: 'text/csv',
                pdf: 'application/pdf',
                svg: 'image/svg+xml'
            };

            const blob = new Blob([response.data], { type: mimeTypes[format] });
            const url = window.URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `sensor_data_${timePeriod}_${dateRange.startDate.split('T')[0]}_to_${dateRange.endDate.split('T')[0]}.${format}`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            window.URL.revokeObjectURL(url);

            alert('Export completed successfully!');
            onClose();
        } catch (error) {
            console.error('Export error:', error);
            const errorMessage = getErrorMessage(error);
            alert('Export failed: ' + errorMessage);
        } finally {
            setIsLoading(false);
        }
    };

    const resetForm = () => {
        setExportType('predefined');
        setTimeFrame('current');
        setStartDate('');
        setEndDate('');
        setFormat('csv');
        setSelectedFields(['timestamp', 'temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity']);
        setSummary(null);
        setShowPreview(false);
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
                <div className="flex justify-between items-center mb-4">
                    <h2 className="text-2xl font-bold text-[#356B2C]">Export Sensor Data</h2>
                    <button
                        onClick={() => { onClose(); resetForm(); }}
                        className="text-gray-500 hover:text-gray-700 text-2xl"
                    >
                        ×
                    </button>
                </div>

                {/* Export Type Selection */}
                <div className="mb-6">
                    <h3 className="text-lg font-semibold mb-3 text-[#356B2C]">Export Type</h3>
                    <div className="flex gap-2">
                        <button
                            onClick={() => setExportType('predefined')}
                            className={`px-4 py-2 rounded-md text-sm flex-1 ${exportType === 'predefined'
                                    ? 'bg-[#79A842] text-white'
                                    : 'bg-gray-100 text-[#356B2C] hover:bg-gray-200'
                                }`}
                        >
                            Predefined Period
                        </button>
                        <button
                            onClick={() => setExportType('custom')}
                            className={`px-4 py-2 rounded-md text-sm flex-1 ${exportType === 'custom'
                                    ? 'bg-[#79A842] text-white'
                                    : 'bg-gray-100 text-[#356B2C] hover:bg-gray-200'
                                }`}
                        >
                            Custom Range
                        </button>
                    </div>
                </div>

                {/* Date Range Selection */}
                {exportType === 'predefined' ? (
                    <div className="mb-6">
                        <h3 className="text-lg font-semibold mb-3 text-[#356B2C]">Time Frame</h3>
                        <div className="grid grid-cols-2 gap-2">
                            {[
                                { value: 'days', label: 'Days (Raw Data)' },
                                { value: 'weeks', label: 'Weeks (Aggregated)' },
                                { value: 'months', label: 'Months (Aggregated)' }
                            ].map((option) => (
                                <button
                                    key={option.value}
                                    onClick={() => setTimeFrame(option.value)}
                                    className={`px-3 py-2 rounded-md text-sm ${timeFrame === option.value
                                            ? 'bg-[#79A842] text-white'
                                            : 'bg-gray-100 text-[#356B2C] hover:bg-gray-200'
                                        }`}
                                >
                                    {option.label}
                                </button>
                            ))}
                        </div>
                        <div className="mt-2 p-2 bg-blue-50 rounded-md border border-blue-200">
                            <p className="text-sm text-blue-800">
                                <strong>Note:</strong> Raw data shows individual sensor readings. Aggregated data shows averages over time periods.
                            </p>
                        </div>
                    </div>
                ) : (
                    <div className="mb-6">
                        <h3 className="text-lg font-semibold mb-3 text-[#356B2C]">Select Date Range</h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-medium mb-1 text-[#356B2C]">Start Date</label>
                                <input
                                    type="datetime-local"
                                    value={startDate}
                                    onChange={(e) => setStartDate(e.target.value)}
                                    className="w-full p-2 border border-[#356B2C] rounded-md"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1 text-[#356B2C]">End Date</label>
                                <input
                                    type="datetime-local"
                                    value={endDate}
                                    onChange={(e) => setEndDate(e.target.value)}
                                    className="w-full p-2 border border-[#356B2C] rounded-md"
                                />
                            </div>
                        </div>
                        <div className="mt-2 p-2 bg-yellow-50 rounded-md border border-yellow-200">
                            <p className="text-sm text-yellow-800">
                                <strong>Note:</strong> Custom date ranges will export raw sensor data.
                            </p>
                        </div>
                    </div>
                )}

                {/* Preview Button */}
                <div className="mb-6">
                    <button
                        onClick={fetchPreview}
                        disabled={isLoading || (exportType === 'custom' && (!startDate || !endDate))}
                        className="px-4 py-2 bg-[#356B2C] text-white rounded-md hover:bg-[#2a5823] disabled:bg-gray-300 disabled:cursor-not-allowed"
                    >
                        {isLoading ? 'Loading...' : 'Preview Data'}
                    </button>
                </div>

                {/* Data Preview */}
                {showPreview && summary && (
                    <div className="mb-6 p-4 bg-gray-50 rounded-md border border-[#356B2C]">
                        <h3 className="text-lg font-semibold mb-2 text-[#356B2C]">Data Preview</h3>
                        <p><strong>Total Records:</strong> {summary.totalRecords.toLocaleString()}</p>
                        <p><strong>Data Type:</strong> {summary.timePeriod === 'raw' ? 'Raw Sensor Readings' : `${summary.timePeriod.charAt(0).toUpperCase() + summary.timePeriod.slice(1)} Averages`}</p>
                        <p><strong>Date Range:</strong> {new Date(summary.dateRange.startDate).toLocaleString()} - {new Date(summary.dateRange.endDate).toLocaleString()}</p>
                        {summary.statistics ? (
                            <div className="mt-2 grid grid-cols-2 gap-2 text-sm">
                                <p>Avg Temperature: {summary.statistics.avgTemperature ? summary.statistics.avgTemperature.toFixed(1) + '°C' : 'N/A'}</p>
                                <p>Avg Humidity: {summary.statistics.avgHumidity ? summary.statistics.avgHumidity.toFixed(1) + '%' : 'N/A'}</p>
                                <p>Avg Soil Moisture: {summary.statistics.avgSoilMoisture ? summary.statistics.avgSoilMoisture.toFixed(0) : 'N/A'}</p>
                                <p>Avg Soil pH: {summary.statistics.avgSoilPH ? summary.statistics.avgSoilPH.toFixed(1) : 'N/A'}</p>
                                <p>Avg Light Intensity: {summary.statistics.avgLightIntensity ? summary.statistics.avgLightIntensity.toFixed(0) : 'N/A'}</p>
                            </div>
                        ) : (
                            <p className="text-sm text-gray-600 mt-2">No statistical data available for this range.</p>
                        )}
                    </div>
                )}

                {/* Field Selection */}
                <div className="mb-6">
                    <h3 className="text-lg font-semibold mb-3 text-[#356B2C]">Select Fields to Export</h3>
                    <div className="grid grid-cols-2 gap-2">
                        {availableFields.map(field => (
                            <label key={field.key} className="flex items-center text-[#356B2C]">
                                <input
                                    type="checkbox"
                                    checked={selectedFields.includes(field.key)}
                                    onChange={() => handleFieldToggle(field.key)}
                                    className="mr-2 accent-[#79A842]"
                                />
                                {field.label}
                            </label>
                        ))}
                    </div>
                </div>

                {/* Format Selection */}
                <div className="mb-6">
                    <h3 className="text-lg font-semibold mb-3 text-[#356B2C]">Export Format</h3>
                    <div className="grid grid-cols-3 gap-4">
                        <label className="flex items-center text-[#356B2C]">
                            <input
                                type="radio"
                                value="csv"
                                checked={format === 'csv'}
                                onChange={(e) => setFormat(e.target.value as 'csv')}
                                className="mr-2 accent-[#79A842]"
                            />
                            <div>
                                <div className="font-medium">CSV</div>
                                <div className="text-sm text-gray-500">Excel compatible spreadsheet</div>
                            </div>
                        </label>
                        <label className="flex items-center text-[#356B2C]">
                            <input
                                type="radio"
                                value="pdf"
                                checked={format === 'pdf'}
                                onChange={(e) => setFormat(e.target.value as 'pdf')}
                                className="mr-2 accent-[#79A842]"
                            />
                            <div>
                                <div className="font-medium">PDF Report</div>
                                <div className="text-sm text-gray-500">Charts, stats & data tables</div>
                            </div>
                        </label>
                        <label className="flex items-center text-[#356B2C]">
                            <input
                                type="radio"
                                value="svg"
                                checked={format === 'svg'}
                                onChange={(e) => setFormat(e.target.value as 'svg')}
                                className="mr-2 accent-[#79A842]"
                            />
                            <div>
                                <div className="font-medium">SVG Dashboard</div>
                                <div className="text-sm text-gray-500">Scalable vector graphics</div>
                            </div>
                        </label>
                    </div>

                    {(format === 'pdf' || format === 'svg') && (
                        <div className="mt-3 p-3 bg-[#79A842] bg-opacity-10 rounded-md border border-[#79A842]">
                            <p className="text-sm text-[#356B2C]">
                                <strong>Note:</strong> {format.toUpperCase()} format includes automatically generated charts and statistics.
                                Field selection applies to data tables only.
                            </p>
                        </div>
                    )}
                </div>

                {/* Action Buttons */}
                <div className="flex justify-end gap-3">
                    <button
                        onClick={() => { onClose(); resetForm(); }}
                        className="px-4 py-2 text-[#356B2C] border border-[#356B2C] rounded-md hover:bg-gray-50"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleExport}
                        disabled={isLoading || (exportType === 'custom' && (!startDate || !endDate)) || selectedFields.length === 0}
                        className="px-6 py-2 bg-[#356B2C] text-white rounded-md hover:bg-[#2a5823] disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center gap-2"
                    >
                        {isLoading ? (
                            <>
                                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                                Exporting...
                            </>
                        ) : (
                            `Export ${format.toUpperCase()}`
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ExportDataModal;