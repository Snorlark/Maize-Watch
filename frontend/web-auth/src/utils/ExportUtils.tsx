import { jsPDF } from "jspdf";
import * as htmlToImage from "html-to-image";

type ChartDataPoint = {
  [key: string]: string | number;
  value: number;
};

export const handleExport = async (
  format: string,
  chartNode: HTMLElement | null,
  chartData: ChartDataPoint[],
  xKey: string,
  title: string
) => {
  if (!chartNode) return;

  if (format === "pdf") {
    const dataUrl = await htmlToImage.toPng(chartNode);
    const pdf = new jsPDF("landscape", "mm", "a4");
    const imgProps = pdf.getImageProperties(dataUrl);
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
    pdf.addImage(dataUrl, "PNG", 10, 20, pdfWidth - 20, pdfHeight);
    pdf.setFontSize(16);
    pdf.text(title, 10, 15);
    pdf.save(`${title}.pdf`);
  }

  if (format === "svg") {
    const dataUrl = await htmlToImage.toSvg(chartNode);
    const link = document.createElement("a");
    link.download = `${title}.svg`;
    link.href = dataUrl;
    link.click();
  }

  if (format === "csv") {
    const rows = chartData.map((row) => `${row[xKey]},${row.value}`);
    const csv = `${xKey},value\n${rows.join("\n")}`;
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.download = `${title}.csv`;
    link.href = url;
    link.click();
  }
};