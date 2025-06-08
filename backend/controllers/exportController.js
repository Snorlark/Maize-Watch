//exportController.js
import SensorReading from '../models/SensorReading.js';
import DailyAverage from '../models/DailyAverage.js';
import WeeklyAverage from '../models/WeeklyAverage.js';
import MonthlyAverage from '../models/MonthlyAverage.js';
import { parse as json2csv } from 'json2csv';
import PDFDocument from 'pdfkit';
import { createCanvas } from 'canvas';
import { Chart, registerables } from 'chart.js';

// Register Chart.js components
Chart.register(...registerables);

/**
 * Safe value extractor that handles null/undefined values
 * @param {*} value - Value to extract
 * @param {*} defaultValue - Default value if null/undefined
 * @returns {*} - Safe value
 */
const safeValue = (value, defaultValue = null) => {
  return (value !== null && value !== undefined && !isNaN(value)) ? value : defaultValue;
};

/**
 * Get the appropriate model and transform function based on time period
 * @param {string} timePeriod - The time period ('days', 'weeks', 'months', or 'raw')
 * @returns {Object} - Model and transform function
 */
const getModelAndTransform = (timePeriod) => {
  switch (timePeriod) {
    case 'days':
      return {
        model: DailyAverage,
        transform: (data) => data.map(item => ({
          timestamp: item.date || '',
          field_id: 'average',
          temperature: safeValue(item.averages?.temperature),
          humidity: safeValue(item.averages?.humidity),
          soil_moisture: safeValue(item.averages?.soilMoisture),
          soil_ph: safeValue(item.averages?.soilPh),
          light_intensity: safeValue(item.averages?.lightIntensity),
          count: safeValue(item.count, 0)
        })),
        dateField: 'date'
      };
    case 'weeks':
      return {
        model: WeeklyAverage,
        transform: (data) => data.map(item => ({
          timestamp: item.weekStart || '',
          field_id: 'average',
          temperature: safeValue(item.averages?.temperature),
          humidity: safeValue(item.averages?.humidity),
          soil_moisture: safeValue(item.averages?.soilMoisture),
          soil_ph: safeValue(item.averages?.soilPh),
          light_intensity: safeValue(item.averages?.lightIntensity),
          count: safeValue(item.count, 0),
          week_end: item.weekEnd || ''
        })),
        dateField: 'weekStart'
      };
    case 'months':
      return {
        model: MonthlyAverage,
        transform: (data) => data.map(item => ({
          timestamp: item.monthStart || '',
          field_id: 'average',
          temperature: safeValue(item.averages?.temperature),
          humidity: safeValue(item.averages?.humidity),
          soil_moisture: safeValue(item.averages?.soilMoisture),
          soil_ph: safeValue(item.averages?.soilPh),
          light_intensity: safeValue(item.averages?.lightIntensity),
          count: safeValue(item.count, 0),
          month_end: item.monthEnd || ''
        })),
        dateField: 'monthStart'
      };
    default: // raw sensor data
      return {
        model: SensorReading,
        transform: (data) => data.map(reading => ({
          timestamp: reading.timestamp || '',
          field_id: reading.field_id || '',
          temperature: safeValue(reading.measurements?.temperature),
          humidity: safeValue(reading.measurements?.humidity),
          soil_moisture: safeValue(reading.measurements?.soil_moisture),
          soil_ph: safeValue(reading.measurements?.soil_ph),
          light_intensity: safeValue(reading.measurements?.light_intensity)
        })),
        dateField: 'timestamp'
      };
  }
};

