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
            alert("Export failed. Please try again.");
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
            <Card className="w-full max-w-2xl bg-white shadow-lg" onClick={e => e.stopPropagation()}>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-xl font-bold">Export Data</CardTitle>
                    <Button variant="ghost" size="icon" onClick={onClose}>
                        <X className="h-4 w-4" />
                    </Button>
                </CardHeader>
                <CardContent>
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

                    {/* PDF Options */}
                    {exportFormat === 'pdf' && (
                        <div className="mb-6">
                            <h3 className="text-lg font-semibold mb-3">PDF Options</h3>
                            <div className="flex gap-6">
                                <label className="flex items-center gap-2">
                                    <input
                                        type="checkbox"
                                        checked={includeChartImage}
                                        onChange={e => setIncludeChartImage(e.target.checked)}
                                    />
                                    Include chart image
                                </label>
                                <label className="flex items-center gap-2">
                                    <input
                                        type="checkbox"
                                        checked={includeTabularData}
                                        onChange={e => setIncludeTabularData(e.target.checked)}
                                    />
                                    Include tabular data
                                </label>
                            </div>
                        </div>
                    )}

                    {/* Action Buttons */}
                    <div className="flex justify-end gap-3">
                        <Button variant="outline" onClick={onClose}>
                            Cancel
                        </Button>
                        <Button
                            onClick={handleExport}
                            disabled={isExporting}
                            className="flex items-center gap-2"
                        >
                            {isExporting ? (
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