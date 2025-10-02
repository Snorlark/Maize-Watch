import React from "react";
import apiClient from "../api/client";
import { jsPDF } from "jspdf";
import * as htmlToImage from "html-to-image";
import Papa from "papaparse";

// Chart configuration for export formatting
const CHART_CONFIGS = {
  temperature: {
    title: "Temperature Monitoring Report",
    fieldName: "Temperature",
    unit: "°C",
    shortName: "temp"
  },
  humidity: {
    title: "Humidity Monitoring Report", 
    fieldName: "Humidity",
    unit: "%",
    shortName: "humidity"
  },
  soilMoisture: {
    title: "Soil Moisture Monitoring Report",
    fieldName: "Soil Moisture", 
    unit: "%",
    shortName: "soil-moisture"
  },
  soilPh: {
    title: "Soil pH Level Monitoring Report",
    fieldName: "Soil pH",
    unit: "pH",
    shortName: "soil-ph"
  },
  lightIntensity: {
    title: "Light Intensity Monitoring Report",
    fieldName: "Light Intensity",
    unit: "lux",
    shortName: "light-intensity"
  }
};

// Load an image from public path and return a data URL for embedding in PDF
const loadImageAsDataUrl = async (path: string): Promise<string> => {
  try {
    const res = await fetch(path, { cache: 'no-cache' });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const blob = await res.blob();
    return await new Promise<string>((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(String(reader.result));
      reader.onerror = () => reject(reader.error);
      reader.readAsDataURL(blob);
    });
  } catch (e) {
    console.warn('Failed to load image:', path, e);
    throw e;
  }
};

// Try multiple public paths to find the logo and return a data URL
const loadLogoDataUrl = async (): Promise<string | null> => {
  const candidates = [
    '/maizewatch.png',
    '/web-admin/public/maizewatch.png',
    'maizewatch.png'
  ];
  for (const path of candidates) {
    try {
      const dataUrl = await loadImageAsDataUrl(path);
      if (dataUrl && dataUrl.startsWith('data:image')) return dataUrl;
    } catch (_) {
      // continue trying other paths
    }
  }
  return null;
};

// Data point interface
interface ChartDataPoint {
  [key: string]: string | number | null | { min: number; max: number; critical: number } | undefined;
  value: number | null;
  threshold?: {
    min: number;
    max: number;
    critical: number;
  };
  hour?: string;
  day?: string;
  week?: string;
  month?: string;
  timestamp?: string;
  dataPoints?: number;
  periodDescription?: string;
  exportType?: string;
}

type DateRange = {
  from: string;
  to: string;
} | null;

interface ExportOptions {
  format: 'pdf' | 'csv' | 'svg';
  chartType: 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity';
  currentOverview: 'hourly' | 'daily' | 'weekly' | 'monthly';
  exportType?: 'predefined' | 'custom';
  timeFrame?: 'day' | 'week' | 'month' | 'year';
  customDateRange?: { startDate: string; endDate: string };
  dateRange?: DateRange;
  includeChartImage?: boolean;
  includeTabularData?: boolean;
}

// Helper function to calculate statistics
const calculateStatistics = (data: ChartDataPoint[]) => {
  const validData = data.filter(item => item.value !== null && item.value !== undefined);
  
  if (validData.length === 0) return null;
  
  const values = validData.map(item => item.value as number);
  const sum = values.reduce((acc, val) => acc + val, 0);
  const average = sum / values.length;
  const min = Math.min(...values);
  const max = Math.max(...values);
  
  return {
    average,
    min,
    max,
    count: validData.length,
    total: sum
  };
};