/**
 * Export sensor data within a custom date range
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
export const exportSensorData = async (req, res) => {
  try {
    const { 
      startDate, 
      endDate, 
      format = 'csv', 
      fields = [], 
      timePeriod = 'raw' // New parameter to specify data source
    } = req.query;

    // Validate required parameters
    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Start date and end date are required'
      });
    }

    // Validate date format and range
    const start = new Date(startDate);
    const end = new Date(endDate);

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid date format. Use ISO 8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)'
      });
    }

    if (start >= end) {
      return res.status(400).json({
        success: false,
        message: 'Start date must be before end date'
      });
    }

    // Check if date range is too large (optional protection)
    const daysDifference = (end - start) / (1000 * 60 * 60 * 24);
    if (daysDifference > 365 && timePeriod === 'raw') {
      return res.status(400).json({
        success: false,
        message: 'Date range cannot exceed 365 days for raw data'
      });
    }

    // Get appropriate model and transform function
    const { model, transform, dateField } = getModelAndTransform(timePeriod);

    // Build MongoDB query
    const query = {};
    query[dateField] = {
      $gte: start,
      $lte: end
    };

    // Optional: Filter by specific field_id if provided (only for raw data)
    if (req.query.field_id && timePeriod === 'raw') {
      query.field_id = req.query.field_id;
    }

    // Fetch data from MongoDB with error handling
    let rawData;
    try {
      rawData = await model.find(query)
        .sort({ [dateField]: 1 }) // Sort by date field ascending
        .lean(); // Use lean() for better performance
    } catch (dbError) {
      console.error('Database query error:', dbError);
      return res.status(500).json({
        success: false,
        message: 'Database query failed',
        error: process.env.NODE_ENV === 'development' ? dbError.message : undefined
      });
    }

    // Handle case where no data is found
    if (!rawData || rawData.length === 0) {
      // Return empty data structure instead of error
      const emptyResult = {
        success: true,
        data: [],
        count: 0,
        dateRange: { startDate, endDate },
        timePeriod,
        message: 'No data found for the specified date range'
      };

      switch (format.toLowerCase()) {
        case 'json':
          res.setHeader('Content-Type', 'application/json');
          res.setHeader('Content-Disposition', `attachment; filename=${timePeriod}_data_${startDate}_to_${endDate}.json`);
          return res.json(emptyResult);

        case 'csv':
          const csvHeaders = timePeriod === 'raw' ? 
            'timestamp,field_id,temperature,humidity,soil_moisture,soil_ph,light_intensity\n' :
            'timestamp,field_id,temperature,humidity,soil_moisture,soil_ph,light_intensity,count\n';

          res.setHeader('Content-Type', 'text/csv');
          res.setHeader('Content-Disposition', `attachment; filename=${timePeriod}_data_${startDate}_to_${endDate}.csv`);
          return res.status(200).send(csvHeaders);

        default:
          return res.status(404).json({
            success: false,
            message: 'No data found for the specified date range'
          });
      }
    }

    // Transform data for export with safe handling
    let transformedData;
    try {
      transformedData = transform(rawData);
    } catch (transformError) {
      console.error('Data transformation error:', transformError);
      return res.status(500).json({
        success: false,
        message: 'Data transformation failed',
        error: process.env.NODE_ENV === 'development' ? transformError.message : undefined
      });
    }

    // Handle different export formats
    switch (format.toLowerCase()) {
      case 'json':
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', `attachment; filename=${timePeriod}_data_${startDate}_to_${endDate}.json`);
        return res.json({
          success: true,
          data: transformedData,
          count: transformedData.length,
          dateRange: { startDate, endDate },
          timePeriod
        });

      case 'pdf':
        return await generatePDFExport(transformedData, { startDate, endDate, timePeriod }, res);

      case 'svg':
        return await generateSVGExport(transformedData, { startDate, endDate, timePeriod }, res);

      default: // CSV
        try {
          const csvFields = timePeriod === 'raw' ? 
            ['timestamp', 'field_id', 'temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity'] :
            ['timestamp', 'field_id', 'temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity', 'count'];

          // Add additional fields for weekly/monthly data
          if (timePeriod === 'weeks') csvFields.push('week_end');
          if (timePeriod === 'months') csvFields.push('month_end');

          // Filter fields if specific fields are requested
          const fieldsToExport = fields.length > 0 ? 
            csvFields.filter(field => fields.includes(field)) : 
            csvFields;

          // Enhanced CSV generation with null handling
          const csvOptions = {
            fields: fieldsToExport,
            defaultValue: '', // Use empty string for null values
            emptyValue: '', // Use empty string for empty values
            quote: '"',
            escapedQuote: '""'
          };

          const csv = json2csv(transformedData, csvOptions);

          res.setHeader('Content-Type', 'text/csv');
          res.setHeader('Content-Disposition', `attachment; filename=${timePeriod}_data_${startDate}_to_${endDate}.csv`);
          res.status(200).send(csv);
        } catch (csvError) {
          console.error('CSV generation error:', csvError);
          return res.status(500).json({
            success: false,
            message: 'CSV generation failed',
            error: process.env.NODE_ENV === 'development' ? csvError.message : undefined
          });
        }
    }

  } catch (error) {
    console.error('Export error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error during export',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Get data summary for a date range (useful for preview before export)
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
export const getDataSummary = async (req, res) => {
  try {
    const { startDate, endDate, timePeriod = 'raw' } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Start date and end date are required'
      });
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    // Get appropriate model and date field
    const { model, dateField } = getModelAndTransform(timePeriod);

    const query = {};
    query[dateField] = {
      $gte: start,
      $lte: end
    };

    // Get count and basic statistics with enhanced null handling
    let count, stats;

    try {
      if (timePeriod === 'raw') {
        // For raw data, use aggregation with null handling
        [count, stats] = await Promise.all([
          model.countDocuments(query),
          model.aggregate([
            { $match: query },
            {
              $group: {
                _id: null,
                avgTemperature: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$measurements.temperature', null] },
                        { $ne: ['$measurements.temperature', undefined] },
                        { $type: ['$measurements.temperature', 'number'] }
                      ]}, 
                      '$measurements.temperature', 
                      null
                    ]
                  }
                },
                avgHumidity: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$measurements.humidity', null] },
                        { $ne: ['$measurements.humidity', undefined] },
                        { $type: ['$measurements.humidity', 'number'] }
                      ]}, 
                      '$measurements.humidity', 
                      null
                    ]
                  }
                },
                avgSoilMoisture: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$measurements.soil_moisture', null] },
                        { $ne: ['$measurements.soil_moisture', undefined] },
                        { $type: ['$measurements.soil_moisture', 'number'] }
                      ]}, 
                      '$measurements.soil_moisture', 
                      null
                    ]
                  }
                },
                avgSoilPH: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$measurements.soil_ph', null] },
                        { $ne: ['$measurements.soil_ph', undefined] },
                        { $type: ['$measurements.soil_ph', 'number'] }
                      ]}, 
                      '$measurements.soil_ph', 
                      null
                    ]
                  }
                },
                avgLightIntensity: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$measurements.light_intensity', null] },
                        { $ne: ['$measurements.light_intensity', undefined] },
                        { $type: ['$measurements.light_intensity', 'number'] }
                      ]}, 
                      '$measurements.light_intensity', 
                      null
                    ]
                  }
                },
                minTimestamp: { $min: `$${dateField}` },
                maxTimestamp: { $max: `$${dateField}` }
              }
            }
          ])
        ]);
      } else {
        // For aggregated data, calculate averages with null handling
        [count, stats] = await Promise.all([
          model.countDocuments(query),
          model.aggregate([
            { $match: query },
            {
              $group: {
                _id: null,
                avgTemperature: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$averages.temperature', null] },
                        { $ne: ['$averages.temperature', undefined] },
                        { $type: ['$averages.temperature', 'number'] }
                      ]}, 
                      '$averages.temperature', 
                      null
                    ]
                  }
                },
                avgHumidity: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$averages.humidity', null] },
                        { $ne: ['$averages.humidity', undefined] },
                        { $type: ['$averages.humidity', 'number'] }
                      ]}, 
                      '$averages.humidity', 
                      null
                    ]
                  }
                },
                avgSoilMoisture: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$averages.soilMoisture', null] },
                        { $ne: ['$averages.soilMoisture', undefined] },
                        { $type: ['$averages.soilMoisture', 'number'] }
                      ]}, 
                      '$averages.soilMoisture', 
                      null
                    ]
                  }
                },
                avgSoilPH: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$averages.soilPh', null] },
                        { $ne: ['$averages.soilPh', undefined] },
                        { $type: ['$averages.soilPh', 'number'] }
                      ]}, 
                      '$averages.soilPh', 
                      null
                    ]
                  }
                },
                avgLightIntensity: { 
                  $avg: { 
                    $cond: [
                      { $and: [
                        { $ne: ['$averages.lightIntensity', null] },
                        { $ne: ['$averages.lightIntensity', undefined] },
                        { $type: ['$averages.lightIntensity', 'number'] }
                      ]}, 
                      '$averages.lightIntensity', 
                      null
                    ]
                  }
                },
                minTimestamp: { $min: `$${dateField}` },
                maxTimestamp: { $max: `$${dateField}` },
                totalCount: { $sum: { $cond: [{ $ne: ['$count', null] }, '$count', 0] } }
              }
            }
          ])
        ]);
      }
    } catch (aggregationError) {
      console.error('Aggregation error:', aggregationError);
      return res.status(500).json({
        success: false,
        message: 'Error calculating statistics',
        error: process.env.NODE_ENV === 'development' ? aggregationError.message : undefined
      });
    }

    res.json({
      success: true,
      summary: {
        totalRecords: count || 0,
        dateRange: { startDate, endDate },
        timePeriod,
        statistics: stats && stats[0] ? stats[0] : null
      }
    });

  } catch (error) {
    console.error('Summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching data summary',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Generate charts using Chart.js and Canvas with null handling
 * @param {Array} data - Sensor data array
 * @param {Object} options - Chart options
 * @returns {Buffer} - Chart image buffer
 */
