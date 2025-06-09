import React from "react";
import { jsPDF } from "jspdf";
import * as htmlToImage from "html-to-image";
import Papa from "papaparse";

// Types
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
}

type DateRange = {
  from: string;
  to: string;
} | null;

interface ExportOptions {
  format: 'pdf' | 'csv' | 'svg';
  chartType: 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity';
  currentOverview: 'hourly' | 'daily' | 'weekly' | 'monthly';
  dateRange?: DateRange;
  customDateRange?: {
    startDate: Date;
    endDate: Date;
  };
}

// Chart type configurations
const CHART_CONFIGS = {
  temperature: {
    title: 'Temperature Dashboard',
    unit: '°C',
    fieldName: 'Temperature',
    color: '#F97316',
    thresholds: { min: 20, max: 30, critical: 35 }
  },
  humidity: {
    title: 'Humidity Dashboard',
    unit: '%',
    fieldName: 'Humidity',
    color: '#3B82F6',
    thresholds: { min: 40, max: 80, critical: 90 }
  },
  soilMoisture: {
    title: 'Soil Moisture Dashboard',
    unit: '%',
    fieldName: 'Soil Moisture',
    color: '#8B5CF6',
    thresholds: { min: 30, max: 70, critical: 80 }
  },
  soilPh: {
    title: 'Soil pH Level Dashboard',
    unit: 'pH',
    fieldName: 'Soil pH',
    color: '#10B981',
    thresholds: { min: 6.0, max: 7.5, critical: 8.0 }
  },
  lightIntensity: {
    title: 'Light Intensity Dashboard',
    unit: 'lux',
    fieldName: 'Light Intensity',
    color: '#F59E0B',
    thresholds: { min: 1000, max: 50000, critical: 100000 }
  }
};

/**
 * Calculate statistics for the data
 */
const calculateStatistics = (data: ChartDataPoint[]) => {
  const validData = data.filter(item => item.value !== null && !isNaN(item.value as number));
  if (validData.length === 0) return null;

  const values = validData.map(item => item.value as number);
  return {
    average: values.reduce((a, b) => a + b, 0) / values.length,
    min: Math.min(...values),
    max: Math.max(...values),
    count: validData.length
  };
};

/**
 * Get status based on value and thresholds
 */
const getStatus = (value: number, thresholds: { min: number; max: number; critical: number }): string => {
  if (value < thresholds.min) return "Too Low";
  if (value > thresholds.critical) return "Critical";
  if (value > thresholds.max) return "Too High";
  return "Normal";
};

/**
 * Export to PDF with Maize Watch branding
 */