// Helper function to generate standardized filename
const generateFilename = (chartType: string, format: string, options: ExportOptions) => {
  const config = CHART_CONFIGS[chartType as keyof typeof CHART_CONFIGS];
  const shortName = config.shortName;
  const now = new Date();
  const timestamp = now.toISOString().split('T')[0]; // YYYY-MM-DD
  
  let period: string = options.currentOverview;
  
  if (options.customDateRange) {
    const start = new Date(options.customDateRange.startDate).toISOString().split('T')[0];
    const end = new Date(options.customDateRange.endDate).toISOString().split('T')[0];
    period = `${start}_to_${end}`;
  } else if (options.timeFrame) {
    period = options.timeFrame;
  } else if (options.dateRange && options.dateRange.from && options.dateRange.to) {
    const start = new Date(options.dateRange.from).toISOString().split('T')[0];
    const end = new Date(options.dateRange.to).toISOString().split('T')[0];
    period = `${start}_to_${end}`;
  }
  
  return `MaizeWatch_${shortName}_${period}_${timestamp}.${format}`;
};

// Helper function to format date for display
const formatDateForDisplay = (date: Date): string => {
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};

// Helper function to calculate predefined date ranges
const calculatePredefinedRange = (timeFrame: 'day' | 'week' | 'month' | 'year'): { start: Date; end: Date } => {
  const end = new Date();
  const start = new Date();

  switch (timeFrame) {
    case 'day':
      start.setDate(end.getDate() - 1);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
      break;
    case 'week':
      start.setDate(end.getDate() - 7);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
      break;
    case 'month':
      start.setMonth(end.getMonth() - 1);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
      break;
    case 'year':
      start.setFullYear(end.getFullYear() - 1);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
      break;
    default:
      start.setDate(end.getDate() - 1);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
  }

  return { start, end };
};

// Enhanced function to create filtered data based on export options
const createFilteredDataForExport = (
  originalData: ChartDataPoint[],
  options: ExportOptions
): { data: ChartDataPoint[]; actualRange: { start: Date; end: Date } | null } => {
  
  // For PREDEFINED exports, use the current chart data as-is
  // This ensures the export matches exactly what the user sees in the chart
  if (options.exportType === 'predefined') {
    console.log('Predefined export: using current chart data as-is');
    console.log('Current overview:', options.currentOverview);
    console.log('Chart data:', originalData);
    
    // Add descriptive information about what period this represents
    let periodDescription: string;
    switch (options.currentOverview) {
      case 'daily':
        periodDescription = 'Current Week (Sunday to Saturday)';
        break;
      case 'weekly': 
        periodDescription = 'Current Month (Week 1 to Week 5)';
        break;
      case 'monthly':
        periodDescription = 'Current Year (January to December)';
        break;
      default:
        periodDescription = 'Current Period';
    }
    
    // Add metadata to describe the current period being exported
    const enhancedData = originalData.map((item) => ({
      ...item,
      periodDescription,
      exportType: 'predefined_current_view'
    }));

    return { 
      data: enhancedData, 
      actualRange: null // No specific date range for predefined - it's the current view
    };
  }

  // For CUSTOM exports, we need to handle date range filtering
  if (options.exportType === 'custom' && options.customDateRange) {
    const targetStart = new Date(options.customDateRange.startDate);
    const targetEnd = new Date(options.customDateRange.endDate);
    targetEnd.setHours(23, 59, 59, 999);
    
    console.log('Custom export: filtering data for date range', {
      start: targetStart.toISOString(),
      end: targetEnd.toISOString()
    });

    // For custom date ranges, we'll create synthetic data based on the selected range
    // This is more complex and depends on how your chart data is structured
    const enhancedData = originalData.map((item, index) => {
      // Add synthetic timestamp within the custom range for display
      const rangeDurationMs = targetEnd.getTime() - targetStart.getTime();
      const itemTimestamp = new Date(targetStart.getTime() + (index / originalData.length) * rangeDurationMs);
      
      return {
        ...item,
        timestamp: itemTimestamp.toISOString(),
        exportType: 'custom_date_range'
      };
    });

    return { 
      data: enhancedData, 
      actualRange: { start: targetStart, end: targetEnd }
    };
  }

  // Default: return original data
  console.log('Default export: using original data');
  return { data: originalData, actualRange: null };
};