const generateChart = async (data, options = {}) => {
  const {
    type = 'line',
    field = 'temperature',
    title = 'Sensor Data',
    width = 800,
    height = 400,
    color = 'rgb(75, 192, 192)'
  } = options;

  try {
    // Create canvas
    const canvas = createCanvas(width, height);
    const ctx = canvas.getContext('2d');

    // Filter out null values and prepare data for Chart.js
    const validData = data.filter(item => 
      item[field] !== null && 
      item[field] !== undefined && 
      !isNaN(item[field]) &&
      item.timestamp
    );

    if (validData.length === 0) {
      // Create empty chart if no valid data
      ctx.fillStyle = '#f0f0f0';
      ctx.fillRect(0, 0, width, height);
      ctx.fillStyle = '#666';
      ctx.font = '20px Arial';
      ctx.textAlign = 'center';
      ctx.fillText('No data available', width / 2, height / 2);
      return canvas.toBuffer('image/png');
    }

    // Prepare data for Chart.js
    const chartData = {
      labels: validData.map(item => new Date(item.timestamp).toLocaleDateString()),
      datasets: [{
        label: title,
        data: validData.map(item => item[field]),
        borderColor: color,
        backgroundColor: color.replace('rgb', 'rgba').replace(')', ', 0.1)'),
        borderWidth: 2,
        fill: true,
        tension: 0.4,
        spanGaps: true // This will connect points even if there are gaps
      }]
    };

    const config = {
      type,
      data: chartData,
      options: {
        responsive: false,
        animation: false,
        elements: {
          point: {
            radius: 2
          }
        },
        plugins: {
          title: {
            display: true,
            text: title,
            font: { size: 16 }
          },
          legend: {
            display: true,
            position: 'top'
          }
        },
        scales: {
          x: {
            display: true,
            title: {
              display: true,
              text: 'Date'
            }
          },
          y: {
            display: true,
            title: {
              display: true,
              text: getFieldUnit(field)
            }
          }
        }
      }
    };

    // Create chart
    new Chart(ctx, config);

    // Return canvas buffer
    return canvas.toBuffer('image/png');
  } catch (chartError) {
    console.error('Chart generation error:', chartError);
    
    // Return a simple error chart
    const canvas = createCanvas(width, height);
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#ffebee';
    ctx.fillRect(0, 0, width, height);
    ctx.fillStyle = '#d32f2f';
    ctx.font = '16px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('Chart generation failed', width / 2, height / 2);
    return canvas.toBuffer('image/png');
  }
};

