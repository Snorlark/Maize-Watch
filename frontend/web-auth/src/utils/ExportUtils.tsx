import { jsPDF } from "jspdf";
import * as htmlToImage from "html-to-image";
import Papa from "papaparse";

type ChartDataPoint = {
  [key: string]: string | number;
  value: number;
};

type DateRange = {
  from: string;
  to: string;
} | null;

// Map of months to their numerical representation
const MONTH_MAP: Record<string, number> = {
  "Jan": 0, "Feb": 1, "Mar": 2, "Apr": 3, "May": 4, "Jun": 5, 
  "Jul": 6, "Aug": 7, "Sep": 8, "Oct": 9, "Nov": 10, "Dec": 11
};

// Map of days to their numerical representation (Sunday = 0)
const DAY_MAP: Record<string, number> = {
  "Sunday": 0, "Monday": 1, "Tuesday": 2, "Wednesday": 3, 
  "Thursday": 4, "Friday": 5, "Saturday": 6
};

/**
 * Parse date string to Date object based on different formats
 * @param dateStr The date string to parse
 * @param dataType The type of data (days, weeks, months, years)
 * @param referenceDate Optional reference date for relative formats
 * @returns Date object or null if parsing fails
 */
export const parseDateString = (
  dateStr: string | number,
  dataType: string = "unknown",
  referenceDate?: Date
): Date | null => {
  if (typeof dateStr !== 'string') {
    return null;
  }
  
  const ref = referenceDate || new Date();
  const currentYear = ref.getFullYear();
  
  // Try different date formats based on data type
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
    // ISO date format (YYYY-MM-DD)
    return new Date(dateStr);
  } else if (/^\d{4}$/.test(dateStr)) {
    // Year only (e.g., "2023")
    return new Date(parseInt(dateStr, 10), 0, 1);
  } else if (Object.keys(MONTH_MAP).includes(dateStr)) {
    // Month name (e.g., "Jan")
    return new Date(currentYear, MONTH_MAP[dateStr], 1);
  } else if (/^Week \d+$/.test(dateStr)) {
    // Week format (e.g., "Week 1")
    const weekNum = parseInt(dateStr.replace("Week ", ""), 10);
    // Calculate first day of the week
    return new Date(currentYear, 0, 1 + (weekNum - 1) * 7);
  } else if (Object.keys(DAY_MAP).includes(dateStr)) {
    // Day of week (e.g., "Monday")
    const today = new Date(ref);
    const dayDiff = DAY_MAP[dateStr] - today.getDay();
    today.setDate(today.getDate() + (dayDiff >= 0 ? dayDiff : dayDiff + 7));
    return today;
  }
  
  // Try generic date parsing as fallback
  const fallbackDate = new Date(dateStr);
  if (!isNaN(fallbackDate.getTime())) {
    return fallbackDate;
  }
  
  return null;
};

/**
 * Maps a date to a data point key based on the data type
 * @param date The date to map
 * @param dataType The type of chart data (days, weeks, months, years)
 * @returns The key that would be used in the data for this date
 */
export const mapDateToDataKey = (date: Date, dataType: string): string => {
  switch (dataType) {
    case "days":
      const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
      return days[date.getDay()];
    case "weeks":
      // Calculate week number (approximate)
      const startOfYear = new Date(date.getFullYear(), 0, 1);
      const days_passed = Math.floor((date.getTime() - startOfYear.getTime()) / (24 * 60 * 60 * 1000));
      const weekNum = Math.ceil((days_passed + startOfYear.getDay() + 1) / 7);
      return `Week ${weekNum}`;
    case "months":
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return months[date.getMonth()];
    case "years":
      return date.getFullYear().toString();
    default:
      // Try to format as ISO date for unknown types
      return date.toISOString().split('T')[0];
  }
};

/**
 * Exports chart as a PDF document with a table format and logo
 */