// Fetch real data for custom date range from backend and map to ChartDataPoint[]
const fetchCustomRangeData = async (
  chartType: ExportOptions["chartType"],
  startISO: string,
  endISO: string
): Promise<ChartDataPoint[]> => {
  try {
    const response = await apiClient.get("/api/sensors/historical", {
      params: { startDate: startISO, endDate: endISO },
    });

    const payload = response.data?.data ?? response.data;
    const readings: any[] = Array.isArray(payload) ? payload : payload?.readings || [];

    const valueKeyMap: Record<string, string> = {
      temperature: "temperature",
      humidity: "humidity",
      soilMoisture: "soilMoisture",
      soilPh: "soilPh",
      lightIntensity: "lightIntensity",
    };
    const key = valueKeyMap[chartType] || "temperature";

    // Build daily buckets for the full range (inclusive)
    const start = new Date(startISO);
    start.setHours(0, 0, 0, 0);
    const end = new Date(endISO);
    end.setHours(23, 59, 59, 999);

    const dayKey = (d: Date) => `${d.getFullYear()}-${(d.getMonth()+1).toString().padStart(2,'0')}-${d.getDate().toString().padStart(2,'0')}`;

    const buckets = new Map<string, { sum: number; count: number }>();

    readings.forEach((r) => {
      if (!r || !r.timestamp) return;
      const ts = new Date(r.timestamp);
      if (ts < start || ts > end) return;
      const data = r.data || r;
      const v = typeof data[key] === 'number' ? data[key] : null;
      if (v === null || Number.isNaN(v)) return;
      const k = dayKey(ts);
      const cur = buckets.get(k) || { sum: 0, count: 0 };
      cur.sum += v;
      cur.count += 1;
      buckets.set(k, cur);
    });

    // Produce a row for every day in the range, fill N/A when empty
    const result: ChartDataPoint[] = [];
    const cursor = new Date(start);
    while (cursor <= end) {
      const k = dayKey(cursor);
      const b = buckets.get(k);
      const avg = b && b.count > 0 ? Number((b.sum / b.count).toFixed(2)) : null;
      const ts = new Date(cursor);
      // set to noon to avoid TZ edge cases when rendering
      ts.setHours(12, 0, 0, 0);
      result.push({
        day: k,
        timestamp: ts.toISOString(),
        value: avg,
        dataPoints: b?.count || 0,
      } as ChartDataPoint);
      cursor.setDate(cursor.getDate() + 1);
    }

    return result;
  } catch (err) {
    console.error("Failed to fetch custom range data:", err);
    return [];
  }
};
/**
 * Export to PDF with professional formatting
 */
