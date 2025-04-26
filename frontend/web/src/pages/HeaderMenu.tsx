import { useNavigate } from 'react-router-dom';
import { useState } from "react";

export default function HeaderMenuPage() {
    const navigate = useNavigate();
    const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <body className="lg:px-10 xl:px-20 bg-(--color-white) h-screen overflow-hidden">
        <main className="h-full">
  
         <div className="flex justify-end mt-10 pr-8 md:mt-10 md:pr-20 lg:mt-10 lg:pr-40 xl:mt-30 xl:pr-40">
            <button 
              onClick={() => navigate('/')} 
              className="text-(--color-lgreen) hover:text-(--color-green) cursor-pointer transition-all ease-in-out duration-300"
              aria-label="Close menu"
            >
              <svg 
                xmlns="http://www.w3.org/2000/svg" 
                width="24" 
                height="24" 
                viewBox="0 0 24 24" 
                fill="none" 
                stroke="currentColor" 
                strokeWidth="2" 
                strokeLinecap="round" 
                strokeLinejoin="round"
                className="w-6 h-6 md:w-12 md:h-12"
              >
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
  
          <div className="h-[calc(100%-80px)]">
              <div className="mx-auto grid grid-cols-1 md:grid-cols-2 gap-10 items-center px-4 md:px-20 lg:px-40 h-full">
                  <div className="cursor-pointer">
                      <h2 onClick={() => navigate('/')} className="hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 text-4xl md:text-5xl lg:text-6xl font-bold text-(--color-dgreen) mb-8">Home.</h2>
                      <h2 onClick={() => navigate('/solutions')} className="hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 text-4xl md:text-5xl lg:text-6xl font-bold text-(--color-dgreen) mb-8">Solution.</h2>
                      <h2 onClick={() => navigate('/products')} className="hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 text-4xl md:text-5xl lg:text-6xl font-bold text-(--color-dgreen) mb-8">Product.</h2>
                      <h2 onClick={() => navigate('/technology')} className="hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 text-4xl md:text-5xl lg:text-6xl font-bold text-(--color-dgreen) mb-8">Technology.</h2>
                      <h2 onClick={() => navigate('/')} className="hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 text-4xl md:text-5xl lg:text-6xl font-bold text-(--color-dgreen) mb-8">About.</h2>
                  </div>
  
                 
                <div className="lg:mt-0 md:flex md:flex-col md:items-end">
                  
                  <button onClick={() => navigate('/signup')} className="bg-(--color-lgreen) text-(--color-white) px-4 md:px-8 py-2 md:py-4 rounded-md text-base md:text-2xl xl:text-4xl font-semibold cursor-pointer hover:bg-(--color-green) ease-in-out duration-250">Sign Up Now</button>
  
                  <button
                      onClick={() => setIsOpen(!isOpen)}
                      className="mt-10 flex items-center text:1xl md:text-2xl font-bold text-(--color-dgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer"
                    >
                      {isOpen ? "View Less -" : "Knowledge Hub > "}
                    </button>
  
  
                    {isOpen && (
                      <div className="text-(--color-dgreen) md:text-right">
  
                        <div>
                          <h3 className="text-base md:text-[20px] xl:mt-5 font-medium hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer">F.A.Qs</h3>
                          <h3 className="text-base md:text-[20px] xl:mt-5 font-medium hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer">App Run-Through</h3>
                          <h3 className="text-base md:text-[20px] xl:mt-5 font-medium hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer">Help</h3>
  
                        </div>
  
                      </div>
                    )}
  
                  <div className="mt-10 flex gap-4">
  
                      <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                        <img src="/images/instagram.png" alt="Instagram" className="h-5 w-5  md:h-7 md:w-7  lg:h-10 lg:w-10" />
                      </a>
                      <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                        <img src="/images/github.png" alt="GitHub" className="h-5 w-5 md:h-7 md:w-7  lg:h-10 lg:w-10" />
                      </a>
                      <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                        <img src="/images/linkedin.png" alt="LinkedIn" className="h-5 w-5 md:h-7 md:w-7  lg:h-10 lg:w-10" />
                      </a>
                      <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                        <img src="/images/x.png" alt="X" className="h-5 w-5 md:h-7 md:w-7  lg:h-10 lg:w-10" />
                      </a>
                  </div>
                </div>
              </div>
          </div>
       
        </main>
      </body>
    </>
  )
}