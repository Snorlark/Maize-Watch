import React from "react";

const Footer = () => {
  return (
    <footer className="bg-[#E6F0D3] text-[#356B2C] text-sm border-t-1 border-[#356B2C] py-15 px-4 sm:px-8 lg:px-16">
      <div className="max-w-7xl mx-auto flex flex-wrap justify-between items-start gap-8 pb-6">
        
        {/* Logo & Socials */}
        <div>
          <img src="maizewatch.png" alt="Maize Watch Logo" className="w-40 mb-1" />
          <div className="flex gap-3">
            <img src="/footer/instagram.png" alt="Instagram" className="w-5 h-5 cursor-pointer" />
            <img src="/footer/github.png" alt="GitHub" className="w-5 h-5 cursor-pointer" />
            <img src="/footer/linkedin.png" alt="LinkedIn" className="w-5 h-5 cursor-pointer" />
            <img src="/footer/x.png" alt="X" className="w-4 h-4 cursor-pointer" />
          </div>
        </div>

        {/* Info Links */}
        <div>
          <h3 className="font-semibold mb-2">Information</h3>
          <ul className="space-y-1">
            <li className="hover:underline cursor-pointer">Privacy</li>
            <li className="hover:underline cursor-pointer">Terms of Use</li>
            <li className="hover:underline cursor-pointer">About us</li>
          </ul>
        </div>

        {/* Contact Details */}
        <div>
          <h3 className="font-semibold mb-2">Contact Us</h3>
          <p>1234 Jhocson Street</p>
          <p>Sampaloc, Manila 1004 Philippines</p>
          <p>Office: (02) 123-4557 (Mon–Fri)</p>
        </div>

        {/* Copyright */}
        <div className="text-right text-xs text-[#356B2C] whitespace-nowrap mt-10 sm:mt-0">
          © {new Date().getFullYear()} NOVU. All rights reserved.
        </div>
      </div>
     
    </footer>
  );
};

export default Footer;