const exportToPdf = async (
  chartNode: HTMLElement,
  chartData: ChartDataPoint[],
  xKey: string,
  title: string,
  dateRange: DateRange
) => {
  try {
    // Create PDF document
    const pdf = new jsPDF("portrait", "mm", "a4");
    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();
    
    // Add logo at the top middle part (use try-catch in case the image is not available)
    try {
      const logoWidth = 60; // mm
      const logoX = (pageWidth - logoWidth) / 2; // Center the logo
      pdf.addImage("maizewatch.png", "PNG", logoX, 10, logoWidth, 15);
    } catch (error) {
      console.error("Error adding logo:", error);
    }
    
    // Add title and metadata (position it below the logo)
    pdf.setFontSize(16);
    pdf.text(title, pageWidth / 2, 35, { align: "center" });
    
    // Add date range if provided
    if (dateRange && dateRange.from && dateRange.to) {
      pdf.setFontSize(10);
      const from = new Date(dateRange.from).toLocaleDateString();
      const to = new Date(dateRange.to).toLocaleDateString();
      pdf.text(`Date Range: ${from} to ${to}`, pageWidth / 2, 42, { align: "center" });
    }
    
    // Add timestamp
    const now = new Date();
    pdf.setFontSize(8);
    pdf.text(`Generated: ${now.toLocaleString()}`, pageWidth - 15, pageHeight - 10, { align: "right" });
    
    // Check if we have day/date information from custom export
    const hasCustomDayDate = chartData.length > 0 && 'dayName' in chartData[0] && 'date' in chartData[0];
    
    // Table settings
    const startY = 50; // Start position for the table
    const margin = 15; // Left margin
    const availableWidth = pageWidth - (margin * 2);
    
    let columnWidths: number[];
    let headers: string[];
    
    if (hasCustomDayDate) {
      // For custom day/date exports
      headers = ["Day", "Date", "Value"];
      columnWidths = [availableWidth * 0.3, availableWidth * 0.4, availableWidth * 0.3]; // 30%, 40%, 30%
    } else {
      // For standard exports
      headers = [xKey, "Value"];
      columnWidths = [availableWidth * 0.6, availableWidth * 0.4]; // 60%, 40%
    }
    
    // Calculate row height
    const rowHeight = 8;
    
    // Draw table header
    pdf.setFillColor(240, 240, 240); // Light gray for header
    pdf.setDrawColor(0, 0, 0);
    pdf.setLineWidth(0.1);
    pdf.rect(margin, startY, availableWidth, rowHeight, 'FD'); // Fill and draw
    
    // Add header text
    pdf.setFontSize(10);
    pdf.setTextColor(0, 0, 0);
    let xPos = margin;
    
    headers.forEach((header, index) => {
      pdf.text(header, xPos + 2, startY + 5.5); // Add a small padding
      xPos += columnWidths[index];
    });
    
    // Draw table rows
    let yPos = startY + rowHeight;
    const dataToShow = chartData.slice(0, 50); // Limit to 50 rows to avoid too many pages
    
    dataToShow.forEach((dataPoint, index) => {
      // Draw row background (alternate colors for better readability)
      pdf.setFillColor(index % 2 === 0 ? 255 : 248, index % 2 === 0 ? 255 : 248, index % 2 === 0 ? 255 : 248);
      pdf.rect(margin, yPos, availableWidth, rowHeight, 'FD');
      
      // Add row data
      xPos = margin;
      pdf.setFontSize(9);
      
      if (hasCustomDayDate) {
        // For custom day/date format
        pdf.text(String(dataPoint.dayName), xPos + 2, yPos + 5.5);
        xPos += columnWidths[0];
        
        pdf.text(String(dataPoint.date), xPos + 2, yPos + 5.5);
        xPos += columnWidths[1];
        
        pdf.text(String(dataPoint.value), xPos + 2, yPos + 5.5);
      } else {
        // For standard format
        pdf.text(String(dataPoint[xKey]), xPos + 2, yPos + 5.5);
        xPos += columnWidths[0];
        
        pdf.text(String(dataPoint.value), xPos + 2, yPos + 5.5);
      }
      
      yPos += rowHeight;
      
      // Add a new page if we're reaching the bottom of the current page
      if (yPos > (pageHeight - 20) && index < dataToShow.length - 1) {
        pdf.addPage();
        
        // Add header to the new page
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
    
    // Add note if data was truncated
    if (chartData.length > 50) {
      pdf.setFontSize(8);
      pdf.text(`(Showing 50 of ${chartData.length} data points)`, margin, yPos + 5);
    }
    
    // Save the PDF
    pdf.save(`${title}.pdf`);
  } catch (error) {
    console.error("Error exporting to PDF:", error);
  }
};

/**
 * Exports chart as an SVG image
 */
const exportToSvg = async (chartNode: HTMLElement, title: string) => {
  try {
    // Generate SVG with proper styling
    const dataUrl = await htmlToImage.toSvg(chartNode, {
      quality: 1.0,
      backgroundColor: "white"
    });
    
    // Create download link
    const link = document.createElement("a");
    link.download = `${title}.svg`;
    link.href = dataUrl;
    link.click();
  } catch (error) {
    console.error("Error exporting to SVG:", error);
  }
};

/**
 * Exports chart data as a CSV file
 */
const exportToCsv = (chartData: ChartDataPoint[], xKey: string, title: string) => {
  try {
    // Convert data to CSV format
    const csvData = chartData.map(item => {
      // Check if we have day and date information from custom export
      if (item.dayName && item.date) {
        return {
          'Day': item.dayName,
          'Date': item.date,
          'Value': item.value
        };
      } else {
        // Use original format
        return {
          [xKey]: item[xKey],
          'Value': item.value
        };
      }
    });
    
    // Use PapaParse for more robust CSV handling
    const csv = Papa.unparse(csvData);
    
    // Create download link
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.download = `${title}.csv`;
    link.href = url;
    link.click();
    
    // Clean up
    setTimeout(() => {
      URL.revokeObjectURL(url);
    }, 100);
  } catch (error) {
    console.error("Error exporting to CSV:", error);
  }
};

/**
 * Creates a date-value map from day-of-week data to handle date ranges spanning multiple weeks
 * @param chartData The original chart data with day-of-week keys
 * @param fromDate Start date of the range
 * @param toDate End date of the range
 * @param xKey The key used for the x-axis values
 * @returns Filtered data that includes data for each day in the range with formatted date info
 */
const handleDayOfWeekDateRange = (
  chartData: ChartDataPoint[],
  fromDate: Date,
  toDate: Date,
  xKey: string
): ChartDataPoint[] => {
  // Create a map of day names to their values
  const dayValueMap: Record<string, number> = {};
  chartData.forEach(item => {
    if (typeof item.value === 'number' && typeof item[xKey] === 'string') {
      const dayName = item[xKey] as string;
      dayValueMap[dayName] = item.value;
    }
  });
  
  // Create filtered data for each day in the range
  const result: ChartDataPoint[] = [];
  const dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  
  // Clone the dates to avoid modifying the original
  const current = new Date(fromDate);
  const end = new Date(toDate);
  
  // Function to format date as MM/DD/YYYY
  const formatDate = (date: Date): string => {
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const year = date.getFullYear();
    return `${month}/${day}/${year}`;
  };
  
  // Iterate through each day in the range
  while (current <= end) {
    const dayName = dayNames[current.getDay()];
    
    // If we have data for this day of week, add it to the result
    if (dayName in dayValueMap) {
      // Format the date in MM/DD/YYYY format
      const formattedDate = formatDate(current);
      
      // Create a combined display string: "Day: Thursday Date: 05/01/2025"
      const displayText = `Day: ${dayName} Date: ${formattedDate}`;
      
      result.push({
        [xKey]: displayText, // Use the combined format as the key
        dayName: dayName,    // Keep original day name for reference
        date: formattedDate, // Keep formatted date for reference
        value: dayValueMap[dayName]
      });
    }
    
    // Move to the next day
    current.setDate(current.getDate() + 1);
  }
  
  return result;
};

/**
 * Handles exporting chart data in different formats
 * @param format The format to export (pdf, svg, csv)
 * @param chartNode The DOM node of the chart
 * @param chartData The data used to render the chart
 * @param xKey The key for the x-axis values
 * @param title The title of the chart
 * @param dateRange Optional date range for custom exports
 * @param dataType The type of data being displayed (days, weeks, months, years)
 */
export const handleExport = async (
  format: string,
  chartNode: HTMLElement | null,
  chartData: ChartDataPoint[],
  xKey: string,
  title: string,
  dateRange: DateRange = null,
  dataType: string = "unknown"
) => {
  if (!chartNode) return;

  // Apply date range filter if provided
  let filteredData = chartData;
  if (dateRange && dateRange.from && dateRange.to) {
    const fromDate = new Date(dateRange.from);
    const toDate = new Date(dateRange.to);
    
    // Set end of day for the to date to include the full day
    toDate.setHours(23, 59, 59, 999);
    
    if (!isNaN(fromDate.getTime()) && !isNaN(toDate.getTime())) {
      console.log(`Filtering data from ${fromDate.toISOString()} to ${toDate.toISOString()}`);
      
      // Different filtering logic based on data type
      if (dataType === "days") {
        // Use the enhanced day-of-week handler for multi-week ranges
        filteredData = handleDayOfWeekDateRange(chartData, fromDate, toDate, xKey);
      } else {
        // For other data types, attempt to convert labels to dates
        filteredData = chartData.filter(item => {
          // Parse the item date based on data type
          const itemDate = parseDateString(item[xKey] as string, dataType);
          
          // If we couldn't parse the date, include the item by default
          if (!itemDate) return true;
          
          // Check if date is within range
          return itemDate >= fromDate && itemDate <= toDate;
        });
      }
    }
  }

  console.log(`Exporting ${filteredData.length} data points in ${format} format`);

  // Export based on format
  if (format === "pdf") {
    await exportToPdf(chartNode, filteredData, xKey, title, dateRange);
  } else if (format === "svg") {
    await exportToSvg(chartNode, title);
  } else if (format === "csv") {
    exportToCsv(filteredData, xKey, title);
  }
};