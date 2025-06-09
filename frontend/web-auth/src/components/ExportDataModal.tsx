import { useState, useEffect } from 'react';
import { Download, X } from 'lucide-react';
import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Label } from './ui/label';
import { Input } from './ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Calendar } from './ui/calendar';
import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';
import { saveAs } from 'file-saver';

interface ExportDataModalProps {
    isOpen: boolean;
    onClose: () => void;
    currentOverview?: string;
    chartData?: any[];
    chartRef?: React.RefObject<HTMLDivElement | null>;
    chartType?: 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity';
    dateRange?: string;
}

const ExportDataModal: React.FC<ExportDataModalProps> = ({
    isOpen,
    onClose,
    currentOverview = 'weekly',
    chartData = [],
    chartRef,
    chartType = 'humidity',
    dateRange = ''
}) => {
    const [exportFormat, setExportFormat] = useState<string>("CSV");
    const [exportType, setExportType] = useState<string>("current");
    const [startDate, setStartDate] = useState<Date>(new Date());
    const [endDate, setEndDate] = useState<Date>(new Date());
    const [showStartCalendar, setShowStartCalendar] = useState<boolean>(false);
    const [showEndCalendar, setShowEndCalendar] = useState<boolean>(false);
    const [isLoadingExport, setIsLoadingExport] = useState<boolean>(false);
    const [xKey, setXKey] = useState<string>('timestamp');

    // Set xKey based on currentOverview
    useEffect(() => {
        switch (currentOverview) {
            case 'hourly':
                setXKey('hour');
                break;
            case 'daily':
                setXKey('day');
                break;
            case 'weekly':
                setXKey('week');
                break;
            case 'monthly':
                setXKey('month');
                break;
            default:
                setXKey('timestamp');
        }
    }, [currentOverview]);

    // Get field unit for labels
    const getFieldUnit = (field: string): string => {
        const units: { [key: string]: string } = {
            temperature: 'Temperature (°C)',
            humidity: 'Humidity (%)',
            soilMoisture: 'Soil Moisture (%)',
            soilPh: 'pH Level',
            lightIntensity: 'Light Intensity (lux)'
        };
        return units[field] || field;
    };

    // Calculate statistics for the data
    const calculateStatistics = (data: any[]) => {
        const validData = data.filter(item => item.value !== null && !isNaN(item.value));
        if (validData.length === 0) return null;

        const values = validData.map(item => item.value);
        return {
            average: values.reduce((a, b) => a + b, 0) / values.length,
            min: Math.min(...values),
            max: Math.max(...values),
            count: validData.length
        };
    };

    // Get filtered data based on export type
    const getFilteredData = () => {
        if (exportType === "custom") {
            return chartData.filter((item) => {
                const itemDate = new Date(item.timestamp || item[xKey]);
                return itemDate >= startDate && itemDate <= endDate;
            });
        }
        return chartData;
    };

    const handleExport = async () => {
        setIsLoadingExport(true);
        try {
            const filteredData = getFilteredData();
            const stats = calculateStatistics(filteredData);
            
            if (exportFormat === "CSV") {
                // Prepare CSV headers and data
                const headers = [
                    xKey.charAt(0).toUpperCase() + xKey.slice(1),
                    getFieldUnit(chartType),
                    "Status",
                    "Thresholds"
                ];

                const rows = filteredData.map((item) => {
                    const value = item.value as number;
                    const threshold = (item as any).threshold as {
                        min: number;
                        max: number;
                        critical: number;
                    };
                    let status = "Normal";
                    if (value < threshold.min) status = "Too Low";
                    else if (value > threshold.critical) status = "Critical";
                    else if (value > threshold.max) status = "Too High";
                    
                    return [
                        item[xKey],
                        value?.toFixed(1),
                        status,
                        `Min: ${threshold.min}, Max: ${threshold.max}, Critical: ${threshold.critical}`
                    ];
                });

                // Add statistics to CSV
                if (stats) {
                    rows.push(
                        ['', '', '', ''],
                        ['Statistics', '', '', ''],
                        ['Average', stats.average.toFixed(2), '', ''],
                        ['Minimum', stats.min.toFixed(2), '', ''],
                        ['Maximum', stats.max.toFixed(2), '', ''],
                        ['Data Points', stats.count.toString(), '', '']
                    );
                }

                const csvContent = [
                    headers.join(","),
                    ...rows.map(row => row.join(","))
                ].join("\n");
                
                const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8" });
                saveAs(blob, `${chartType}-data-${currentOverview}-${new Date().toISOString().split('T')[0]}.csv`);
            } 
            else if (exportFormat === "PDF") {
                if (!chartRef?.current) throw new Error("Chart reference not found");
                
                const container = document.createElement('div');
                container.style.width = '1200px';
                container.style.height = '800px';
                container.style.position = 'absolute';
                container.style.left = '-9999px';
                container.style.top = '-9999px';
                document.body.appendChild(container);

                const chartClone = chartRef.current.querySelector('svg');
                if (!chartClone) throw new Error("SVG element not found");
                container.appendChild(chartClone.cloneNode(true) as SVGElement);

                try {
                    const canvas = await html2canvas(container, {
                        scale: 2,
                        useCORS: true,
                        logging: false,
                        width: 1200,
                        height: 800,
                        backgroundColor: '#ffffff'
                    });

                    const imgData = canvas.toDataURL('image/png');
                    const pdf = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });
                    const pdfWidth = pdf.internal.pageSize.getWidth();
                    const pdfHeight = pdf.internal.pageSize.getHeight();
                    const imgWidth = canvas.width;
                    const imgHeight = canvas.height;
                    const ratio = Math.min(pdfWidth / imgWidth, pdfHeight / imgHeight);
                    const imgX = (pdfWidth - imgWidth * ratio) / 2;
                    const imgY = 20;

                    // Add title and metadata
                    pdf.setFontSize(16);
                    pdf.setTextColor(37, 99, 235);
                    pdf.text(`${getFieldUnit(chartType)} Dashboard`, pdfWidth / 2, 15, { align: 'center' });
                    
                    pdf.setFontSize(12);
                    pdf.setTextColor(75, 85, 99);
                    pdf.text(
                        `${currentOverview.charAt(0).toUpperCase() + currentOverview.slice(1)} View - ${
                            exportType === "custom" 
                                ? `${startDate.toLocaleDateString()} to ${endDate.toLocaleDateString()}`
                                : dateRange
                        }`,
                        pdfWidth / 2,
                        25,
                        { align: 'center' }
                    );

                    // Add chart
                    pdf.addImage(imgData, 'PNG', imgX, imgY, imgWidth * ratio, imgHeight * ratio);

                    // Add statistics if available
                    if (stats) {
                        const statsY = imgY + imgHeight * ratio + 20;
                        pdf.setFontSize(12);
                        pdf.setTextColor(75, 85, 99);
                        pdf.text('Statistics:', 20, statsY);
                        pdf.setFontSize(10);
                        pdf.text(`Average: ${stats.average.toFixed(2)}`, 20, statsY + 10);
                        pdf.text(`Minimum: ${stats.min.toFixed(2)}`, 20, statsY + 20);
                        pdf.text(`Maximum: ${stats.max.toFixed(2)}`, 20, statsY + 30);
                        pdf.text(`Data Points: ${stats.count}`, 20, statsY + 40);
                    }

                    // Add footer
                    pdf.setFontSize(10);
                    pdf.setTextColor(107, 114, 128);
                    pdf.text(`Generated on ${new Date().toLocaleString()}`, pdfWidth / 2, pdfHeight - 10, { align: 'center' });
                    
                    pdf.save(`${chartType}-dashboard-${currentOverview}-${new Date().toISOString().split('T')[0]}.pdf`);
                } finally {
                    document.body.removeChild(container);
                }
            }
            else if (exportFormat === "SVG") {
                if (!chartRef?.current) throw new Error("Chart reference not found");
                
                const svgElement = chartRef.current.querySelector('svg');
                if (!svgElement) throw new Error("SVG element not found");
                
                const container = document.createElement('div');
                container.style.width = '1200px';
                container.style.height = '800px';
                container.style.position = 'absolute';
                container.style.left = '-9999px';
                container.style.top = '-9999px';
                document.body.appendChild(container);

                const svgClone = svgElement.cloneNode(true) as SVGElement;
                svgClone.setAttribute('width', '1200');
                svgClone.setAttribute('height', '800');

                // Add metadata to SVG
                const metadata = document.createElementNS('http://www.w3.org/2000/svg', 'metadata');
                metadata.innerHTML = `
                    <title>${getFieldUnit(chartType)} Chart</title>
                    <description>${currentOverview} view from ${dateRange}</description>
                    ${stats ? `
                    <statistics>
                        <average>${stats.average.toFixed(2)}</average>
                        <min>${stats.min.toFixed(2)}</min>
                        <max>${stats.max.toFixed(2)}</max>
                        <count>${stats.count}</count>
                    </statistics>
                    ` : ''}
                `;
                svgClone.insertBefore(metadata, svgClone.firstChild);

                container.appendChild(svgClone);

                try {
                    const svgData = new XMLSerializer().serializeToString(svgClone);
                    const svgBlob = new Blob([svgData], { type: 'image/svg+xml;charset=utf-8' });
                    saveAs(svgBlob, `${chartType}-chart-${currentOverview}-${new Date().toISOString().split('T')[0]}.svg`);
                } finally {
                    document.body.removeChild(container);
                }
            }
            
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
                                        value={startDate.toISOString().split('T')[0]}
                                        onChange={(e) => setStartDate(new Date(e.target.value))}
                                        className="w-full p-2 border rounded-md"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1">End Date</label>
                                    <input
                                        type="datetime-local"
                                        value={endDate.toISOString().split('T')[0]}
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
                                { value: 'csv', label: 'CSV', description: 'Excel compatible spreadsheet' },
                                { value: 'pdf', label: 'PDF', description: 'Chart and data report' },
                                { value: 'svg', label: 'SVG', description: 'Scalable vector graphics' }
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
                                        onChange={(e) => setExportFormat(e.target.value as 'csv' | 'pdf' | 'svg')}
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

export default ExportDataModal; 