const exportToPdf = async (
  chartData: ChartDataPoint[],
  xKey: string,
  title: string,
  options: ExportOptions,
  chartRef?: React.RefObject<HTMLDivElement | null>
) => {
  try {
    const config = CHART_CONFIGS[options.chartType as keyof typeof CHART_CONFIGS];
    const pdf = new jsPDF("portrait", "mm", "a4");
    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();
    const margin = 20;
    const contentWidth = pageWidth - (margin * 2);
    
    let yCursor = margin;
    
    // Add Maize Watch logo (try multiple public paths)
    {
      const dataUrl = await loadLogoDataUrl();
      if (dataUrl) {
        const logoWidth = 40; // mm
        const logoHeight = 12; // tuned height
        const logoX = (pageWidth - logoWidth) / 2;
        pdf.addImage(dataUrl, 'PNG', logoX, yCursor, logoWidth, logoHeight, undefined, 'FAST');
        // Extra space between logo and title
        yCursor += logoHeight + 10;
      } else {
        console.warn('maizewatch.png not found in public paths');
        yCursor += 8;
      }
    }
    
    // Add report header
    pdf.setFontSize(20);
    // Maize Watch green #456C2D
    pdf.setTextColor(69, 108, 45);
    pdf.text(config.title, pageWidth / 2, yCursor, { align: "center" });
    yCursor += 10;
    
    // Add report metadata
    pdf.setFontSize(12);
    pdf.setTextColor(75, 85, 99);
    
    // Date range information
    let dateRangeText = `Report`;
    
    if (options.customDateRange) {
      const start = new Date(options.customDateRange.startDate).toLocaleDateString();
      const end = new Date(options.customDateRange.endDate).toLocaleDateString();
      dateRangeText += ` - Custom Range: ${start} to ${end}`;
    } else if (options.exportType === 'predefined' && options.dateRange && options.dateRange.from && options.dateRange.to) {
      const start = new Date(options.dateRange.from).toLocaleDateString();
      const end = new Date(options.dateRange.to).toLocaleDateString();
      dateRangeText += ` - ${start} to ${end}`;
    } else if (options.timeFrame) {
      const range = calculatePredefinedRange(options.timeFrame);
      dateRangeText += ` - Last ${options.timeFrame} (${range.start.toLocaleDateString()} to ${range.end.toLocaleDateString()})`;
    } else if (options.dateRange && options.dateRange.from && options.dateRange.to) {
      const start = new Date(options.dateRange.from).toLocaleDateString();
      const end = new Date(options.dateRange.to).toLocaleDateString();
      dateRangeText += ` - ${start} to ${end}`;
    }
    
    pdf.text(dateRangeText, pageWidth / 2, yCursor, { align: "center" });
    yCursor += 8;
    
    // Generation timestamp
    const generatedAt = `Generated on ${formatDateForDisplay(new Date())}`;
    pdf.text(generatedAt, pageWidth / 2, yCursor, { align: "center" });
    yCursor += 20;
    
    // Add chart image if requested
    if (options.includeChartImage && chartRef?.current) {
      try {
        const chartImgData = await htmlToImage.toPng(chartRef.current, { 
          backgroundColor: "white", 
          quality: 1.0,
          width: 800,
          height: 400
        });
        const imgProps = pdf.getImageProperties(chartImgData);
        const imgWidth = contentWidth;
        const imgHeight = (imgProps.height * imgWidth) / imgProps.width;
        
        // Check if chart will fit on current page
        if (yCursor + imgHeight + 30 > pageHeight - 50) {
          pdf.addPage();
          yCursor = margin;
        }
        
        // Add chart title
        pdf.setFontSize(14);
        pdf.setTextColor(55, 65, 81);
        pdf.text("Chart Visualization", margin, yCursor);
        yCursor += 8;
        
        pdf.addImage(chartImgData, "PNG", margin, yCursor, imgWidth, imgHeight);
        yCursor += imgHeight + 20;
      } catch (err) {
        console.error("Error rendering chart image for PDF:", err);
      }
    }
    
    // Calculate statistics
    const stats = calculateStatistics(chartData);
    
    // Add statistics section
    if (stats) {
      // Check if we need a new page for statistics
      if (yCursor + 60 > pageHeight - 50) {
        pdf.addPage();
        yCursor = margin;
      }
      
      pdf.setFontSize(14);
      pdf.setTextColor(55, 65, 81);
      pdf.text("Summary Statistics", margin, yCursor);
      yCursor += 12;
      
      pdf.setFontSize(11);
      pdf.setTextColor(75, 85, 99);
      
      const statY = yCursor;
      pdf.text(`Average: ${stats.average.toFixed(2)} ${config.unit}`, margin, statY);
      pdf.text(`Minimum: ${stats.min.toFixed(2)} ${config.unit}`, margin + 70, statY);
      pdf.text(`Maximum: ${stats.max.toFixed(2)} ${config.unit}`, margin + 140, statY);
      yCursor += 8;
      
      pdf.text(`Total Records: ${stats.count}`, margin, yCursor);
      if (stats.count > 0) {
        pdf.text(`Sum: ${stats.total.toFixed(2)} ${config.unit}`, margin + 70, yCursor);
      }
      yCursor += 20;
    }
    
    // Add tabular data if requested
    if (options.includeTabularData && chartData.length > 0) {
      // Check if we need a new page for table
      if (yCursor + 40 > pageHeight - 50) {
        pdf.addPage();
        yCursor = margin;
      }
      
      pdf.setFontSize(14);
      pdf.setTextColor(55, 65, 81);
      pdf.text("Detailed Data", margin, yCursor);
      yCursor += 12;
      
      // Table settings
      const startY = yCursor;
      const rowHeight = 8;
      const headers = ["Period", `${config.fieldName} (${config.unit})`];
      const columnWidths = [contentWidth * 0.6, contentWidth * 0.4];
      
      // Draw table header
      pdf.setFillColor(240, 240, 240);
      pdf.setDrawColor(0, 0, 0);
      pdf.setLineWidth(0.2);
      pdf.rect(margin, startY, contentWidth, rowHeight, 'FD');
      
      // Add header text
      pdf.setFontSize(10);
      pdf.setTextColor(0, 0, 0);
      let xPos = margin;
      
      headers.forEach((header, index) => {
        pdf.text(header, xPos + 2, startY + 5.5);
        xPos += columnWidths[index];
      });
      
      // Draw table rows (limit to first 30 rows for better fit)
      let yPos = startY + rowHeight;
      const dataToShow = chartData.slice(0, 30);
      
      dataToShow.forEach((dataPoint, index) => {
        // Check if we need a new page
        if (yPos + rowHeight > pageHeight - 30) {
          pdf.addPage();
          yPos = margin;
          
          // Draw header on new page
          pdf.setFillColor(240, 240, 240);
          pdf.rect(margin, yPos, contentWidth, rowHeight, 'FD');
          
          xPos = margin;
          pdf.setFontSize(10);
          headers.forEach((header, index) => {
            pdf.text(header, xPos + 2, yPos + 5.5);
            xPos += columnWidths[index];
          });
          
          yPos += rowHeight;
        }
        
        // Draw row background
        pdf.setFillColor(index % 2 === 0 ? 255 : 248, index % 2 === 0 ? 255 : 248, index % 2 === 0 ? 255 : 248);
        pdf.rect(margin, yPos, contentWidth, rowHeight, 'FD');
        
        // Add row data
        xPos = margin;
        pdf.setFontSize(9);
        
        // Period value
        const periodValue = dataPoint[xKey] || dataPoint.day || dataPoint.week || dataPoint.month || 'N/A';
        pdf.text(String(periodValue), xPos + 2, yPos + 5.5);
        xPos += columnWidths[0];
        
        // Value
        const value = dataPoint.value;
        const valueText = value !== null ? `${value.toFixed(1)} ${config.unit}` : 'N/A';
        pdf.text(valueText, xPos + 2, yPos + 5.5);
        
        yPos += rowHeight;
      });
      
      // Add note if data was truncated
      if (chartData.length > 30) {
        if (yPos + 10 > pageHeight - 30) {
          pdf.addPage();
          yPos = margin;
        }
        pdf.setFontSize(8);
        pdf.setTextColor(107, 114, 128);
        pdf.text(`Note: Showing first 30 of ${chartData.length} records. Full data available in CSV export.`, margin, yPos + 5);
      }
    }
    
    // Add footer on the last page
    const footerY = pageHeight - 15;
    pdf.setFontSize(8);
    pdf.setTextColor(107, 114, 128);
    pdf.text("Maize Watch - Smart Agriculture Monitoring System", pageWidth / 2, footerY);
    
    // Save the PDF with standardized filename
    const filename = generateFilename(options.chartType, 'pdf', options);
    pdf.save(filename);
  } catch (error) {
    console.error("Error exporting to PDF:", error);
    throw error;
  }
};


