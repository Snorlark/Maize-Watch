import React, { useState } from 'react';
import { Pencil, Trash2, Loader2, ArrowUpDown, Download } from 'lucide-react';
import { User } from '../api/client';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
// @ts-ignore - Add this if jspdf-autotable types are causing issues

interface UserTableProps {
  users: User[];
  loading: boolean;
  onEdit: (user: User) => void;
  onDelete: (user: User) => void;
}

type SortDirection = 'asc' | 'desc' | null;

const UserTable: React.FC<UserTableProps> = ({ users, loading, onEdit, onDelete }) => {
  const [sortDirection, setSortDirection] = useState<SortDirection>(null);
  
  // We now receive pre-filtered farmers directly
  const farmersOnly = users.filter(user => user.role === 'farmer');
  
  // Sort users by name if sort direction is specified
  const sortedUsers = [...farmersOnly].sort((a, b) => {
    if (sortDirection === null) return 0;
    
    const nameA = a.fullName.toLowerCase();
    const nameB = b.fullName.toLowerCase();
    
    if (sortDirection === 'asc') {
      return nameA.localeCompare(nameB);
    } else {
      return nameB.localeCompare(nameA);
    }
  });
  
  // Toggle sort direction
  const toggleSort = () => {
    if (sortDirection === null) {
      setSortDirection('asc');
    } else if (sortDirection === 'asc') {
      setSortDirection('desc');
    } else {
      setSortDirection(null);
    }
  };
  
  // Export to PDF
  const exportToPDF = () => {
  try {
    const doc = new jsPDF("portrait", "mm", "a4");
    const pageWidth = doc.internal.pageSize.getWidth();

    const title = "Farmers List";
    const now = new Date();
    const exportDate = now.toLocaleString();

    // Try adding the logo centered at the top
    try {
      const logo = new Image();
      logo.src = "maizewatch.png"; // ✅ if imported with Webpack

      logo.onload = () => {
        const logoWidth = 60; // mm
        const logoHeight = 15;
        const logoX = (pageWidth - logoWidth) / 2;

        doc.addImage(logo, 'PNG', logoX, 10, logoWidth, logoHeight);

        // Add title below the logo
        doc.setFontSize(16);
        doc.text(title, pageWidth / 2, 35, { align: "center" });

        // Add export date
        doc.setFontSize(10);
        doc.text(`Exported on: ${exportDate}`, pageWidth / 2, 42, { align: "center" });

        // Table content
        const tableColumn = ["Name", "Address", "Contact No.", "Username"];
        const tableRows = sortedUsers.map(user => [
          user.fullName,
          user.address,
          user.contactNumber,
          user.username
        ]);

        autoTable(doc, {
          head: [tableColumn],
          body: tableRows,
          startY: 50,
          theme: 'grid',
          styles: { fontSize: 10, cellPadding: 3 },
          headStyles: { fillColor: [204, 227, 187], textColor: [18, 59, 31] }
        });

        doc.save("farmers-list.pdf");
      };
    } catch (error) {
      console.error("Error adding logo:", error);
    }
  } catch (err) {
    console.error("Error generating PDF:", err);
  }
};
  
  return (
    <div className="overflow-x-auto">
      <div className="flex justify-between mb-4">
        <h2 className="text-xl font-semibold">Farmers List</h2>
        <div className="flex gap-2">
          <button 
            onClick={toggleSort}
            className="flex items-center px-3 py-2 bg-[#cce3bb] text-[#123b1f] rounded-md hover:bg-[#b8d9a2]"
          >
            <ArrowUpDown className="w-4 h-4 mr-1" /> 
            Sort by Name {sortDirection === 'asc' ? '(A-Z)' : sortDirection === 'desc' ? '(Z-A)' : ''}
          </button>
          <button 
            onClick={exportToPDF}
            className="flex items-center px-3 py-2 bg-[#123b1f] text-white rounded-md hover:bg-[#1a5930]"
          >
            <Download className="w-4 h-4 mr-1" /> Export PDF
          </button>
        </div>
      </div>
      <table className="min-w-full bg-white rounded-xl shadow-md overflow-hidden">
        <thead className="bg-[#cce3bb] text-[#123b1f] text-left">
          <tr>
            <th className="px-6 py-3">
              <div className="flex items-center">
                Name
              </div>
            </th>
            <th className="px-6 py-3">Address</th>
            <th className="px-6 py-3">Contact No.</th>
            <th className="px-6 py-3">Username</th>
            <th className="px-6 py-3">Actions</th>
          </tr>
        </thead>
        <tbody>
          {loading && farmersOnly.length === 0 ? (
            <tr>
              <td colSpan={5} className="px-6 py-4 text-center">
                <Loader2 className="w-6 h-6 mx-auto animate-spin" />
                <p>Loading users...</p>
              </td>
            </tr>
          ) : sortedUsers.length === 0 ? (
            <tr>
              <td colSpan={5} className="px-6 py-4 text-center">No farmers found</td>
            </tr>
          ) : (
            sortedUsers.map((user) => (
              <tr key={user._id} className="border-b hover:bg-[#f2fbe7]">
                <td className="px-6 py-4">{user.fullName}</td>
                <td className="px-6 py-4">{user.address}</td>
                <td className="px-6 py-4">{user.contactNumber}</td>
                <td className="px-6 py-4">{user.username}</td>
                <td className="px-6 py-4 flex gap-2">
                  <Pencil 
                    className="w-5 h-5 text-green-600 cursor-pointer hover:scale-110 transition-transform" 
                    onClick={() => onEdit(user)}
                  />
                  <Trash2 
                    className="w-5 h-5 text-red-600 cursor-pointer hover:scale-110 transition-transform" 
                    onClick={() => onDelete(user)}
                  />
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default UserTable;