const exportToPdf = async (
  chartData: ChartDataPoint[],
  xKey: string,
  title: string,
  dateRange: DateRange
) => {
  try {
    const config = CHART_CONFIGS[xKey as 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity'];
    const pdf = new jsPDF("portrait", "mm", "a4");
    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();
    
    // Add Maize Watch logo
    try {
      const logoWidth = 60;
      const logoX = (pageWidth - logoWidth) / 2;
      pdf.addImage("/maizewatch.png", "PNG", logoX, 10, logoWidth, 15);
    } catch (error) {
      console.error("Error adding logo:", error);
    }
    
    // Add title and metadata
    pdf.setFontSize(18);
    pdf.setTextColor(37, 99, 235);
    pdf.text(title, pageWidth / 2, 35, { align: "center" });
    
    // Add date range information
    pdf.setFontSize(12);
    pdf.setTextColor(75, 85, 99);
    let dateRangeText = `${xKey.charAt(0).toUpperCase() + xKey.slice(1)} View`;
    
    if (dateRange) {
      const { from, to } = dateRange;
      dateRangeText += ` - ${from} to ${to}`;
    }
    
    pdf.text(dateRangeText, pageWidth / 2, 42, { align: "center" });
    
    // Add timestamp
    const now = new Date();
    pdf.setFontSize(10);
    pdf.setTextColor(107, 114, 128);
    pdf.text(`Generated: ${now.toLocaleString()}`, pageWidth - 15, pageHeight - 10, { align: "right" });
    
    // Calculate statistics
    const stats = calculateStatistics(chartData);
    
    // Table settings
    const startY = 55;
    const margin = 15;
    const availableWidth = pageWidth - (margin * 2);
    
    const headers = [xKey.charAt(0).toUpperCase() + xKey.slice(1), `${config.fieldName} (${config.unit})`, "Status"];
    const columnWidths = [availableWidth * 0.4, availableWidth * 0.4, availableWidth * 0.2];
    
    const rowHeight = 8;
    
    // Draw table header
    pdf.setFillColor(240, 240, 240);
    pdf.setDrawColor(0, 0, 0);
    pdf.setLineWidth(0.1);
    pdf.rect(margin, startY, availableWidth, rowHeight, 'FD');
    
    // Add header text
    pdf.setFontSize(10);
    pdf.setTextColor(0, 0, 0);
    let xPos = margin;
    
    headers.forEach((header, index) => {
      pdf.text(header, xPos + 2, startY + 5.5);
      xPos += columnWidths[index];
    });
    
    // Draw table rows
    let yPos = startY + rowHeight;
    const dataToShow = chartData.slice(0, 50);
    
    dataToShow.forEach((dataPoint, index) => {
      // Draw row background
      pdf.setFillColor(index % 2 === 0 ? 255 : 248, index % 2 === 0 ? 255 : 248, index % 2 === 0 ? 255 : 248);
      pdf.rect(margin, yPos, availableWidth, rowHeight, 'FD');
      
      // Add row data
      xPos = margin;
      pdf.setFontSize(9);
      
      // X-axis value
      const xValue = dataPoint[xKey] || dataPoint.timestamp || '';
      pdf.text(String(xValue), xPos + 2, yPos + 5.5);
      xPos += columnWidths[0];
      
      // Value
      const value = dataPoint.value;
      const valueText = value !== null ? `${value.toFixed(1)} ${config.unit}` : 'N/A';
      pdf.text(valueText, xPos + 2, yPos + 5.5);
      xPos += columnWidths[1];
      
      // Status
      if (value !== null && dataPoint.threshold) {
        const status = getStatus(value, dataPoint.threshold);
        pdf.text(status, xPos + 2, yPos + 5.5);
      } else {
        pdf.text('N/A', xPos + 2, yPos + 5.5);
      }
      
      yPos += rowHeight;
      
      // Add new page if needed
      if (yPos > (pageHeight - 30) && index < dataToShow.length - 1) {
        pdf.addPage();
        yPos = 20;
        
        // Draw header on new page
        pdf.setFillColor(240, 240, 240);
        pdf.rect(margin, yPos, availableWidth, rowHeight, 'FD');
        
        xPos = margin;
        pdf.setFontSize(10);
        headers.forEach((header, index) => {
          pdf.text(header, xPos + 2, yPos + 5.5);
          xPos += columnWidths[index];
        });
        
        yPos += rowHeight;
      }
    });
    
    // Add statistics if available
    if (stats) {
      const statsY = yPos + 10;
      pdf.setFontSize(12);
      pdf.setTextColor(75, 85, 99);
      pdf.text('Statistics:', margin, statsY);
      pdf.setFontSize(10);
      pdf.text(`Average: ${stats.average.toFixed(2)} ${config.unit}`, margin, statsY + 8);
      pdf.text(`Minimum: ${stats.min.toFixed(2)} ${config.unit}`, margin, statsY + 16);
      pdf.text(`Maximum: ${stats.max.toFixed(2)} ${config.unit}`, margin, statsY + 24);
      pdf.text(`Data Points: ${stats.count}`, margin, statsY + 32);
    }
    
    // Add note if data was truncated
    if (chartData.length > 50) {
      pdf.setFontSize(8);
      pdf.text(`(Showing 50 of ${chartData.length} data points)`, margin, yPos + 5);
    }
    
    // Save the PDF
    const filename = `${xKey}-dashboard-${dateRange ? `${dateRange.from}-${dateRange.to}` : 'all'}-${new Date().toISOString().split('T')[0]}.pdf`;
    pdf.save(filename);
  } catch (error) {
    console.error("Error exporting to PDF:", error);
    throw error;
  }
};

/**
 * Export to SVG with metadata
 */
const exportToSvg = async (chartNode: HTMLElement, options: ExportOptions) => {
  try {
    // Generate SVG with proper styling
    const dataUrl = await htmlToImage.toSvg(chartNode, {
      quality: 1.0,
      backgroundColor: "white"
    });
    
    // Create download link
    const link = document.createElement("a");
    const filename = `${options.chartType}-chart-${options.currentOverview}-${new Date().toISOString().split('T')[0]}.svg`;
    link.download = filename;
    link.href = dataUrl;
    link.click();
  } catch (error) {
    console.error("Error exporting to SVG:", error);
    throw error;
  }
};

/**
 * Export to CSV with proper formatting
 */
const exportToCsv = (chartData: ChartDataPoint[], options: ExportOptions) => {
  try {
    const config = CHART_CONFIGS[options.chartType];
    
    // Determine xKey based on current overview
    const xKey = options.currentOverview === 'hourly' ? 'hour' : 
                 options.currentOverview === 'daily' ? 'day' : 
                 options.currentOverview === 'weekly' ? 'week' : 'month';
    
    // Convert data to CSV format
    const csvData = chartData.map(item => {
      const xValue = item[xKey] || item.timestamp || '';
      const value = item.value;
      const valueText = value !== null ? value.toFixed(1) : 'N/A';
      
      const csvRow: any = {
        [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: xValue,
        [`${config.fieldName} (${config.unit})`]: valueText
      };
      
      if (value !== null && item.threshold) {
        csvRow['Status'] = getStatus(value, item.threshold);
      } else {
        csvRow['Status'] = 'N/A';
      }
      
      return csvRow;
    });
    
    // Add statistics if available
    const stats = calculateStatistics(chartData);
    if (stats) {
      csvData.push(
        {},
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'Statistics' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'Average', [`${config.fieldName} (${config.unit})`]: stats.average.toFixed(2) },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'Minimum', [`${config.fieldName} (${config.unit})`]: stats.min.toFixed(2) },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'Maximum', [`${config.fieldName} (${config.unit})`]: stats.max.toFixed(2) },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'Data Points', [`${config.fieldName} (${config.unit})`]: stats.count.toString() }
      );
    }
    
    // Use PapaParse for robust CSV handling
    const csv = Papa.unparse(csvData);
    
    // Create download link
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    const filename = `${options.chartType}-data-${options.currentOverview}-${new Date().toISOString().split('T')[0]}.csv`;
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
    const config = CHART_CONFIGS[options.chartType];
    const xKey = options.currentOverview === 'hourly' ? 'hour' : 
                 options.currentOverview === 'daily' ? 'day' : 
                 options.currentOverview === 'weekly' ? 'week' : 'month';
    
    const dateRange = options.dateRange || { from: '', to: '' };
    
    switch (format) {
      case 'pdf':
        await exportToPdf(chartData, xKey, config.title, dateRange);
        break;
      case 'svg':
        if (chartRef?.current) {
          await exportToSvg(chartRef.current, options);
        } else {
          throw new Error('Chart reference is required for SVG export');
        }
        break;
      case 'csv':
        exportToCsv(chartData, options);
        break;
      default:
        throw new Error(`Unsupported format: ${format}`);
    }
  } catch (error) {
    console.error('Export failed:', error);
    throw error;
  }
};

export type { ChartDataPoint, DateRange, ExportOptions };
export { exportChartData }; 