/**
 * Get field unit for y-axis label
 * @param {string} field - Field name
 * @returns {string} - Unit string
 */
const getFieldUnit = (field) => {
  const units = {
    temperature: 'Temperature (°C)',
    humidity: 'Humidity (%)',
    soil_moisture: 'Soil Moisture',
    soil_ph: 'pH Level',
    light_intensity: 'Light Intensity (lux)'
  };
  return units[field] || field;
};

/**
 * Generate PDF export with charts and data
 * @param {Array} data - Sensor data
 * @param {Object} dateRange - Date range info with timePeriod
 * @param {Object} res - Express response object
 */
const generatePDFExport = async (data, dateRange, res) => {
  try {
    const { startDate, endDate, timePeriod } = dateRange;
    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    
    // Set response headers
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=${timePeriod}_report_${startDate}_to_${endDate}.pdf`);
    
    // Pipe PDF to response
    doc.pipe(res);

    // Title page
    // Add the header image
    const imageWidth = 150; // Adjust width as needed
    const pageWidth = doc.page.width;
    const imageX = (pageWidth - imageWidth) / 2; // Center the image horizontally

    doc.image('maizewatch.png', imageX, doc.y, {
        width: imageWidth,
        align: 'center'
    });

    // Move down after the image
    doc.moveDown(4);

    doc.fontSize(24).text(`${timePeriod.charAt(0).toUpperCase() + timePeriod.slice(1)} Sensor Data Report`, { align: 'center' });
    doc.moveDown();
    doc.fontSize(14).text(`Date Range: ${new Date(startDate).toLocaleDateString()} - ${new Date(endDate).toLocaleDateString()}`, { align: 'center' });
    doc.text(`Total Records: ${data.length.toLocaleString()}`, { align: 'center' });
    doc.text(`Data Type: ${timePeriod === 'raw' ? 'Raw Sensor Readings' : `${timePeriod.charAt(0).toUpperCase() + timePeriod.slice(1)} Averages`}`, { align: 'center' });
    doc.moveDown(2);

    // Summary statistics with null handling
    const stats = calculateStatistics(data);
    doc.fontSize(16).text('Summary Statistics', { underline: true });
    doc.moveDown();
    doc.fontSize(12);
    
    Object.entries(stats).forEach(([key, value]) => {
      if (value.avg !== null && !isNaN(value.avg)) {
        doc.text(`${getFieldUnit(key)}:`);
        doc.text(`  Average: ${value.avg.toFixed(2)}`, { indent: 20 });
        doc.text(`  Min: ${value.min.toFixed(2)}`, { indent: 20 });
        doc.text(`  Max: ${value.max.toFixed(2)}`, { indent: 20 });
        doc.text(`  Valid Data Points: ${value.count}`, { indent: 20 });
        doc.moveDown(0.5);
      } else {
        doc.text(`${getFieldUnit(key)}: No valid data available`);
        doc.moveDown(0.5);
      }
    });

    // Generate charts for each measurement type
    const chartFields = ['temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity'];
    const colors = [
      'rgb(255, 99, 132)',   // Red
      'rgb(54, 162, 235)',   // Blue
      'rgb(255, 205, 86)',   // Yellow
      'rgb(75, 192, 192)',   // Teal
      'rgb(153, 102, 255)'   // Purple
    ];

    for (let i = 0; i < chartFields.length; i++) {
      const field = chartFields[i];
      const filteredData = data.filter(item => 
        item[field] !== null && 
        item[field] !== undefined && 
        !isNaN(item[field])
      );
      
      doc.addPage();
      doc.fontSize(16).text(`${getFieldUnit(field)} Chart (${timePeriod})`, { align: 'center' });
      doc.moveDown();

      try {
        // Generate chart
        const chartBuffer = await generateChart(data, {
          field,
          title: `${getFieldUnit(field)} - ${timePeriod}`,
          color: colors[i],
          width: 500,
          height: 300
        });

        // Add chart to PDF
        doc.image(chartBuffer, 50, doc.y, { width: 500, height: 300 });
        doc.moveDown(15);

        // Add recent data table
        doc.fontSize(14).text('Recent Data Points:', { underline: true });
        doc.moveDown();
        doc.fontSize(10);

        const recentData = filteredData.slice(-10); // Last 10 records
        if (recentData.length > 0) {
          recentData.forEach(item => {
            const timestamp = item.timestamp ? new Date(item.timestamp).toLocaleString() : 'N/A';
            const value = item[field] !== null ? item[field] : 'N/A';
            doc.text(`${timestamp}: ${value}`);
          });
        } else {
          doc.text('No valid data points available for this field');
        }
      } catch (chartError) {
        console.error(`Error generating chart for ${field}:`, chartError);
        doc.text(`Chart generation failed for ${field}: ${chartError.message}`);
      }
    }

    // Data table (last few pages)
    doc.addPage();
    doc.fontSize(16).text(`Raw Data (Last 50 Records) - ${timePeriod}`, { align: 'center' });
    doc.moveDown();
    doc.fontSize(8);

    const recentRecords = data.slice(-50);
    recentRecords.forEach(record => {
      const timestamp = record.timestamp ? new Date(record.timestamp).toLocaleString() : 'N/A';
      const temp = record.temperature !== null ? `${record.temperature}°C` : 'N/A';
      const humidity = record.humidity !== null ? `${record.humidity}%` : 'N/A';
      const soilMoisture = record.soil_moisture !== null ? record.soil_moisture : 'N/A';
      const soilPH = record.soil_ph !== null ? record.soil_ph : 'N/A';
      const lightIntensity = record.light_intensity !== null ? record.light_intensity : 'N/A';
      
      doc.text(`${timestamp} | T:${temp} | H:${humidity} | SM:${soilMoisture} | pH:${soilPH} | LI:${lightIntensity}`);
    });

    // Finalize PDF
    doc.end();

  } catch (error) {
    console.error('PDF generation error:', error);
    if (!res.headersSent) {
      res.status(500).json({
        success: false,
        message: 'PDF generation failed',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
};

/**
 * Generate SVG export with charts
 * @param {Array} data - Sensor data
 * @param {Object} dateRange - Date range info with timePeriod
 * @param {Object} res - Express response object
 */
const generateSVGExport = async (data, dateRange, res) => {
  try {
    const { startDate, endDate, timePeriod } = dateRange;
    const svgWidth = 1200;
    const svgHeight = 800;
    const chartWidth = 350;
    const chartHeight = 150;
    
    // Start SVG
    let svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="${svgWidth}" height="${svgHeight}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style>
      .title { font-family: Arial, sans-serif; font-size: 24px; font-weight: bold; }
      .subtitle { font-family: Arial, sans-serif; font-size: 14px; }
      .chart-title { font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; }
      .axis-label { font-family: Arial, sans-serif; font-size: 10px; }
      .data-line { fill: none; stroke-width: 2; }
      .grid-line { stroke: #e0e0e0; stroke-width: 0.5; }
    </style>
  </defs>
  
  <!-- Background -->
  <rect width="100%" height="100%" fill="white"/>
  
  <!-- Title -->
  <text x="${svgWidth/2}" y="30" text-anchor="middle" class="title">${timePeriod.charAt(0).toUpperCase() + timePeriod.slice(1)} Sensor Data Dashboard</text>
  <text x="${svgWidth/2}" y="55" text-anchor="middle" class="subtitle">
    ${new Date(startDate).toLocaleDateString()} - ${new Date(endDate).toLocaleDateString()} | ${data.length} records | ${timePeriod} data
  </text>`;

    // Generate mini charts for each sensor type
    const chartFields = ['temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity'];
    const chartTitles = ['Temperature (°C)', 'Humidity (%)', 'Soil Moisture', 'pH Level', 'Light Intensity'];
    const colors = ['#ff6384', '#36a2eb', '#ffcd56', '#4bc0c0', '#9966ff'];

    for (let i = 0; i < chartFields.length; i++) {
      const field = chartFields[i];
      const filteredData = data.filter(item => item[field] !== null);
      
      if (filteredData.length > 0) {
        const x = 50 + (i % 3) * (chartWidth + 50);
        const y = 100 + Math.floor(i / 3) * (chartHeight + 80);
        
        svg += generateSVGChart(filteredData, field, {
          x, y, width: chartWidth, height: chartHeight,
          title: `${chartTitles[i]} (${timePeriod})`,
          color: colors[i]
        });
      }
    }

    // Statistics table
    const stats = calculateStatistics(data);
    svg += generateSVGStatsTable(stats, { x: 50, y: 500, width: 1100 });

    // Close SVG
    svg += '</svg>';

    // Set response headers and send
    res.setHeader('Content-Type', 'image/svg+xml');
    res.setHeader('Content-Disposition', `attachment; filename=${timePeriod}_dashboard_${startDate}_to_${endDate}.svg`);
    res.send(svg);

  } catch (error) {
    console.error('SVG generation error:', error);
    res.status(500).json({
      success: false,
      message: 'SVG generation failed',
      error: error.message
    });
  }
};

