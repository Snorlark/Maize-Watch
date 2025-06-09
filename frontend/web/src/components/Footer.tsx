import React from 'react';

const Footer: React.FC = () => {
  return (
    <footer className="bg-white py-6 mt-auto">
      <div className="container mx-auto px-4 text-center text-[#356B2C]">
        <p>&copy; {new Date().getFullYear()} Maize Watch. All rights reserved.</p>
      </div>
    </footer>
  );
};

export default Footer; 