import { useState } from "react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Download, X } from "lucide-react";
import { exportChartData, type ChartDataPoint, type ExportOptions } from "../utils/UnifiedExportUtils";

interface UnifiedExportModalProps {
    isOpen: boolean;
    onClose: () => void;
    currentOverview: 'hourly' | 'daily' | 'weekly' | 'monthly';
    chartData: ChartDataPoint[];
    chartRef: React.RefObject<HTMLDivElement | null>;
    chartType: 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity';
    dateRange?: string;
}

const UnifiedExportModal = ({ 
    isOpen, 
    onClose, 
    currentOverview, 
    chartData, 
    chartRef, 
    chartType, 
    dateRange 
}: UnifiedExportModalProps) => {
    const [exportFormat, setExportFormat] = useState<'pdf' | 'svg' | 'csv'>('pdf');
    const [isExporting, setIsExporting] = useState(false);
    const [includeChartImage, setIncludeChartImage] = useState(true);
    const [includeTabularData, setIncludeTabularData] = useState(true);

    const handleExport = async () => {
        setIsExporting(true);
        try {
            const options: ExportOptions = {
                format: exportFormat,
                chartType,
                currentOverview,
                dateRange: dateRange ? { from: dateRange, to: dateRange } : undefined,
                includeChartImage,
                includeTabularData
            };
            
            await exportChartData(chartData, options, exportFormat, chartRef);
            onClose();
        } catch (error) {
            console.error('Export failed:', error);
            // Create styled error message that matches the theme
            const errorMessage = error instanceof Error ? error.message : 'Unknown error';
            const errorDiv = document.createElement('div');
            errorDiv.className = 'fixed top-4 right-4 z-50 bg-red-100 border border-red-400 text-red-700 px-6 py-4 rounded-lg shadow-lg max-w-md';
            errorDiv.innerHTML = `
                <div class="flex items-center">
                    <svg class="w-5 h-5 mr-2 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                    </svg>
                    <div>
                        <p class="font-semibold">Export Failed</p>
                        <p class="text-sm mt-1">${errorMessage}. Please try again.</p>
                    </div>
                </div>
            `;
            document.body.appendChild(errorDiv);
            
            // Auto-remove after 5 seconds
            setTimeout(() => {
                if (errorDiv.parentNode) {
                    errorDiv.parentNode.removeChild(errorDiv);
                }
            }, 5000);
        } finally {
            setIsExporting(false);
        }
    };

    // Add click outside handler
    const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
        if (e.target === e.currentTarget) {
            onClose();
        }
    };

    if (!isOpen) return null;

    return (
        <div 
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
            onClick={handleBackdropClick}
        >
            <div className="bg-[#E6F0D3] rounded-xl shadow-lg max-w-md w-full p-6" onClick={e => e.stopPropagation()}>
                {/* Header */}
                <div className="flex items-center justify-between mb-6">
                    <h2 className="text-lg font-semibold text-[#1E441E]">Export Options</h2>
                    <button
                        onClick={onClose}
                        className="text-[#456C2D] hover:text-[#1E441E] transition-colors"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* Export Format */}
                <div className="mb-6">
                    <label className="text-sm font-medium text-[#1E441E] mb-3 block">
                        Export Format
                    </label>
                    <div className="flex gap-2">
                        {[
                            { value: 'csv' as const, label: 'CSV' },
                            { value: 'pdf' as const, label: 'PDF' },
                            { value: 'svg' as const, label: 'SVG' }
                        ].map((option) => (
                            <button
                                key={option.value}
                                onClick={() => setExportFormat(option.value)}
                                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                                    exportFormat === option.value
                                        ? 'bg-[#456C2D] text-white'
                                        : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
                                }`}
                            >
                                {option.label}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Export Type */}
                <div className="mb-6">
                    <label className="text-sm font-medium text-[#1E441E] mb-3 block">
                        Date Range Selection
                    </label>
                    <div className="flex gap-2">
                        <button
                            onClick={() => setExportType('predefined')}
                            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                                exportType === 'predefined'
                                    ? 'bg-[#456C2D] text-white'
                                    : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
                            }`}
                        >
                            Predefined Period
                        </button>
                        <button
                            onClick={() => setExportType('custom')}
                            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                                exportType === 'custom'
                                    ? 'bg-[#456C2D] text-white'
                                    : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
                            }`}
                        >
                            Custom Range
                        </button>
                    </div>
                    {/* <p className="text-xs text-[#456C2D] mt-2">
                        {exportType === 'predefined' 
                            ? 'Select from common time periods (last day, week, month, year)'
                            : 'Choose specific start and end dates for your export'
                        }
                    </p> */}
                </div>

                {/* Time Frame (for predefined) */}
                {exportType === 'predefined' && (
                    <div className="mb-6">
                        {/*  <label className="text-sm font-medium text-[#1E441E] mb-3 block">
                            Time Period
                        </label>
                       <div className="grid grid-cols-2 gap-2">
                            {[
                                { value: 'csv' as const, label: 'CSV', description: 'Excel compatible spreadsheet' },
                                { value: 'pdf' as const, label: 'PDF', description: 'Chart and data report' },
                                { value: 'svg' as const, label: 'SVG', description: 'Scalable vector graphics' }
                            ].map((option) => (
                                <label
                                    key={option.value}
                                    className={`flex items-center p-3 border rounded-md cursor-pointer ${
                                        exportFormat === option.value ? 'border-primary bg-primary/5' : 'border-border'
                                    }`}
                                >
                                    <input
                                        type="radio"
                                        value={option.value}
                                        checked={exportFormat === option.value}
                                        onChange={(e) => setExportFormat(e.target.value as 'pdf' | 'csv' | 'svg')}
                                        className="mr-2"
                                    />
                                    <div>
                                        <div className="font-medium">{option.label}</div>
                                        <div className="text-sm text-muted-foreground">{option.description}</div>
                                    </div>
                                </label>
                            ))}
                        </div> 
                        <p className="text-xs text-[#456C2D] mt-2">
                            Data will be filtered to show only the selected time period from now backwards
                        </p>*/}
                    </div>

                {/* Custom Date Range */}
                {exportType === 'custom' && (
                    <div className="mb-6 space-y-4">
                        <div>
                            <label className="text-sm font-medium text-[#1E441E] mb-2 block">
                                Start Date
                            </label>
                            <div className="relative">
                                <input
                                    type="date"
                                    value={startDate}
                                    onChange={(e) => setStartDate(e.target.value)}
                                    className="w-full h-10 px-3 py-2 bg-white border border-[#456C2D] rounded-md text-[#1E441E] placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#456C2D] appearance-none"
                                    placeholder="YYYY-MM-DD"
                                />
                            </div>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-[#1E441E] mb-2 block">
                                End Date
                            </label>
                            <div className="relative">
                                <input
                                    type="date"
                                    value={endDate}
                                    onChange={(e) => setEndDate(e.target.value)}
                                    className="w-full h-10 px-3 py-2 bg-white border border-[#456C2D] rounded-md text-[#1E441E] placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#456C2D] appearance-none"
                                    placeholder="YYYY-MM-DD"
                                />
                            </div>
                        </div>
                        <p className="text-xs text-[#456C2D]">
                            Select the exact date range you want to include in your export
                        </p>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
};

export default UnifiedExportModal; 