/**
 * Generate SVG chart for a specific field
 * @param {Array} data - Filtered data for the field
 * @param {string} field - Field name
 * @param {Object} options - Chart options
 * @returns {string} - SVG string for the chart
 */
const generateSVGChart = (data, field, options) => {
  const { x, y, width, height, title, color } = options;
  
  // Get min/max values for scaling
  const values = data.map(item => item[field]);
  const minVal = Math.min(...values);
  const maxVal = Math.max(...values);
  const range = maxVal - minVal || 1;
  
  let svg = `
  <!-- Chart: ${title} -->
  <g transform="translate(${x}, ${y})">
    <!-- Chart background -->
    <rect width="${width}" height="${height}" fill="#f9f9f9" stroke="#ddd"/>
    
    <!-- Title -->
    <text x="${width/2}" y="-10" text-anchor="middle" class="chart-title">${title}</text>
    
    <!-- Grid lines -->`;
  
  // Horizontal grid lines
  for (let i = 0; i <= 4; i++) {
    const gridY = (height / 4) * i;
    svg += `<line x1="0" y1="${gridY}" x2="${width}" y2="${gridY}" class="grid-line"/>`;
  }
  
  // Vertical grid lines
  for (let i = 0; i <= 5; i++) {
    const gridX = (width / 5) * i;
    svg += `<line x1="${gridX}" y1="0" x2="${gridX}" y2="${gridY}" class="grid-line"/>`;
  }
  
  svg += `
    <!-- Data line -->
    <polyline points="`;
  
  // Generate data points
  data.forEach((item, index) => {
    const xPos = (index / (data.length - 1)) * width;
    const yPos = height - ((item[field] - minVal) / range) * height;
    svg += `${xPos},${yPos} `;
  });
  
  svg += `" class="data-line" stroke="${color}"/>
    
    <!-- Y-axis labels -->
    <text x="-5" y="5" text-anchor="end" class="axis-label">${maxVal.toFixed(1)}</text>
    <text x="-5" y="${height}" text-anchor="end" class="axis-label">${minVal.toFixed(1)}</text>
  </g>`;
  
  return svg;
};

