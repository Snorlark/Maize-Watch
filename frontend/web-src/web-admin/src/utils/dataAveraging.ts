import axios from 'axios';

export interface DataItem {
  [key: string]: string | number;
  value: number;
}

export interface HistoricalData {
  date?: string;
  weekStart?: string;
  monthStart?: string;
  averages: {
    temperature: number;
    humidity: number;
    soilMoisture: number;
    soilPh: number;
    lightIntensity: number;
  };
}

export const fetchAndFormatData = async (
  overview: string,
  metric: 'temperature' | 'humidity' | 'soilMoisture' | 'soilPh' | 'lightIntensity'
): Promise<{ chartData: DataItem[]; xKey: string }> => {
  try {
    const period = overview === "days" ? "daily" : overview === "weeks" ? "weekly" : "monthly";
    const token = localStorage.getItem('token');
    const response = await axios.get(`/api/historical-data/${period}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.data.success) {
      const formattedData = response.data.data.map((item: HistoricalData) => {
        let label;
        if (period === 'daily') {
          label = new Date(item.date!).toLocaleDateString('en-US', { weekday: 'long' });
        } else if (period === 'weekly') {
          const weekStart = new Date(item.weekStart!);
          label = `Week ${Math.ceil((weekStart.getDate() + weekStart.getDay()) / 7)}`;
        } else {
          label = new Date(item.monthStart!).toLocaleDateString('en-US', { month: 'short' });
        }

        return {
          [overview.slice(0, -1)]: label,
          value: item.averages[metric]
        };
      });

      return {
        chartData: formattedData,
        xKey: overview.slice(0, -1)
      };
    }

    return {
      chartData: [],
      xKey: overview.slice(0, -1)
    };
  } catch (error) {
    console.error("Error fetching historical data:", error);
    return {
      chartData: [],
      xKey: overview.slice(0, -1)
    };
  }
};

export const getDefaultData = (overview: string): { chartData: DataItem[]; xKey: string } => {
  const defaultData = {
    days: [
      { day: "Monday", value: 0 },
      { day: "Tuesday", value: 0 },
      { day: "Wednesday", value: 0 },
      { day: "Thursday", value: 0 },
      { day: "Friday", value: 0 },
      { day: "Saturday", value: 0 },
      { day: "Sunday", value: 0 },
    ],
    weeks: [
      { week: "Week 1", value: 0 },
      { week: "Week 2", value: 0 },
      { week: "Week 3", value: 0 },
      { week: "Week 4", value: 0 },
    ],
    months: [
      { month: "Jan", value: 0 },
      { month: "Feb", value: 0 },
      { month: "Mar", value: 0 },
      { month: "Apr", value: 0 },
      { month: "May", value: 0 },
      { month: "Jun", value: 0 },
      { month: "Jul", value: 0 },
      { month: "Aug", value: 0 },
      { month: "Sep", value: 0 },
      { month: "Oct", value: 0 },
      { month: "Nov", value: 0 },
      { month: "Dec", value: 0 },
    ],
  };

  return {
    chartData: defaultData[overview as keyof typeof defaultData],
    xKey: overview.slice(0, -1)
  };
}; 