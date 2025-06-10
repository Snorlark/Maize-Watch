import React from "react";
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

// Helper function to get status based on thresholds
const getStatus = (value: number, thresholds: { min: number; max: number; critical: number }): string => {
  if (value < thresholds.min) return "Low";
  if (value > thresholds.max) return "High";
  if (value > thresholds.critical) return "Critical";
  return "Normal";
};

// Helper function to generate standardized filename
const generateFilename = (chartType: string, format: string, overview: string, dateRange?: DateRange, customRange?: { startDate: Date; endDate: Date }) => {
  const config = CHART_CONFIGS[chartType as keyof typeof CHART_CONFIGS];
  const shortName = config.shortName;
  const now = new Date();
  const timestamp = now.toISOString().split('T')[0]; // YYYY-MM-DD
  
  let period = overview;
  if (customRange) {
    const start = customRange.startDate.toISOString().split('T')[0];
    const end = customRange.endDate.toISOString().split('T')[0];
    period = `${start}_to_${end}`;
  } else if (dateRange && dateRange.from && dateRange.to) {
    period = `${dateRange.from}_to_${dateRange.to}`;
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
    const config = CHART_CONFIGS[options.chartType];
    const pdf = new jsPDF("portrait", "mm", "a4");
    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();
    const margin = 20;
    const contentWidth = pageWidth - (margin * 2);
    
    let yCursor = margin;
    
    // Add Maize Watch logo
    try {
      const logoWidth = 50;
      const logoX = margin;
      pdf.addImage("/maizewatch.png", "PNG", logoX, yCursor, logoWidth, 12);
      yCursor += 20;
    } catch (error) {
      console.warn("Could not add logo to PDF:", error);
      yCursor += 15;
    }
    
    // Add report header
    pdf.setFontSize(20);
    pdf.setTextColor(37, 99, 235);
    pdf.text(title, pageWidth / 2, yCursor, { align: "center" });
    yCursor += 10;
    
    // Add report metadata
    pdf.setFontSize(12);
    pdf.setTextColor(75, 85, 99);
    
    // Date range information
    let dateRangeText = `${options.currentOverview.charAt(0).toUpperCase() + options.currentOverview.slice(1)} Report`;
    if (options.dateRange && options.dateRange.from && options.dateRange.to) {
      dateRangeText += ` - ${options.dateRange.from} to ${options.dateRange.to}`;
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
    
    // Add statistics section with proper spacing
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
      
      // Statistics in a more compact layout
      const statY = yCursor;
      pdf.text(`Average: ${stats.average.toFixed(2)} ${config.unit}`, margin, statY);
      pdf.text(`Minimum: ${stats.min.toFixed(2)} ${config.unit}`, margin + 70, statY);
      pdf.text(`Maximum: ${stats.max.toFixed(2)} ${config.unit}`, margin + 140, statY);
      yCursor += 8;
      
      pdf.text(`Total Records: ${stats.count}`, margin, yCursor);
      pdf.text(`Sum: ${stats.total.toFixed(2)} ${config.unit}`, margin + 70, yCursor);
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
      const headers = [
        xKey.charAt(0).toUpperCase() + xKey.slice(1), 
        `${config.fieldName} (${config.unit})`, 
        "Status"
      ];
      const columnWidths = [contentWidth * 0.3, contentWidth * 0.5, contentWidth * 0.2];
      
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
      
      // Draw table rows (limit to first 25 rows for better fit)
      let yPos = startY + rowHeight;
      const dataToShow = chartData.slice(0, 25);
      
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
      });
      
      // Add note if data was truncated
      if (chartData.length > 25) {
        if (yPos + 10 > pageHeight - 30) {
          pdf.addPage();
          yPos = margin;
        }
        pdf.setFontSize(8);
        pdf.setTextColor(107, 114, 128);
        pdf.text(`Note: Showing first 25 of ${chartData.length} records. Full data available in CSV export.`, margin, yPos + 5);
      }
    }
    
    // Add footer on the last page
    const footerY = pageHeight - 15;
    pdf.setFontSize(8);
    pdf.setTextColor(107, 114, 128);
    pdf.text("Maize Watch - Smart Agriculture Monitoring System", pageWidth / 2, footerY, { align: "center" });
    
    // Save the PDF with standardized filename
    const filename = generateFilename(options.chartType, 'pdf', options.currentOverview, options.dateRange, undefined);
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
    const filename = generateFilename(options.chartType, 'svg', options.currentOverview, options.dateRange, undefined);
    link.download = filename;
    link.href = dataUrl;
    link.click();
  } catch (error) {
    console.error("Error exporting to SVG:", error);
    throw error;
  }
};

/**
 * Export to CSV with professional formatting
 */
const exportToCsv = (chartData: ChartDataPoint[], options: ExportOptions) => {
  try {
    const config = CHART_CONFIGS[options.chartType];
    
    // Determine xKey based on current overview
    const xKey = options.currentOverview === 'hourly' ? 'hour' : 
                 options.currentOverview === 'daily' ? 'day' : 
                 options.currentOverview === 'weekly' ? 'week' : 'month';
    
    // Create the main data rows
    const dataRows = chartData.map(item => {
      const xValue = item[xKey] || item.timestamp || '';
      const value = item.value;
      const valueText = value !== null ? value.toFixed(2) : 'N/A';
      
      const csvRow: Record<string, string> = {
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
    
    // Calculate statistics
    const stats = calculateStatistics(chartData);
    
    // Create summary analytics section
    const summaryRows = [
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'SUMMARY ANALYTICS' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'Report Details' },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Chart Type: ${config.title}` },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Period: ${options.currentOverview.charAt(0).toUpperCase() + options.currentOverview.slice(1)}` },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Year: ${new Date().getFullYear()}` },
      { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Generated: ${formatDateForDisplay(new Date())}` }
    ];
    
    // Add date range if available
    if (options.dateRange && options.dateRange.from && options.dateRange.to) {
      summaryRows.push({ [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Date Range: ${options.dateRange.from} to ${options.dateRange.to}` });
    }
    
    summaryRows.push({ [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: '' });
    
    // Add statistics if available
    if (stats) {
      summaryRows.push(
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: 'Statistics' },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Total Records: ${stats.count}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Average ${config.fieldName}: ${stats.average.toFixed(2)} ${config.unit}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Minimum ${config.fieldName}: ${stats.min.toFixed(2)} ${config.unit}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Maximum ${config.fieldName}: ${stats.max.toFixed(2)} ${config.unit}` },
        { [xKey.charAt(0).toUpperCase() + xKey.slice(1)]: `Sum ${config.fieldName}: ${stats.total.toFixed(2)} ${config.unit}` }
      );
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
    const filename = generateFilename(options.chartType, 'csv', options.currentOverview, options.dateRange, undefined);
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
    
    switch (format) {
      case 'pdf':
        await exportToPdf(chartData, xKey, config.title, options, chartRef);
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