/**
 * Generate SVG statistics table
 * @param {Object} stats - Statistics object
 * @param {Object} options - Table options
 * @returns {string} - SVG string for the table
 */
const generateSVGStatsTable = (stats, options) => {
  const { x, y, width } = options;
  let svg = `
  <!-- Statistics Table -->
  <g transform="translate(${x}, ${y})">
    <text x="0" y="0" class="chart-title">Statistics Summary</text>`;
  
  let rowY = 25;
  Object.entries(stats).forEach(([field, data]) => {
    if (data.avg !== null) {
      svg += `
    <text x="0" y="${rowY}" class="axis-label">${getFieldUnit(field)}:</text>
    <text x="200" y="${rowY}" class="axis-label">Avg: ${data.avg.toFixed(2)}</text>
    <text x="350" y="${rowY}" class="axis-label">Min: ${data.min.toFixed(2)}</text>
    <text x="500" y="${rowY}" class="axis-label">Max: ${data.max.toFixed(2)}</text>`;
      rowY += 20;
    }
  });
  
  svg += `</g>`;
  return svg;
};

/**
 * Calculate statistics for all sensor fields
 * @param {Array} data - Sensor data array
 * @returns {Object} - Statistics object
 */
const calculateStatistics = (data) => {
  const fields = ['temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity'];
  const stats = {};
  
  fields.forEach(field => {
    const values = data.map(item => item[field]).filter(val => val !== null);
    
    if (values.length > 0) {
      stats[field] = {
        avg: values.reduce((a, b) => a + b, 0) / values.length,
        min: Math.min(...values),
        max: Math.max(...values),
        count: values.length
      };
    } else {
      stats[field] = { avg: null, min: null, max: null, count: 0 };
    }
  });
  
  return stats;
};