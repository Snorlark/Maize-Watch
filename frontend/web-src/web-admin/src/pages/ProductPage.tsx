import { useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { useState } from 'react';

export default function ProductPage() {
  const navigate = useNavigate();
  const { pathname } = useLocation();
  const [isOpen, setIsOpen] = useState(false);


  const [currentImageIndex, setCurrentImageIndex] = useState(0);
      
      const images = [
          '/images/Phealthycorn.png',
          '/images/Pdetailedtables.png'
      ];
  
      const handlePrevImage = () => {
          setCurrentImageIndex((prev) => (prev === 0 ? images.length - 1 : prev - 1));
      };
  
      const handleNextImage = () => {
          setCurrentImageIndex((prev) => (prev === images.length - 1 ? 0 : prev + 1));
      };
  

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);
  return (
    <>
      <body className="bg-(--color-white) min-h-screen">
        <main>
          <div className=" relative h-10 bg-cover bg-center flex items-center justify-center">
            <nav className="bg-(--color-dgreen) fixed top-0 w-full container z-10 bg-transparent px-2 md:px-10 py-1 flex items-center justify-between">
              <div className="w-16 md:w-20 py-2 flex items-center">
                <img
                  onClick={() => navigate('/')}
                  src="/images/smalllogo.png"
                  alt="Logo"
                  className="h-14 w-14 md:h-18 md:w-18 object-cover cursor-pointer ease-in-out duration-250 hover:scale-110"
                />
              </div>
              <div>
                <ul className="flex items-center font-bold space-x-4 md:space-x-15">
                  <li><button onClick={() => navigate('/signup')} className="bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in-out duration-250">Sign Up</button></li>
                  <li><button>
                    <img
                      onClick={() => navigate('/headermenu')}
                      src="/images/menu-green.png"
                      alt="Logo"
                      className="h-8 w-8 md:h-10 md:w-10 object-cover hover:opacity-80 duration-300"
                    />
                  </button></li>
                </ul>
              </div>
            </nav>
          </div>

          <div className="py-16 2xl:pt-20 px-4 md:px-20 mr-5">
            <div className="container mx-auto px-4 md:px-20 lg:px-80">
              <div className=" space-y-6">
                <div className="flex items-center gap-3">
                  <div className="p-2 ">
                    <img src="/images/header-product.png" alt="Brain Icon" className="w-full h-full" />
                  </div>
                </div>
                <p className="py-5 xl:py-10  xl:text-lg">
                 <b>Maize Watch</b>  offers a real-time, IoT-powered mobile and web application designed to revolutionize corn farming by turning raw environmental data into actionable insights. Using a network of smart sensors—monitoring temperature, humidity, soil moisture, light intensity, and soil pH—our system collects critical information from the field and transmits it instantly to the cloud via a SIM-enabled microcontroller.
                </p>
                <div className="items-center">
                <button
                    onClick={() => setIsOpen(!isOpen)}
                    className="flex items-center  text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen) hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer"
                  >
                    {isOpen ? "LESS -" : "MORE +"}
                  </button>

                  {isOpen && (
                    <div className="py-5 xl:text-lg">
                      <p>
                      Weather forecasts, crop growth modeling, and historical yield data are all incorporated to assist farmers in making data-driven decisions that optimize output while preserving resources. As this project seeks to increase crop yields, decrease resource waste, and advance sustainable agriculture methods, it serves as a guide for farming decisions. 
                      </p>

                      <br/>

                      <p>By supporting data-informed farming in the face of climate change, this technology approach supports a number of Sustainable Development Goals (SDGs), such as Zero Hunger, Climate Action, Life on Land, and Sustainable Cities and Communities.</p>

                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>

          <hr className="my-4 border-t border-(--color-lgreen) mt-10  mx-10 xl:mx-40" />

          {/* See the prototype */}
          <section className="py-16 px-4 md:px-20 mr-5">
            <div className="container mx-auto px-4 md:px-20 lg:px-80">
              <div className=" space-y-6">
                <div className="flex items-center gap-3">
                  <div className="p-2 ">
                    <img src="/images/header-product-2.png" alt="Brain Icon" className="w-full h-full" />
                  </div>

                </div>
              </div>
            </div>
          </section>

              <div className="container mx-auto 2xl:px-40 ">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                  
                  <div className="px-15 2xl:pl-35 mx-auto  space-y-10">
                    <div className="flex items-center gap-2">
                      <div >
                        <h2 className="text-5xl md:text-4xl font-bold text-(--color-dgreen)">Real-time Monitoring</h2>
                      </div>
                    </div>
  
                    <p className=" xl:py-8 text-sm md:text-base xl:text-lg max-w-xl">
                      Monitor your corn crops in real time with IoT sensors—track temperature, soil moisture, humidity, pH level, and light intensity for healthier harvests. Get instant visibility into field conditions, enabling quick decisions on irrigation, soil care, and crop management to support optimal growth and yield.
                    </p>
                    
                      
                      <div className="pl-30 2xl:pl-35 flex gap-4">
                        <button 
                          onClick={handlePrevImage}
                          className="w-12 h-12 rounded-full border-2 border-(--color-dgreen) flex items-center justify-center hover:bg-(--color-llgreen) hover:text-white transition-discrete ease-in-out duration-300">
                          <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-(--color-dgreen)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                          </svg>
                        </button>
                        <button 
                          onClick={handleNextImage}
                          className="w-12 h-12 rounded-full border-2 border-(--color-dgreen) flex items-center justify-center hover:bg-(--color-llgreen) hover:text-white transition-discrete ease-in-out duration-300">
                          <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-(--color-dgreen)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                          </svg>
                        </button>
                    
                    </div>
                  </div>
                  
                  <div className="relative flex justify-center items-center">
                    <div className="bg-(--color-lgreen) w-[300px] h-[300px] md:w-[400px] md:h-[400px] rounded-full absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-15 transition-discrete ease-in-out duration-500"></div>
                    <img
                      src={images[currentImageIndex]}
                      alt="Maize Watch App Preview"
                      className="relative w-[280px] md:w-[300px] mx-auto fade-out-left transition-discrete ease-in-out duration-500"
                    />
                  </div>
                </div>
              </div>

              <br/> <br/>
              
          <hr className="my-5 border-t border-(--color-lgreen) mt-20  mx-10 xl:mx-40" />

          <section className=" py-12 px-4 md:px-20">
            <div className="max-w-5xl mx-auto space-y-6 text-center">
              <h2 className="text-3xl md:text-4xl font-bold text-(--color-dgreen)">Learn and Grow.</h2>

              <div className="flex flex-col items-center space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 bg-white rounded-xl overflow-hidden shadow-md max-w-3xl w-full xl:my-15">
                  <div className="bg-(--color-dgreen) text-white p-10 flex items-center justify-center">
                    <p className="text-lg font-semibold text-left">Want to understand how the app works?</p>
                  </div>
                  <div className="bg-(--color-lgreen) text-white p-12 flex items-center justify-center">
                    <p className="text-sm md:text-base text-left">
                      Navigate through our <span className="underline">knowledge hub</span>, just click the learn more below.
                    </p>
                  </div>
                </div>

                <button
                  onClick={() => navigate('/technology')}
                  className="flex items-center gap-2 text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen)  hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer"
                >
                  LEARN MORE
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                  </svg>
                </button>
              </div>
            </div>
          </section>

          <hr className="my-4 border-t border-(--color-lgreen) mt-10  mx-10 xl:mx-40" />

          <footer className="bg-(--color-white) py-6 px-4 md:px-12">
            <div className="container mx-auto max-w-6xl">
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8 md:gap-4">
                <div className="space-y-3">
                  <img src="/images/logo.png" alt="Maize Watch" className="h-10 md:h-12" />
                  <div className="ml-7 flex gap-3">

                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/instagram.png" alt="Instagram" className="h-5 w-5" />
                    </a>
                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/github.png" alt="GitHub" className="h-5 w-5" />
                    </a>
                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/linkedin.png" alt="LinkedIn" className="h-5 w-5" />
                    </a>
                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/x.png" alt="X" className="h-5 w-5" />
                    </a>
                  </div>
                </div>

                <div className="mt-2 md:mt-0">
                  <h4 className="font-semibold text-base md:text-lg mb-3 text-(--color-dgreen)">Information</h4>
                  <ul className="space-y-2 text-sm md:text-base text-(--color-dgreen)">
                    <li><a href="#" className="hover:opacity-80 transition-all duration-300">Privacy</a></li>
                    <li><a href="#" className="hover:opacity-80 transition-all duration-300">Terms of Use</a></li>
                    <li><a href="#" className="hover:opacity-80 transition-all duration-300">About us</a></li>
                  </ul>
                </div>

                <div className="mt-2 md:mt-0">
                  <h4 className="font-semibold text-base md:text-lg mb-3 text-(--color-dgreen)">Contact Us</h4>
                  <ul className="space-y-2 text-sm md:text-base text-(--color-dgreen)">
                    <li>1234 Taft Avenue</li>
                    <li>Malate, Manila 1004 Philippines</li>
                    <li>Office: (02) 123-4567 (Mon-Fri)</li>
                  </ul>
                </div>

                <div className="text-left md:text-right text-(--color-dgreen) text-xs md:text-sm mt-4 md:mt-12">
                  © 2025 NOVU. All rights reserved.
                </div>
              </div>
            </div>
          </footer>
          <br />
        </main>
      </body>
    </>
  )
}