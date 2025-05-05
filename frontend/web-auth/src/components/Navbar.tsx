import React, { useState } from "react";
import { NavLink } from "react-router-dom";
import { Menu, X, ChevronRight } from "lucide-react";

const Navbar: React.FC = () => {
  
  const [menuOpen, setMenuOpen] = useState(false);
  
  

  return (
    <header className="sticky top-0 z-50 bg-[#E6F0D3] py-10 px-1 font-montserrat">
      <div className="max-w-7xl mx-auto flex items-center justify-between">
        {/* Logo */}
        <div className="flex items-center gap-2">
          <img
            src="/maizewatch.png"
            alt="Maize Watch Logo"
            className="h-20 w-80"
          />
        </div>

        {/* Navigation Links */}
        <nav className="hidden md:flex mt-3 gap-10 items-center text-[#1E441E] text-sm font-medium">
          <NavLink 
            to="/dashboard"
            className=  {({ isActive }) =>
              isActive
                ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D]"
                : " hover:text-[#347928] transition"
                
            }
          >
            Data History
            
          </NavLink>
          <NavLink
            to="/livedata"
            className={({ isActive }) =>
              isActive
                ? "relative  pb-2  after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D]"
                : "hover:text-[#347928] transition"
            }
          >
            Live Data
          </NavLink>
          <NavLink
            to="/accountmanagement"
            className={({ isActive }) =>
              isActive
                ? "relative pb-2 after:absolute after:-bottom-1 after:left-0 after:w-full after:h-1 after:bg-[#456C2D]"
                : "hover:text-[#456C2D] transition"
            }
          >
            Account Management
          </NavLink>
        </nav>

        {/* Menu Icon (Always Visible) */}
        <button onClick={() => setMenuOpen(true)} className="text-[#1E441E]">
          <Menu size={28} />
        </button>
      </div>

      {/* Menu Widget */}
      {menuOpen && (
        <div className="absolute top-24 right-4 w-72 bg-white shadow-xl z-50 p-6 rounded-2xl border border-gray-200 animate-fade-in">
          <div className="flex justify-end mb-4">
            <button onClick={() => setMenuOpen(false)} className="text-[#1E441E]">
              <X size={24} />
            </button>
          </div>
          <ul className="space-y-5 text-base font-semibold">
            <li className="flex justify-between items-center text-[#1E441E] hover:opacity-80 cursor-pointer">
              Account Setting <ChevronRight size={18} />
            </li>
            <li className="flex justify-between items-center text-[#1E441E] hover:opacity-80 cursor-pointer">
              About <ChevronRight size={18} />
            </li>
            <NavLink
            to="/">
              <li className="flex justify-between items-center text-gray-700 hover:opacity-80 cursor-pointer">
                Log Out <ChevronRight size={18} />
              </li>
            </NavLink>
          </ul>
        </div>
      )}
    </header>
  );
};

export default Navbar;