/**
 * Export to SVG with professional formatting
 */
const exportToSvg = async (chartNode: HTMLElement, options: ExportOptions) => {
  try {
    // Generate SVG with proper styling and metadata
    const dataUrl = await htmlToImage.toSvg(chartNode, {
      quality: 1.0,
      backgroundColor: "white",
      width: 1200,
      height: 600
    });
    
    // Create download link with standardized filename
    const link = document.createElement("a");
    const filename = generateFilename(options.chartType, 'svg', options);
    link.download = filename;
    link.href = dataUrl;
    link.click();
  } catch (error) {
    console.error("Error exporting to SVG:", error);
    throw error;
  }
};

/**
 * Export to CSV with professional formatting and restored statistics
 */
const exportToCsv = (chartData: ChartDataPoint[], options: ExportOptions) => {
  try {
    const config = CHART_CONFIGS[options.chartType as keyof typeof CHART_CONFIGS];
    
    // Determine xKey based on current overview
    const xKey = options.currentOverview === 'hourly' ? 'hour' : 
                 options.currentOverview === 'daily' ? 'day' : 
                 options.currentOverview === 'weekly' ? 'week' : 'month';
    
    // Calculate statistics first
    const stats = calculateStatistics(chartData);
    
    // Create the main data rows
    const dataRows = chartData.map(item => {
      // Format date properly for CSV
      let periodValue = item[xKey] || item.day || item.week || item.month || 'N/A';
      
      // If it's a date string, format it properly
      if (periodValue && typeof periodValue === 'string') {
        // Check if it's a date string (YYYY-MM-DD format)
        if (/^\d{4}-\d{2}-\d{2}$/.test(periodValue)) {
          const date = new Date(periodValue + 'T00:00:00');
          periodValue = date.toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: '2-digit', 
            day: '2-digit' 
          });
        }
        // If it's an ISO timestamp, format it as date
        else if (item.timestamp && typeof item.timestamp === 'string') {
          const date = new Date(item.timestamp);
          periodValue = date.toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: '2-digit', 
            day: '2-digit' 
          });
        }
      }
      
      const value = item.value;
      const valueText = value !== null ? value.toFixed(2) : 'N/A';
      const csvRow: Record<string, string> = {
        [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: String(periodValue),
        [`${config.fieldName} (${config.unit})`]: valueText
      };
      // Removed Data Points column as requested
      return csvRow;
    });

    // Create comprehensive summary section
    const summaryRows = [
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '=================================' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'MAIZE WATCH EXPORT SUMMARY' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '=================================' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'REPORT DETAILS:' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Sensor Type: ${config.fieldName}` },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Export Format: CSV` }
    ];

    // Add export-specific range information
    if (options.exportType === 'custom' && options.customDateRange) {
      const start = new Date(options.customDateRange.startDate);
      const end = new Date(options.customDateRange.endDate);
      summaryRows.push(
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Export Type: Custom Date Range` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Start Date: ${start.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `End Date: ${end.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Range Duration: ${Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24))} days` }
      );
    } else if (options.exportType === 'predefined') {
      // Prefer chart's current dateRange if provided to match UI "Current Chart Info"
      if (options.dateRange && options.dateRange.from && options.dateRange.to) {
        const start = new Date(options.dateRange.from);
        const end = new Date(options.dateRange.to);
        summaryRows.push(
          { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Export Type: Predefined Range` },
          { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Start Date: ${start.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}` },
          { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `End Date: ${end.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}` }
        );
      } else if (options.timeFrame) {
        const range = calculatePredefinedRange(options.timeFrame);
        summaryRows.push(
          { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Export Type: Predefined Range` },
          { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Time Frame: Last ${options.timeFrame}` },
          { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Start Date: ${range.start.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}` },
          { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `End Date: ${range.end.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}` }
        );
      }
    } else if (options.dateRange && options.dateRange.from && options.dateRange.to) {
      summaryRows.push(
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Export Type: Chart Default Range` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Date Range: ${options.dateRange.from} to ${options.dateRange.to}` }
      );
    }

    // Add generation info
    summaryRows.push(
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'GENERATION INFO:' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Generated: ${formatDateForDisplay(new Date())}` },
     
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' }
    );
    
    // Add comprehensive statistics if available
    if (stats) {
      summaryRows.push(
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '=================================' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'STATISTICAL ANALYSIS' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '=================================' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'DATA OVERVIEW:' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Total Data Records: ${chartData.length}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Valid Measurements: ${stats.count}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Missing/Invalid: ${chartData.length - stats.count}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Data Completeness: ${((stats.count / chartData.length) * 100).toFixed(1)}%` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'MEASUREMENT STATISTICS:' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Average ${config.fieldName}: ${stats.average.toFixed(3)} ${config.unit}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Minimum ${config.fieldName}: ${stats.min.toFixed(3)} ${config.unit}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Maximum ${config.fieldName}: ${stats.max.toFixed(3)} ${config.unit}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Total Sum: ${stats.total.toFixed(3)} ${config.unit}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Range (Max - Min): ${(stats.max - stats.min).toFixed(3)} ${config.unit}` }
      );

      // Remove threshold/status sections per request
    }

    
    
    // Combine data and summary
    const csvData = [...dataRows, ...summaryRows];
    
    // Use PapaParse for robust CSV handling
    const csv = Papa.unparse(csvData, {
      header: true,
      delimiter: ',',
      quotes: true,
      quoteChar: '"',
      escapeChar: '"'
    });
    
    // Create download link with standardized filename
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    const filename = generateFilename(options.chartType, 'csv', options);
    link.download = filename;
    link.href = url;
    link.click();
    
    // Clean up
    setTimeout(() => {
      URL.revokeObjectURL(url);
    }, 100);
  } catch (error) {
    console.error("Error exporting to CSV:", error);
    throw error;
  }
};

/**
 * Main unified export function
 */
const exportChartData = async (
  chartData: ChartDataPoint[],
  options: ExportOptions,
  format: 'pdf' | 'svg' | 'csv',
  chartRef?: React.RefObject<HTMLDivElement | null>
) => {
  try {
    console.log('Export Options:', options);
    console.log('Original Chart Data:', chartData);
    
    const config = CHART_CONFIGS[options.chartType as keyof typeof CHART_CONFIGS];
    const xKey = options.currentOverview === 'hourly' ? 'hour' : 
                 options.currentOverview === 'daily' ? 'day' : 
                 options.currentOverview === 'weekly' ? 'week' : 'month';
    
    let processedData: ChartDataPoint[] = [];

    if (options.exportType === 'custom' && options.customDateRange) {
      const startISO = new Date(options.customDateRange.startDate).toISOString();
      const endDate = new Date(options.customDateRange.endDate);
      endDate.setHours(23, 59, 59, 999);
      const endISO = endDate.toISOString();
      const fetched = await fetchCustomRangeData(options.chartType, startISO, endISO);
      processedData = fetched.length > 0 ? fetched : chartData;
    } else {
      // Create filtered/synthetic data based on export modal selections
      const { data } = createFilteredDataForExport(chartData, options);
      processedData = data;
    }
    
    console.log('Processed Data for Export:', processedData);
    console.log('Export Format:', format);

    switch (format) {
      case 'pdf':
        await exportToPdf(processedData, xKey, config.title, options, chartRef);
        break;
      case 'svg':
        if (chartRef?.current) {
          await exportToSvg(chartRef.current, options);
        } else {
          throw new Error('Chart reference is required for SVG export');
        }
        break;
      case 'csv':
        exportToCsv(processedData, options);
        break;
      default:
        throw new Error(`Unsupported format: ${format}`);
    }
  } catch (error) {
    console.error('Export failed:', error);
    throw error;
  }
};

export type { ChartDataPoint, ExportOptions };
export { exportChartData };
