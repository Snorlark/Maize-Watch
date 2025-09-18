import { format } from "date-fns";

export const dataTransformUtils = {
  formatLabel: (date: string, period: "daily" | "weekly" | "monthly") => {
    const d = new Date(date);
    switch (period) {
      case "daily":
        return format(d, "MMM d");
      case "weekly":
        return `W${Math.ceil(d.getDate() / 7)} ${format(d, "MMM")}`;
      case "monthly":
        return format(d, "MMM yyyy");
      default:
        return format(d, "MMM d");
    }
  }
};
