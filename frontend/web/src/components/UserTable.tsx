import React from 'react';
import { Pencil, Trash2, Loader2 } from 'lucide-react';
import { User } from '../api/userService';

interface UserTableProps {
  users: User[];
  loading: boolean;
  onEdit: (user: User) => void;
  onDelete: (user: User) => void;
}

const UserTable: React.FC<UserTableProps> = ({ users, loading, onEdit, onDelete }) => {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full bg-white rounded-xl shadow-md overflow-hidden">
        <thead className="bg-[#cce3bb] text-[#123b1f] text-left">
          <tr>
            <th className="px-6 py-3">Lot #</th>
            <th className="px-6 py-3">Name</th>
            <th className="px-6 py-3">Address</th>
            <th className="px-6 py-3">Email</th>
            <th className="px-6 py-3">Contact No.</th>
            <th className="px-6 py-3">Username</th>
            <th className="px-6 py-3">Role</th>
            <th className="px-6 py-3">Actions</th>
          </tr>
        </thead>
        <tbody>
          {loading && users.length === 0 ? (
            <tr>
              <td colSpan={8} className="px-6 py-4 text-center">
                <Loader2 className="w-6 h-6 mx-auto animate-spin" />
                <p>Loading users...</p>
              </td>
            </tr>
          ) : users.length === 0 ? (
            <tr>
              <td colSpan={8} className="px-6 py-4 text-center">No users found</td>
            </tr>
          ) : (
            users.map((user) => (
              <tr key={user._id} className="border-b hover:bg-[#f2fbe7]">
                <td className="px-6 py-4">{user.lot || 'N/A'}</td>
                <td className="px-6 py-4">{user.fullName}</td>
                <td className="px-6 py-4">{user.address}</td>
                <td className="px-6 py-4">{user.email || 'N/A'}</td>
                <td className="px-6 py-4">{user.contactNumber}</td>
                <td className="px-6 py-4">{user.username}</td>
                <td className="px-6 py-4">{user.role}</td>
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