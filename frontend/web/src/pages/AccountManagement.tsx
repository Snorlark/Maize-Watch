import { Pencil, Trash2, PlusCircle } from "lucide-react";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";

const accounts = Array.from({ length: 11 }).map(() => ({
  lot: 1,
  name: "Juan Dela Cruz",
  address: "123 Espana St. Brgy 44, Batangas City",
  email: "juandelacruz@gmail.com",
  contact: "09123456789",
  username: "juandc",
}));


export default function AccountManagement() {
  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <Navbar />

      <main className="flex-grow container mx-auto px-4 py-8">
        <h1 className="text-2xl font-semibold mb-6">Account Management</h1>

        <div className="overflow-x-auto">
          <table className="min-w-full bg-(--color-rwhite) rounded-xl shadow-md overflow-hidden">
            <thead className="bg-[#cce3bb] text-[#123b1f] text-left">
              <tr>
                <th className="px-6 py-3">Lot #</th>
                <th className="px-6 py-3">Name</th>
                <th className="px-6 py-3">Address</th>
                <th className="px-6 py-3">Email</th>
                <th className="px-6 py-3">Contact No.</th>
                <th className="px-6 py-3">Username</th>
                <th className="px-6 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {accounts.map((acc, idx) => (
                <tr key={idx} className="border-b hover:bg-[#f2fbe7]">
                  <td className="px-6 py-4">{acc.lot}</td>
                  <td className="px-6 py-4">{acc.name}</td>
                  <td className="px-6 py-4">{acc.address}</td>
                  <td className="px-6 py-4">{acc.email}</td>
                  <td className="px-6 py-4">{acc.contact}</td>
                  <td className="px-6 py-4">{acc.username}</td>
                  <td className="px-6 py-4 flex gap-2">
                    <Pencil className="w-5 h-5 text-green-600 cursor-pointer hover:scale-110 transition-transform" />
                    <Trash2 className="w-5 h-5 text-red-600 cursor-pointer hover:scale-110 transition-transform" />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="mt-6 flex items-center text-green-700 cursor-pointer hover:underline">
          <PlusCircle className="w-5 h-5 mr-2" />
          <span>Create new account</span>
        </div>
      </main>

      <Footer />
    </div>
  );
}