import { useState, useRef } from 'react';
import { Download, X } from 'lucide-react';
import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Label } from './ui/label';
import { Input } from './ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Calendar } from './ui/calendar';
import { format } from 'date-fns';
import { cn } from '../lib/utils';
import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';
import { saveAs } from 'file-saver';
import { unifiedExport, type ChartDataPoint, type ExportOptions } from '../utils/UnifiedExportUtils';

interface UnifiedExportModalProps {
    isOpen: boolean;
    onClose: () => void;
    currentOverview: 'hourly' | 'daily' | 'weekly' | 'monthly';
    chartData: ChartDataPoint[];
    chartRef: React.RefObject<HTMLDivElement | null>;
    chartType: 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity';
    dateRange?: string;
}

const UnifiedExportModal: React.FC<UnifiedExportModalProps> = ({
    isOpen,
    onClose,
    currentOverview,
    chartData = [],
    chartRef,
    chartType,
    dateRange = ''
}) => {
    const [exportFormat, setExportFormat] = useState<'pdf' | 'csv' | 'svg'>('pdf');
    const [exportType, setExportType] = useState<'current' | 'custom'>('current');
    const [startDate, setStartDate] = useState<Date>(new Date());
    const [endDate, setEndDate] = useState<Date>(new Date());
    const [isLoadingExport, setIsLoadingExport] = useState<boolean>(false);

    const handleExport = async () => {
        setIsLoadingExport(true);
        try {
            const options: ExportOptions = {
                format: exportFormat,
                chartType,
                currentOverview,
                customDateRange: exportType === 'custom' ? {
                    startDate,
                    endDate
                } : undefined
            };

            await unifiedExport(exportFormat, chartRef.current, chartData, options);
            onClose();
        } catch (error) {
            console.error("Export error:", error);
            alert("Export failed. Please try again.");
        } finally {
            setIsLoadingExport(false);
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
            <Card className="w-full max-w-2xl bg-white shadow-lg" onClick={e => e.stopPropagation()}>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-xl font-bold">Export Data</CardTitle>
                    <Button variant="ghost" size="icon" onClick={onClose}>
                        <X className="h-4 w-4" />
                    </Button>
                </CardHeader>
                <CardContent>
                    {/* Export Type Selection */}
                    <div className="mb-6">
                        <h3 className="text-lg font-semibold mb-3">Export Type</h3>
                        <div className="flex gap-2">
                            <Button
                                variant={exportType === 'current' ? 'default' : 'outline'}
                                onClick={() => setExportType('current')}
                                className="flex-1"
                            >
                                Current Period
                            </Button>
                            <Button
                                variant={exportType === 'custom' ? 'default' : 'outline'}
                                onClick={() => setExportType('custom')}
                                className="flex-1"
                            >
                                Custom Range
                            </Button>
                        </div>
                    </div>

                    {/* Date Range Selection */}
                    {exportType === 'custom' && (
                        <div className="mb-6">
                            <h3 className="text-lg font-semibold mb-3">Select Date Range</h3>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium mb-1">Start Date</label>
                                    <input
                                        type="datetime-local"
                                        value={startDate.toISOString().slice(0, 16)}
                                        onChange={(e) => setStartDate(new Date(e.target.value))}
                                        className="w-full p-2 border rounded-md"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1">End Date</label>
                                    <input
                                        type="datetime-local"
                                        value={endDate.toISOString().slice(0, 16)}
                                        onChange={(e) => setEndDate(new Date(e.target.value))}
                                        className="w-full p-2 border rounded-md"
                                    />
                                </div>
                            </div>
                        </div>
                    )}

                    {/* Format Selection */}
                    <div className="mb-6">
                        <h3 className="text-lg font-semibold mb-3">Export Format</h3>
                        <div className="grid grid-cols-3 gap-4">
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
                    </div>

                    {/* Action Buttons */}
                    <div className="flex justify-end gap-3">
                        <Button variant="outline" onClick={onClose}>
                            Cancel
                        </Button>
                        <Button
                            onClick={handleExport}
                            disabled={isLoadingExport || (exportType === 'custom' && (!startDate || !endDate))}
                            className="flex items-center gap-2"
                        >
                            {isLoadingExport ? (
                                <>
                                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                                    Exporting...
                                </>
                            ) : (
                                <>
                                    <Download className="h-4 w-4" />
                                    Export {exportFormat.toUpperCase()}
                                </>
                            )}
                        </Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
};

export default UnifiedExportModal; 