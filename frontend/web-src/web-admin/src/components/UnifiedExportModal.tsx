import { useState } from "react";
import { Button } from "./ui/button";
import { Download, X, Calendar } from "lucide-react";
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
    const [exportFormat, setExportFormat] = useState<'csv' | 'pdf' | 'svg'>('csv');
    const [exportType, setExportType] = useState<'predefined' | 'custom'>('predefined');
    const [timeFrame, setTimeFrame] = useState<'day' | 'week' | 'month' | 'year'>('week');
    const [startDate, setStartDate] = useState<string>('');
    const [endDate, setEndDate] = useState<string>('');
    const [isExporting, setIsExporting] = useState(false);
    const [includeChartImage, setIncludeChartImage] = useState(true);
    const [includeTabularData, setIncludeTabularData] = useState(true);

    const handleExport = async () => {
        setIsExporting(true);
        try {
            // Validate custom date range if selected
            if (exportType === 'custom') {
                if (!startDate || !endDate) {
                    alert('Please select both start and end dates for custom range');
                    return;
                }
                if (new Date(startDate) >= new Date(endDate)) {
                    alert('Start date must be before end date');
                    return;
                }
            }

            // Build comprehensive export options
            const options: ExportOptions = {
                format: exportFormat,
                chartType,
                currentOverview,
                exportType,
                timeFrame: exportType === 'predefined' ? timeFrame : undefined,
                customDateRange: exportType === 'custom' ? { 
                    startDate: startDate, 
                    endDate: endDate 
                } : undefined,
                dateRange: dateRange ? { 
                    from: dateRange.split(' - ')[0] || dateRange, 
                    to: dateRange.split(' - ')[1] || dateRange 
                } : undefined,
                includeChartImage: exportFormat === 'pdf' ? includeChartImage : false,
                includeTabularData: exportFormat === 'pdf' ? includeTabularData : true
            };

            console.log('Export initiated with options:', options);
            console.log('Chart data to export:', chartData.length, 'items');
            
            await exportChartData(chartData, options, exportFormat, chartRef);
            onClose();
        } catch (error) {
            console.error('Export failed:', error);
            alert(`Export failed: ${error instanceof Error ? error.message : 'Unknown error'}. Please try again.`);
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
                    <p className="text-xs text-[#456C2D] mt-2">
                        {exportType === 'predefined' 
                            ? 'Select from common time periods (last day, week, month, year)'
                            : 'Choose specific start and end dates for your export'
                        }
                    </p>
                </div>

                {/* Time Frame (for predefined) */}
                {exportType === 'predefined' && (
                    <div className="mb-6">
                        <label className="text-sm font-medium text-[#1E441E] mb-3 block">
                            Time Period
                        </label>
                        <div className="grid grid-cols-2 gap-2">
                            {[
                                { value: 'day' as const, label: 'Last 24 Hours' },
                                { value: 'week' as const, label: 'Last 7 Days' },
                                { value: 'month' as const, label: 'Last 30 Days' },
                                { value: 'year' as const, label: 'Last 365 Days' }
                            ].map((option) => (
                                <button
                                    key={option.value}
                                    onClick={() => setTimeFrame(option.value)}
                                    className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                                        timeFrame === option.value
                                            ? 'bg-[#456C2D] text-white'
                                            : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
                                    }`}
                                >
                                    {option.label}
                                </button>
                            ))}
                        </div>
                        <p className="text-xs text-[#456C2D] mt-2">
                            Data will be filtered to show only the selected time period from now backwards
                        </p>
                    </div>
                )}

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
                                    className="w-full h-10 px-3 pr-10 py-2 bg-white border border-[#456C2D] rounded-md text-[#1E441E] placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#456C2D] appearance-none"
                                    placeholder="YYYY-MM-DD"
                                />
                                <Calendar className="pointer-events-none absolute right-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-[#456C2D]" />
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
                                    className="w-full h-10 px-3 pr-10 py-2 bg-white border border-[#456C2D] rounded-md text-[#1E441E] placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#456C2D] appearance-none"
                                    placeholder="YYYY-MM-DD"
                                />
                                <Calendar className="pointer-events-none absolute right-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-[#456C2D]" />
                            </div>
                        </div>
                        <p className="text-xs text-[#456C2D]">
                            Select the exact date range you want to include in your export
                        </p>
                    </div>
                )}

                {/* PDF Options */}
                {exportFormat === 'pdf' && (
                    <div className="mb-6">
                        <label className="text-sm font-medium text-[#1E441E] mb-3 block">
                            PDF Content Options
                        </label>
                        <div className="space-y-2">
                            <label className="flex items-center gap-2 text-sm text-[#1E441E]">
                                <input
                                    type="checkbox"
                                    checked={includeChartImage}
                                    onChange={e => setIncludeChartImage(e.target.checked)}
                                    className="rounded border-[#456C2D] text-[#456C2D] focus:ring-[#456C2D]"
                                />
                                Include chart visualization
                            </label>
                            <label className="flex items-center gap-2 text-sm text-[#1E441E]">
                                <input
                                    type="checkbox"
                                    checked={includeTabularData}
                                    onChange={e => setIncludeTabularData(e.target.checked)}
                                    className="rounded border-[#456C2D] text-[#456C2D] focus:ring-[#456C2D]"
                                />
                                Include data table with statistics
                            </label>
                        </div>
                    </div>
                )}

                {/* Current Chart Info */}
                <div className="mb-6 p-3 bg-white/50 rounded-lg">
                    <p className="text-xs text-[#456C2D] font-medium mb-1">Current Chart Info:</p>
                    <p className="text-xs text-[#1E441E]">View: {currentOverview.charAt(0).toUpperCase() + currentOverview.slice(1)}</p>
                    <p className="text-xs text-[#1E441E]">Type: {chartType.charAt(0).toUpperCase() + chartType.slice(1)}</p>
                    <p className="text-xs text-[#1E441E]">Data Points: {chartData.length}</p>
                    {dateRange && <p className="text-xs text-[#1E441E]">Period: {dateRange}</p>}
                </div>

                {/* Action Buttons */}
                <div className="flex gap-3 justify-end">
                    <Button
                        onClick={onClose}
                        variant="outline"
                        className="bg-white border-[#456C2D] text-[#456C2D] hover:bg-[#456C2D] hover:text-white"
                        disabled={isExporting}
                    >
                        Cancel
                    </Button>
                    <Button
                        onClick={handleExport}
                        disabled={isExporting || (exportType === 'custom' && (!startDate || !endDate))}
                        className="bg-[#456C2D] text-white hover:bg-[#356B2C] flex items-center gap-2"
                    >
                        {isExporting ? (
                            <>
                                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                                Exporting...
                            </>
                        ) : (
                            <>
                                <Download className="w-4 h-4" />
                                Export {exportFormat.toUpperCase()}
                            </>
                        )}
                    </Button>
                </div>
            </div>
        </div>
    );
};

export default UnifiedExportModal;

// import { useState } from "react";
// import { Button } from "./ui/button";
// import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
// import { Download, X, Calendar } from "lucide-react";
// import { exportChartData, type ChartDataPoint, type ExportOptions } from "../utils/UnifiedExportUtils";

// interface UnifiedExportModalProps {
//     isOpen: boolean;
//     onClose: () => void;
//     currentOverview: 'hourly' | 'daily' | 'weekly' | 'monthly';
//     chartData: ChartDataPoint[];
//     chartRef: React.RefObject<HTMLDivElement | null>;
//     chartType: 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity';
//     dateRange?: string;
// }

// const UnifiedExportModal = ({ 
//     isOpen, 
//     onClose, 
//     currentOverview, 
//     chartData, 
//     chartRef, 
//     chartType, 
//     dateRange 
// }: UnifiedExportModalProps) => {
//     const [exportFormat, setExportFormat] = useState<'csv' | 'pdf' | 'svg'>('csv');
//     const [exportType, setExportType] = useState<'predefined' | 'custom'>('predefined');
//     const [timeFrame, setTimeFrame] = useState<'day' | 'week' | 'month' | 'year'>('day');
//     const [startDate, setStartDate] = useState<string>('');
//     const [endDate, setEndDate] = useState<string>('');
//     const [isExporting, setIsExporting] = useState(false);
//     const [includeChartImage, setIncludeChartImage] = useState(true);
//     const [includeTabularData, setIncludeTabularData] = useState(true);

//     const handleExport = async () => {
//         setIsExporting(true);
//         try {
//             // Validate custom date range if selected
//             if (exportType === 'custom') {
//                 if (!startDate || !endDate) {
//                     alert('Please select both start and end dates for custom range');
//                     return;
//                 }
//                 if (new Date(startDate) >= new Date(endDate)) {
//                     alert('Start date must be before end date');
//                     return;
//                 }
//             }

//             const options: ExportOptions = {
//                 format: exportFormat,
//                 chartType,
//                 currentOverview,
//                 exportType,
//                 timeFrame: exportType === 'predefined' ? timeFrame : undefined,
//                 customDateRange: exportType === 'custom' ? { startDate, endDate } : undefined,
//                 dateRange: dateRange ? { from: dateRange, to: dateRange } : undefined,
//                 includeChartImage,
//                 includeTabularData
//             };
            
//             await exportChartData(chartData, options, exportFormat, chartRef);
//             onClose();
//         } catch (error) {
//             console.error('Export failed:', error);
//             alert("Export failed. Please try again.");
//         } finally {
//             setIsExporting(false);
//         }
//     };

//     // Add click outside handler
//     const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
//         if (e.target === e.currentTarget) {
//             onClose();
//         }
//     };

//     if (!isOpen) return null;

//     return (
//         <div 
//             className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
//             onClick={handleBackdropClick}
//         >
//             <div className="bg-[#E6F0D3] rounded-xl shadow-lg max-w-md w-full p-6" onClick={e => e.stopPropagation()}>
//                 {/* Header */}
//                 <div className="flex items-center justify-between mb-6">
//                     <h2 className="text-lg font-semibold text-[#1E441E]">Export Options</h2>
//                     <button
//                         onClick={onClose}
//                         className="text-[#456C2D] hover:text-[#1E441E] transition-colors"
//                     >
//                         <X className="w-5 h-5" />
//                     </button>
//                 </div>

//                 {/* Export Format */}
//                 <div className="mb-6">
//                     <label className="text-sm font-medium text-[#1E441E] mb-3 block">
//                         Export Format
//                     </label>
//                     <div className="flex gap-2">
//                         {[
//                             { value: 'csv' as const, label: 'CSV' },
//                             { value: 'pdf' as const, label: 'PDF' },
//                             { value: 'svg' as const, label: 'SVG' }
//                         ].map((option) => (
//                             <button
//                                 key={option.value}
//                                 onClick={() => setExportFormat(option.value)}
//                                 className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
//                                     exportFormat === option.value
//                                         ? 'bg-[#456C2D] text-white'
//                                         : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
//                                 }`}
//                             >
//                                 {option.label}
//                             </button>
//                         ))}
//                     </div>
//                 </div>

//                 {/* Export Type */}
//                 <div className="mb-6">
//                     <label className="text-sm font-medium text-[#1E441E] mb-3 block">
//                         Export Type
//                     </label>
//                     <div className="flex gap-2">
//                         <button
//                             onClick={() => setExportType('predefined')}
//                             className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
//                                 exportType === 'predefined'
//                                     ? 'bg-[#456C2D] text-white'
//                                     : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
//                             }`}
//                         >
//                             Predefined Period
//                         </button>
//                         <button
//                             onClick={() => setExportType('custom')}
//                             className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
//                                 exportType === 'custom'
//                                     ? 'bg-[#456C2D] text-white'
//                                     : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
//                             }`}
//                         >
//                             Custom Range
//                         </button>
//                     </div>
//                 </div>

//                 {/* Time Frame (for predefined) */}
//                 {exportType === 'predefined' && (
//                     <div className="mb-6">
//                         <label className="text-sm font-medium text-[#1E441E] mb-3 block">
//                             Time Frame
//                         </label>
//                         <div className="grid grid-cols-2 gap-2">
//                             {[
//                                 { value: 'day' as const, label: 'Day' },
//                                 { value: 'week' as const, label: 'Week' },
//                                 { value: 'month' as const, label: 'Month' },
//                                 { value: 'year' as const, label: 'Year' }
//                             ].map((option) => (
//                                 <button
//                                     key={option.value}
//                                     onClick={() => setTimeFrame(option.value)}
//                                     className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
//                                         timeFrame === option.value
//                                             ? 'bg-[#456C2D] text-white'
//                                             : 'bg-white text-[#456C2D] border border-[#456C2D] hover:bg-[#456C2D] hover:text-white'
//                                     }`}
//                                 >
//                                     {option.label}
//                                 </button>
//                             ))}
//                         </div>
//                     </div>
//                 )}

//                 {/* Custom Date Range */}
//                 {exportType === 'custom' && (
//                     <div className="mb-6 space-y-4">
//                         <div>
//                             <label className="text-sm font-medium text-[#1E441E] mb-2 block">
//                                 Start Date
//                             </label>
//                             <div className="relative">
//                                 <input
//                                     type="date"
//                                     value={startDate}
//                                     onChange={(e) => setStartDate(e.target.value)}
//                                     className="w-full h-10 px-3 pr-10 py-2 bg-white border border-[#456C2D] rounded-md text-[#1E441E] placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#456C2D] appearance-none"
//                                     placeholder="YYYY-MM-DD"
//                                 />
//                                 <Calendar className="pointer-events-none absolute right-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-[#456C2D]" />
//                             </div>
//                         </div>
//                         <div>
//                             <label className="text-sm font-medium text-[#1E441E] mb-2 block">
//                                 End Date
//                             </label>
//                             <div className="relative">
//                                 <input
//                                     type="date"
//                                     value={endDate}
//                                     onChange={(e) => setEndDate(e.target.value)}
//                                     className="w-full h-10 px-3 pr-10 py-2 bg-white border border-[#456C2D] rounded-md text-[#1E441E] placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#456C2D] appearance-none"
//                                     placeholder="YYYY-MM-DD"
//                                 />
//                                 <Calendar className="pointer-events-none absolute right-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-[#456C2D]" />
//                             </div>
//                         </div>
//                     </div>
//                 )}

//                 {/* PDF Options */}
//                 {exportFormat === 'pdf' && (
//                     <div className="mb-6">
//                         <label className="text-sm font-medium text-[#1E441E] mb-3 block">
//                             PDF Options
//                         </label>
//                         <div className="space-y-2">
//                             <label className="flex items-center gap-2 text-sm text-[#1E441E]">
//                                 <input
//                                     type="checkbox"
//                                     checked={includeChartImage}
//                                     onChange={e => setIncludeChartImage(e.target.checked)}
//                                     className="rounded border-[#456C2D] text-[#456C2D] focus:ring-[#456C2D]"
//                                 />
//                                 Include chart image
//                             </label>
//                             <label className="flex items-center gap-2 text-sm text-[#1E441E]">
//                                 <input
//                                     type="checkbox"
//                                     checked={includeTabularData}
//                                     onChange={e => setIncludeTabularData(e.target.checked)}
//                                     className="rounded border-[#456C2D] text-[#456C2D] focus:ring-[#456C2D]"
//                                 />
//                                 Include tabular data
//                             </label>
//                         </div>
//                     </div>
//                 )}

//                 {/* Action Buttons */}
//                 <div className="flex gap-3 justify-end">
//                     <Button
//                         onClick={onClose}
//                         variant="outline"
//                         className="bg-white border-[#456C2D] text-[#456C2D] hover:bg-[#456C2D] hover:text-white"
//                     >
//                         Cancel
//                     </Button>
//                     <Button
//                         onClick={handleExport}
//                         disabled={isExporting || (exportType === 'custom' && (!startDate || !endDate))}
//                         className="bg-[#456C2D] text-white hover:bg-[#356B2C] flex items-center gap-2"
//                     >
//                         {isExporting ? (
//                             <>
//                                 <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
//                                 Exporting...
//                             </>
//                         ) : (
//                             <>
//                                 <Download className="w-4 h-4" />
//                                 Export
//                             </>
//                         )}
//                     </Button>
//                 </div>
//             </div>
//         </div>
//     );
// };

// export default UnifiedExportModal; 