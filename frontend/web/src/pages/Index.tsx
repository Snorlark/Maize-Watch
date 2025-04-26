import { useNavigate } from 'react-router-dom';
import { useState } from 'react';

export default function Index() {
    const navigate = useNavigate();
    const [currentImageIndex, setCurrentImageIndex] = useState(0);
    
    const images = [
        '/images/healthycorn.png',
        '/images/prescriptions.png',
        '/images/detailedtables.png'
    ];

    const handlePrevImage = () => {
        setCurrentImageIndex((prev) => (prev === 0 ? images.length - 1 : prev - 1));
    };

    const handleNextImage = () => {
        setCurrentImageIndex((prev) => (prev === images.length - 1 ? 0 : prev + 1));
    };

    return (
    <>
        <body className="bg-(--color-white) scroll-smooth">
          <main>
            
          <div className="bg-[url(/images/background.png)] rounded-bl-[50px] rounded-br-[50px] rounded-tl-none rounded-tr-none relative h-197 bg-cover bg-center flex items-center justify-center">
            <nav className="fixed top-0 w-full container z-10 bg-transparent px-2 md:px-10 py-1 flex items-center justify-between">
              <div className="w-16 md:w-20 py-2 flex items-center">
                <img
                  src="/images/smalllogo.png"
                  alt="Logo"
                  className="h-14 w-14 md:h-18 md:w-18 object-cover"
                />
              </div>
  
              <div>
                <ul className="flex items-center font-bold space-x-4 md:space-x-15">
                  <li><button onClick={() => navigate('/signup')} className="bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in-out duration-250">Sign Up</button></li>
                  <li>
                    <button>
                    <img
                    onClick={() => navigate('/headermenu')}
                    src="/images/menu-green.png"
                    alt="Logo"
                    className="h-8 w-8 md:h-10 md:w-10 object-cover opacity-80 hover:opacity-100 duration-300"
                    />
                    </button>
                  </li>
                </ul>
              </div>
            </nav>
  
            {/* HERO PAGE */}
            <div className="relative flex flex-col items-center justify-center text-white text-center space-y-4 md:space-y-6 w-full px-4">
              <div className="flex flex-col items-center">
                <img src="/images/mainlogo.png" alt="Maize Watch Logo" className=" w-80 md:w-100 lg:w-180 xl:w-250 m-auto rounded-full transition-all duration-300 hover:scale-105" />
              </div>
  
              <button  onClick={() => navigate('/login')} className="mt-2 md:mt-4 px-6 md:px-8 py-3 md:py-4 border-2 border-white text-white rounded-full hover:scale-108 hover:bg-white hover:text-(--color-dgreen) transition-all ease-in-out duration-300 text-base md:text-lg font-medium align-text-center">
                Monitor now →
              </button>
            </div>
          </div>
            
            {/* ABOUT PART */}
          <div className="relative -mt-12 pb-8 md:pb-4 ">
              <div className="container mx-auto px-10 md:px-20 lg:px-18 xl:px-75">
                <div onClick={() => navigate('/products')} className="bg-[url(/images/container2.png)] bg-cover bg-center text-white rounded-[31px] p-6 md:p-23 pb-8 lg:pb-30 md:pb-25 hover:scale-99 transition-all ease-in-out duration-300 hover:text-(--color-llgreen) cursor-pointer">
                  <div  className="flex flex-col md:flex-row items-start gap-4 md:gap-6 cursor-pointer">
                    <img src="/images/smiley.png" alt="" className="w-12 h-12 md:w-14 md:h-14" />
                    <div>
                      <h2 className="text-2xl md:text-3xl font-bold mb-4 md:mb-6">
                        Maximize your yields,<br />minimize your worries.
                      </h2>
                      <p className="text-[14px] md:text-[16px] lg:text-[24px] xl:text-[18px] opacity-90 md:mr-10">
                        Maize Watch is a smart farming system that monitors real-time corn field
                        conditions using IoT sensors and delivers data-driven recommendations
                        through AI-powered prescriptive analytics—helping farmers grow
                        healthier crops, efficiently and sustainably.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
  
            <div className="py-8 md:py-15 px-4 md:px-30">
              <div className="container mx-auto">
                <div className="grid grid-cols-1 md:grid-cols-1 lg:grid-cols-3 gap-6 md:gap-8">
                  <div className="bg-[url(/images/cmission.png)] bg-cover p-6 md:p-10 rounded-[31px] text-white transition-all duration-300 hover:opacity-90 hover:text-dgreen">
                    <h3 className="text-3xl md:text-[40px] font-bold mt-4">Mission.</h3>
                    <div className="flex items-start gap-4 mt-4 md:mt-8 mr-30 md:mr-40 lg:mr-10 ml-2 md:ml-8">
                      <p className="text-sm md:text-base">
                        We aim to support Filipino corn farmers by providing real-time insights
                        for smarter, more efficient corn farming.
                      </p>
                    </div>
                  </div>
  
                  <div className="bg-[url(/images/cprinciple.png)] bg-cover p-6 md:p-10 rounded-[31px] text-white transition-all duration-300 hover:opacity-90 hover:text-dgreen">
                    <h3 className="text-3xl md:text-[40px] font-bold mt-4">Principle.</h3>
                    <div className="flex items-start gap-4 mt-4 md:mt-8 mr-30 md:mr-45 lg:mr-10 ml-2 md:ml-8">
                      <p className="text-sm md:text-base">
                        We use IoT and Data Analytics to simplify decision-making, promote sustainable
                        practices, and ensure accessible tools for all.
                      </p>
                    </div>
                  </div>
  
                  <div className="bg-[url(/images/cvalues.png)] bg-cover p-6 md:p-10 rounded-[31px] text-white transition-all duration-300 hover:opacity-90 hover:text-dgreen">
                    <h3 className="text-3xl md:text-[40px] font-bold mt-4">Values.</h3>
                    <div className="flex items-start gap-4 mt-4 md:mt-8 mr-35 mb-3 md:mr-45 lg:mr-10 ml-2 md:ml-8">
                      <p className="text-sm md:text-base">
                        We value innovation, sustainability, and empowering farmers through accurate,
                        data-driven solutions.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
  
            <hr className="my-4 border-t border-(--color-lgreen) mt-10  mx-10 xl:mx-40" />
            
            {/* APP PART */}
            <div className="py-16 px-4 md:px-20">
              <div className="container mx-auto">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                  
                  <div className=" ml-10  space-y-6">
                    <div className="flex items-center gap-3">
                      <div className="p-2 ">
                        <img src="/images/header.png" alt="Brain Icon" className="w-full h-full" />
                      </div>
                    </div>
  
                    <p className="text-gray-700 text-sm md:text-base xl:text-lg max-w-xl">
                      ----------- We also offer a real-time app that helps corn farmers optimize crop yield through IoT sensor data. It monitors key environmental factors and provides actionable insights from our prescriptive analytics, enabling smarter farming decisions for better productivity and sustainability.
                    </p>
                    
                    <div className="flex items-center gap-5 md:gap-70 lg:gap-20 xl:gap-90  ">
                      <button onClick={() => navigate('/solutions')} className="cursor-pointer flex items-center gap-2 text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen) hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1">
                        LEARN MORE
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                          <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                        </svg>
                      </button>
                      
                      <div className="flex gap-4">
                        <button 
                          onClick={handlePrevImage}
                          className="cursor-pointer w-12 h-12 rounded-full border-2 border-(--color-dgreen) flex items-center justify-center hover:bg-(--color-llgreen) hover:text-white transition-discrete ease-in-out duration-300">
                          <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-(--color-dgreen)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                          </svg>
                        </button>
                        <button 
                          onClick={handleNextImage}
                          className="cursor-pointer w-12 h-12 rounded-full border-2 border-(--color-dgreen) flex items-center justify-center hover:bg-(--color-llgreen) hover:text-white transition-discrete ease-in-out duration-300">
                          <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-(--color-dgreen)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                  
                  <div className="relative flex justify-center items-center">
                    <div className="bg-(--color-lgreen) w-[300px] h-[300px] md:w-[400px] md:h-[400px] rounded-full absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-15 transition-discrete ease-in-out duration-500"></div>
                    <img
                      src={images[currentImageIndex]}
                      alt="Maize Watch App Preview"
                      className="relative w-[280px] md:w-[400px] mx-auto fade-out-left transition-discrete ease-in-out duration-500"
                    />
                  </div>
                </div>
              </div>
            </div>
  
  <br /><br />
  
            {/* TECHNOLOGY PART */}
            <div className="bg-[url(/images/background2.png)] rounded-tr-[50px] rounded-tl-[50px] rounded-bl-none relative min-h-screen bg-cover bg-center flex items-center justify-center py-8 md:py-20">
                 <div className="container px-4 md:px-16">
                   <div className="grid grid-cols-1 lg:grid-cols-2 gap-10 md:gap-4 lg:gap-0">
                    
                    {/* colum1 */}
                     <div className="text-white space-y-4 md:space-y-6 mt-4 md:mt-30 lg:mt-40 2xl:mt-100 px-2 md:px-0">
                       <h2 className="text-2xl md:text-4xl lg:text-5xl font-bold leading-tight">
                         The Technology<br />Behind.
                       </h2>
                       <button onClick={() => navigate('/technology')} className="flex items-center gap-2 text-sm md:text-lg font-semibold text-(--color-white) border-b-2 border-(--color-white) pb-1 hover:text-(--color-lgreen) hover:border-(--color-lgreen) transition-all duration-300 cursor-pointer">
                         LEARN MORE
                         <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 md:h-5 md:w-5" viewBox="0 0 20 20" fill="currentColor">
                           <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                         </svg>
                       </button>
                     </div>
                    
                    {/* colum2 */}
                      {/* subcolumn1 */}
                    <div className="container mx-auto xl:col-span-2 2xl:col-span-1 px-4 xl:mx-0">
                      <div className="grid grid-cols-1 xl:grid-cols-2 ">
  
                        <div className="text-white mt-4 md:mt-40 mx-auto w-full max-w-[320px] lg:max-w-full">
                          <div className="bg-(--color-dgreen) 2xl:h-100 rounded-tl-[30px] rounded-tr-[30px] rounded-bl-[30px] rounded-br-[30px] xl:rounded-tr-none xl:rounded-br-none p-6 md:p-15 lg:p-20 xl:p-20 2xl:p-17">
                            <h3 className="text-md md:text-2xl lg:text-3xl 2xl:text-[28px] font-bold uppercase mb-3 md:mb-4 2xl:mb-7">
                              Real-time<br />Monitoring
                            </h3>
                            <p className="leading-relaxed text-sm md:text-base lg:text-[18px] 2xl:text-[16px] text-white/90">
                              Monitor your corn crops in real time with IoT sensors—track temperature, soil moisture, humidity, pH level, and light intensity for healthier harvests.
                            </p>
                          </div>
                        </div>
  
                        {/* subcolumn2 */}
                        <div className="text-white mt-4 md:mt-10 xl:mt-40 mx-auto w-full max-w-[320px] lg:max-w-full">
                          <div className="bg-(--color-lgreen)  2xl:h-100 rounded-tl-[30px] rounded-tr-[30px] rounded-bl-[30px] rounded-br-[30px] xl:rounded-tl-none xl:rounded-bl-none p-6 md:p-15 lg:p-20 xl:p-20 2xl:p-17">
                            <h3 className="text-md md:text-2xl lg:text-3xl 2xl:text-[28px] font-bold uppercase mb-3 md:mb-4 2xl:mb-6">
                              Prescriptive<br />Insights
                            </h3>
                            <p className="leading-relaxed text-sm md:text-base lg:text-[18px] 2xl:text-[16px] text-white/90">
                              We turn real-time corn crop data into smart recommendations—reducing risks, solve issues fast, and maximize your farm's potential.
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>
                   </div>
                 </div>
             </div>
             <br />
  
      
             {/* FOOTER PART */}
             <footer className="bg-(--color-white) py-6 px-4 md:px-10">
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