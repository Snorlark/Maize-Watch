import { startOfWeek, endOfWeek, startOfMonth, endOfMonth, format } from "date-fns";

export const dateUtils = {
  getStartOfWeek: (date: Date) => startOfWeek(date, { weekStartsOn: 1 }),
  getEndOfWeek: (date: Date) => endOfWeek(date, { weekStartsOn: 1 }),
  getStartOfMonth: (date: Date) => startOfMonth(date),
  getEndOfMonth: (date: Date) => endOfMonth(date),
  formatDateRange: (start: Date, end: Date) => {
    return `${format(start, "MMM d, yyyy")} - ${format(end, "MMM d, yyyy")}`;
  }
};
