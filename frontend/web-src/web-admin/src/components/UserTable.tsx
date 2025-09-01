import React, { useState } from 'react';
import { Pencil, Trash2, Loader2, ArrowUpDown, Download, ChevronUp, ChevronDown, ChevronLeft, ChevronRight, User, Shield, Crown, Users } from 'lucide-react';
import { User as UserType } from '../api/services/authService';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
// @ts-ignore - Add this if jspdf-autotable types are causing issues

interface UserTableProps {
  users: UserType[];
  loading: boolean;
  onEdit: (user: UserType) => void;
  onDelete: (user: UserType) => void;
}

type SortDirection = 'asc' | 'desc' | null;
type SortField = 'fullName' | 'address' | 'contactNumber' | 'username' | 'role' | null;

type RoleFilter = 'all' | 'user' | 'farmer' | 'admin' | 'super_admin';

const UserTable: React.FC<UserTableProps> = ({ users, loading, onEdit, onDelete }) => {
  const [sortField, setSortField] = useState<SortField>(null);
  const [sortDirection, setSortDirection] = useState<SortDirection>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [roleFilter, setRoleFilter] = useState<RoleFilter>('all');
  const usersPerPage = 20;
  
  // Filtering by role
  const filteredUsers = roleFilter === 'all'
    ? users
    : users.filter(user => user.role === roleFilter);

  // Sort users based on current sort field and direction
  const sortedUsers = [...filteredUsers].sort((a, b) => {
    if (sortField === null || sortDirection === null) return 0;
    
    let valueA: string;
    let valueB: string;
    
    switch (sortField) {
      case 'fullName':
        valueA = (a.fullName || '').toLowerCase();
        valueB = (b.fullName || '').toLowerCase();
        break;
      case 'address':
        valueA = (a.address || '').toLowerCase();
        valueB = (b.address || '').toLowerCase();
        break;
      case 'contactNumber':
        valueA = (a.contactNumber || '').toLowerCase();
        valueB = (b.contactNumber || '').toLowerCase();
        break;
      case 'username':
        valueA = (a.username || '').toLowerCase();
        valueB = (b.username || '').toLowerCase();
        break;
      case 'role':
        valueA = (a.role || '').toLowerCase();
        valueB = (b.role || '').toLowerCase();
        break;
      default:
        return 0;
    }
    
    if (sortDirection === 'asc') {
      return valueA.localeCompare(valueB);
    } else {
      return valueB.localeCompare(valueA);
    }
  });
  
  // Calculate pagination
  const totalPages = Math.ceil(sortedUsers.length / usersPerPage);
  const startIndex = (currentPage - 1) * usersPerPage;
  const endIndex = startIndex + usersPerPage;
  const currentUsers = sortedUsers.slice(startIndex, endIndex);

  // Get role icon and color
  const getRoleIcon = (role: string) => {
    switch (role) {
      case 'farmer':
      case 'user':
        return <Users className="w-4 h-4" />;
      case 'admin':
        return <Shield className="w-4 h-4" />;
      case 'super_admin':
        return <Crown className="w-4 h-4" />;
      default:
        return <User className="w-4 h-4" />;
    }
  };

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'farmer':
      case 'user':
        return 'bg-green-100 text-green-800';
      case 'admin':
        return 'bg-blue-100 text-blue-800';
      case 'super_admin':
        return 'bg-purple-100 text-purple-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  // Handle column sort
  const handleSort = (field: SortField) => {
    if (sortField === field) {
      // Same field, cycle through directions
      if (sortDirection === 'asc') {
        setSortDirection('desc');
      } else if (sortDirection === 'desc') {
        setSortField(null);
        setSortDirection(null);
      }
    } else {
      // New field, start with ascending
      setSortField(field);
      setSortDirection('asc');
    }
    // Reset to first page when sorting
    setCurrentPage(1);
  };

  // Get sort icon for a column
  const getSortIcon = (field: SortField) => {
    if (sortField !== field) {
      return <ArrowUpDown className="w-4 h-4 ml-1" />;
    }
    if (sortDirection === 'asc') {
      return <ChevronUp className="w-4 h-4 ml-1" />;
    }
    if (sortDirection === 'desc') {
      return <ChevronDown className="w-4 h-4 ml-1" />;
    }
    return <ArrowUpDown className="w-4 h-4 ml-1" />;
  };

  // Handle page navigation
  const goToPage = (page: number) => {
    setCurrentPage(page);
  };

  const goToPreviousPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
  };

  const goToNextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
    }
  };

  // Generate page numbers for pagination
  const getPageNumbers = () => {
    const pages = [];
    const maxVisiblePages = 5;
    
    if (totalPages <= maxVisiblePages) {
      // Show all pages if total is small
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      // Show pages around current page
      let start = Math.max(1, currentPage - 2);
      let end = Math.min(totalPages, start + maxVisiblePages - 1);
      
      // Adjust start if we're near the end
      if (end - start < maxVisiblePages - 1) {
        start = Math.max(1, end - maxVisiblePages + 1);
      }
      
      for (let i = start; i <= end; i++) {
        pages.push(i);
      }
    }
    
    return pages;
  };
  
  // Export to PDF
  const exportToPDF = () => {
  try {
    const doc = new jsPDF("portrait", "mm", "a4");
    const pageWidth = doc.internal.pageSize.getWidth();

      const title = "Users List";
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
          const tableColumn = ["#", "Name", "Address", "Contact No.", "Username", "Role"];
          const tableRows = sortedUsers.map((user, index) => [
            (startIndex + index + 1).toString(),
          user.fullName,
          user.address,
          user.contactNumber,
            user.username,
            user.role
        ]);

        autoTable(doc, {
          head: [tableColumn],
          body: tableRows.map(row => row.map(cell => cell || '')),
          startY: 50,
          theme: 'grid',
          styles: { fontSize: 10, cellPadding: 3 },
          headStyles: { fillColor: [204, 227, 187], textColor: [18, 59, 31] }
        });

          doc.save("users-list.pdf");
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
      {/* Role Filter Dropdown */}
      <div className="flex justify-between mb-4 items-end">
        <div>
          <h2 className="text-xl font-semibold text-[#1E441E]">Users List</h2>
          <p className="text-sm text-[#456C2D] mt-1">
            Showing {startIndex + 1}-{Math.min(endIndex, sortedUsers.length)} of {sortedUsers.length} users
          </p>
        </div>
        <div className="flex gap-4 items-end">
          <div>
            <label htmlFor="roleFilter" className="block text-xs font-medium text-[#456C2D] mb-1">Filter by Role:</label>
            <select
              id="roleFilter"
              value={roleFilter}
              onChange={e => { setRoleFilter(e.target.value as RoleFilter); setCurrentPage(1); }}
              className="px-2 py-1 rounded-lg border border-[#B8D4A8] text-[#356B2C] bg-white focus:outline-none focus:ring-2 focus:ring-[#8B4513]"
            >
              <option value="all">All</option>
              <option value="farmer">farmer</option>
              <option value="admin">admin</option>
              <option value="super_admin">super_admin</option>
            </select>
          </div>
          <button 
            onClick={exportToPDF}
            className="flex items-center px-3 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors cursor-pointer"
          >
            <Download className="w-4 h-4 mr-1" /> Export PDF
          </button>
        </div>
      </div>
      
      <table className="min-w-full bg-white rounded-xl shadow-md overflow-hidden">
        <thead className="bg-[#456C2D] text-[#F5F5DC] text-left">
          <tr>
            <th className="px-6 py-3 w-12">#</th>
            <th 
              className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
              onClick={() => handleSort('fullName')}
            >
              <div className="flex items-center justify-between">
                Name
                {getSortIcon('fullName')}
              </div>
            </th>
            <th 
              className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
              onClick={() => handleSort('address')}
            >
              <div className="flex items-center justify-between">
                Address
                {getSortIcon('address')}
              </div>
            </th>
            <th 
              className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
              onClick={() => handleSort('contactNumber')}
            >
              <div className="flex items-center justify-between">
                Contact No.
                {getSortIcon('contactNumber')}
              </div>
            </th>
            <th 
              className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
              onClick={() => handleSort('username')}
            >
              <div className="flex items-center justify-between">
                Username
                {getSortIcon('username')}
              </div>
            </th>
            <th 
              className="px-6 py-3 cursor-pointer hover:bg-[#5A7A3A] transition-colors"
              onClick={() => handleSort('role')}
            >
              <div className="flex items-center justify-between">
                Role
                {getSortIcon('role')}
              </div>
            </th>
            <th className="px-6 py-3">Actions</th>
          </tr>
        </thead>
        <tbody>
          {loading && filteredUsers.length === 0 ? (
            <tr>
              <td colSpan={7} className="px-6 py-4 text-center">
                <Loader2 className="w-6 h-6 mx-auto animate-spin" />
                <p>Loading users...</p>
              </td>
            </tr>
          ) : currentUsers.length === 0 ? (
            <tr>
              <td colSpan={7} className="px-6 py-4 text-center">No users found</td>
            </tr>
          ) : (
            currentUsers.map((user, index) => (
              <tr key={user._id} className="border-b hover:bg-[#F5F9E8] transition-colors">
                <td className="px-6 py-4 text-center font-medium text-[#456C2D]">
                  {startIndex + index + 1}
                </td>
                <td className="px-6 py-4">{user.fullName}</td>
                <td className="px-6 py-4">{user.address}</td>
                <td className="px-6 py-4">{user.contactNumber}</td>
                <td className="px-6 py-4">{user.username}</td>
                <td className="px-6 py-4">
                  <div className="flex items-center gap-2">
                    {getRoleIcon(user.role)}
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${getRoleColor(user.role)}`}>
                      {user.role}
                    </span>
                  </div>
                </td>
                <td className="px-6 py-4 flex gap-2">
                  <Pencil 
                    className="w-5 h-5 text-[#456C2D] cursor-pointer hover:text-[#8B4513] hover:scale-110 transition-all" 
                    onClick={() => onEdit(user)}
                  />
                  <Trash2 
                    className="w-5 h-5 text-red-600 cursor-pointer hover:text-red-800 hover:scale-110 transition-all" 
                    onClick={() => onDelete(user)}
                  />
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>
      
      {/* Pagination Controls */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between mt-6 p-4 bg-gray-50 rounded-lg border">
          <div className="text-sm text-[#456C2D] font-medium">
            Page {currentPage} of {totalPages} ({sortedUsers.length} total users)
          </div>
          
          <div className="flex items-center gap-2">
            {/* Previous Button */}
            <button
              onClick={goToPreviousPage}
              disabled={currentPage === 1}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors font-medium ${
                currentPage === 1
                  ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
              }`}
            >
              <ChevronLeft className="w-4 h-4 mr-1" />
              Previous
            </button>
            
            {/* Page Numbers */}
            <div className="flex gap-1">
              {getPageNumbers().map((page) => (
                <button
                  key={page}
                  onClick={() => goToPage(page)}
                  className={`px-3 py-2 rounded-lg transition-colors font-medium ${
                    currentPage === page
                      ? 'bg-[#8B4513] text-[#F5F5DC]'
                      : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
                  }`}
                >
                  {page}
                </button>
              ))}
            </div>
            
            {/* Next Button */}
            <button
              onClick={goToNextPage}
              disabled={currentPage === totalPages}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors font-medium ${
                currentPage === totalPages
                  ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
              }`}
            >
              Next
              <ChevronRight className="w-4 h-4 ml-1" />
            </button>
          </div>
        </div>
      )}
      
      {/* Sort Status Indicator */}
      {sortField && (
        <div className="mt-3 text-sm text-[#456C2D]">
          <span className="font-medium">Sorted by:</span> {sortField === 'fullName' ? 'Name' : 
                                                          sortField === 'address' ? 'Address' : 
                                                          sortField === 'contactNumber' ? 'Contact No.' : 
                                                          sortField === 'username' ? 'Username' : 'Role'} 
          ({sortDirection === 'asc' ? 'A to Z' : 'Z to A'})
        </div>
      )}
    </div>
  );
};

export default UserTable;