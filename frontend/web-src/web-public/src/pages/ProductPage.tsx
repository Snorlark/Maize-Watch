import { useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import AOS from 'aos';
import { useState } from 'react';
import { X } from "lucide-react";


export default function ProductPage() {
  const navigate = useNavigate();
  const { pathname } = useLocation();
  const [isOpen, setIsOpen] = useState(false);
  
  const [privacyModalOpen, setPrivacyModalOpen] = useState(false);
  const [termsModalOpen, setTermsModalOpen] = useState(false);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);

   useEffect(() => {
      AOS.init({ duration: 1000, once: true });
    }, []);


  const [currentImageIndex, setCurrentImageIndex] = useState(0);
      
      const images = [
          '/web-public/public/images/Phealthycorn.png',
          '/web-public/public/images/Pdetailedtables.png'
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
                  src="/web-public/public/images/smalllogo.png"
                  alt="Logo"
                  className="h-14 w-14 md:h-18 md:w-18 object-cover cursor-pointer ease-in-out duration-250 hover:scale-110"
                />
              </div>
              <div>
                <ul className="flex items-center font-bold space-x-4 md:space-x-15">
                  <li><button onClick={() => navigate('/getapp')} className="bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in-out duration-250">Get App</button></li>
                  <li><button>
                    <img
                      onClick={() => navigate('/header-menu')}
                      src="/web-public/public/images/menu-green.png"
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
                  <div data-aos="zoom-in" className="p-2 ">
                    <img src="/web-public/public/images/header-product.png" alt="Brain Icon" className="w-full h-full" />
                  </div>
                </div>
                <p data-aos="fade-up" data-aos-delay="200" className="py-5 xl:py-10  xl:text-lg">
                 <b>Maize Watch</b>  offers a real-time, IoT-powered mobile and web application designed to revolutionize corn farming by turning raw environmental data into actionable insights. Using a network of smart sensors—monitoring temperature, humidity, soil moisture, light intensity, and soil pH—our system collects critical information from the field and transmits it instantly to the cloud via a SIM-enabled microcontroller.
                </p>
                <div className="items-center">
                <button
                    data-aos="fade" data-aos-delay="400"
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
          <section className="py-16 px-4 md:px-20 ">
            <div className="container mx-auto px-4 md:px-20 lg:px-80">
              <div className=" space-y-6">
                <div className="flex items-center gap-3">
                  <div className="py-2 ">
                    <h2 className=" text-right text-3xl md:text-6xl font-bold text-(--color-dgreen)">See the prototype.</h2>
                  </div>

                </div>
              </div>
            </div>
          </section>

              <div className="container mx-auto 2xl:px-40 ">
                <div data-aos="fade" data-aos-delay="200" className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                  
                  <div className="px-15 2xl:pl-35 mx-auto  space-y-10">
                    <div className="flex items-center gap-2">
                      <div data-aos="fade-down" data-aos-delay="400" >
                        <h2 className="text-5xl md:text-4xl font-bold text-(--color-dgreen)">Real-time Monitoring</h2>
                      </div>
                    </div>
  
                    <p data-aos="fade-right" data-aos-delay="400" className=" xl:py-8 text-sm md:text-base xl:text-lg max-w-xl">
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
                  
                  <div data-aos="fade-left" data-aos-delay="400" className="relative flex justify-center items-center">
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
            <div data-aos="fade" data-aos-delay="400"  className="max-w-5xl mx-auto space-y-6 text-center">
              <h2 data-aos="fade-down" data-aos-delay="400" className="text-3xl md:text-4xl font-bold text-(--color-dgreen)">Learn and Grow.</h2>

              <div className="flex flex-col items-center space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 bg-white rounded-xl overflow-hidden shadow-md max-w-3xl w-full xl:my-15">
                  <div data-aos="fade-right" data-aos-delay="400"  className="bg-(--color-dgreen) text-white p-10 flex items-center justify-center">
                    <p className="text-lg font-semibold text-left">Want to understand how the app works?</p>
                  </div>
                  <div data-aos="fade-left" data-aos-delay="400"  className="bg-(--color-lgreen) text-white p-12 flex items-center justify-center">
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

          {/* <footer data-aos="fade-up" data-aos-delay="200" className="bg-(--color-white) py-6 px-4 md:px-12">
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
          </footer> */}

           <footer data-aos="fade-up" data-aos-delay="200" className="bg-(--color-white) py-6 px-4 md:px-10">
               <div className="container mx-auto max-w-6xl">
                 <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8 md:gap-4">
                   <div className="space-y-3">
                     <img src="/web-public/public/images/logo.png" alt="Maize Watch" className="h-10 md:h-12" />
                     <div className="ml-7 flex gap-3">
                       
                       <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                         <img src="/web-public/public/images/instagram.png" alt="Instagram" className="h-5 w-5" />
                       </a>
                       <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                         <img src="/web-public/public/images/github.png" alt="GitHub" className="h-5 w-5" />
                       </a>
                       <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                         <img src="/web-public/public/images/linkedin.png" alt="LinkedIn" className="h-5 w-5" />
                       </a>
                       <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                         <img src="/web-public/public/images/x.png" alt="X" className="h-5 w-5" />
                       </a>
                     </div>
                   </div>
  
                   <div className="mt-2 md:mt-0">
                     <h4 className="font-semibold text-base md:text-lg mb-3 text-(--color-dgreen)">Information</h4>
                     <ul className="space-y-2 text-sm md:text-base text-(--color-dgreen)">
                       <li><button 
                       onClick={() => {
                      setPrivacyModalOpen(true);}}
                      className="hover:opacity-80 transition-all duration-300">Privacy</button></li>
                       <li><button 
                       onClick={() => {
                      setTermsModalOpen(true);}} className="hover:opacity-80 transition-all duration-300">Terms of Use</button></li>
                       <li><button
                       onClick={() => {
                      setAboutModalOpen(true);
                    }}className="hover:opacity-80 transition-all duration-300">About us</button></li>
                     </ul>
                   </div>
  
                   <div className="mt-2 md:mt-0">
                     <h4 className="font-semibold text-base md:text-lg mb-3 text-(--color-dgreen)">Contact Us</h4>
                     <ul className="space-y-2 text-sm md:text-base text-(--color-dgreen)">
                       <li>2129 Taft Avenue</li>
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

      
 {aboutModalOpen && (
        <div data-aos="fade" className="fixed inset-0 bg-black bg-opacity-90 backdrop-blur-sm flex items-center justify-center z-50">
          <div data-aos="fade-up" data-aos-delay="100" className="bg-(--color-dgreen) rounded-lg w-full max-w-lg mx-4 p-6 relative">
            <button 
              onClick={() => setAboutModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={25}  className='text-(--color-white) cursor-pointer hover:text-(--color-llgreen) ease-in-out duration-250'/>
            </button>
            
            <div className="flex items-center gap-2 mb-4">
              <div className="rounded-full">
                <img 
                  src="/web-public/public/maizewatchlogo.png" 
                  alt="Maize Watch Icon" 
                  className="h-10 w-10"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/24";
                  }}
                />
              </div>
              <span className="text-[#61983f] text-lg font-bold uppercase tracking-wider">Maize Watch</span>
            </div>
            
            <div className="text-sm text-(--color-white) mb-6 mx-8">
              <p>
                Maize Watch empowers corn farmers to achieve higher yields and greater 
                profitability through data-driven insights. Comprehensive data visualizations 
                provide clarity on performance across all key health and environmental conditions, 
                enabling timely interventions and optimized resource allocation. Integrated 
                account management tools allow farmers to track and analyze sensor data, 
                identify areas for improvement, and implement best practices. The result is 
                increased agricultural efficiency, reduced costs, and improved overall farm 
                productivity.
              </p>
            </div>
            
          </div>
        </div>
      )}

 {privacyModalOpen && (
        <div data-aos="fade" className="fixed inset-0 bg-black bg-opacity-90 backdrop-blur-sm flex items-center justify-center z-50">
          <div data-aos="fade-up" data-aos-delay="100" className="bg-(--color-dgreen) rounded-lg w-full max-w-lg mx-4 p-6 relative">
            <button 
              onClick={() => setPrivacyModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={25}  className='text-(--color-white) cursor-pointer hover:text-(--color-llgreen) ease-in-out duration-250'/>
            </button>
            
            <div className="flex items-center gap-2 mb-4">
              <div className="rounded-full">
                <img 
                  src="/web-public/public/maizewatchlogo.png" 
                  alt="Maize Watch Icon" 
                  className="h-10 w-10"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/24";
                  }}
                />
              </div>
              <span className="text-[#61983f] text-lg font-bold uppercase tracking-wider">Maize Watch</span>
            </div>
            
            <div className="space-y-6 text-sm text-white max-h-[70vh] overflow-y-auto px-4">
              <h2 className="text-xl font-bold text-left mb-4">Privacy Information</h2>

              <p>
                At Maize Watch, we are committed to protecting the privacy of our users, particularly corn farmers who entrust us with their valuable agricultural data. This Privacy Information outlines how we collect, use, and protect your information when you use our platform.
              </p>

              <div>
                <h3 className="font-semibold text-base mb-1">1. Information We Collect:</h3>
                <p className="mb-2">To provide you with data-driven insights and optimize your corn yields, Maize Watch collects the following types of information:</p>

                <ul className="list-disc pl-6 space-y-1">
                  <li>
                    <strong>Farm-Specific Data:</strong> Location (GPS coordinates of fields), field size and boundaries, crop variety, planting/harvesting dates, and yield data.
                  </li>
                  <li>
                    <strong>Sensor Data:</strong> Soil moisture/nutrient levels, temperature (soil/ambient), humidity, light intensity, and other relevant environmental data.
                  </li>
                  <li>
                    <strong>Account Information:</strong> Your name, contact info, farm name/ID, and login credentials (encrypted).
                  </li>
                  <li>
                    <strong>Usage Data:</strong> Features accessed, time spent, reports generated, and anonymized device info.
                  </li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">2. How We Use Your Information:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li><strong>To Provide Core Services:</strong> Visualize farm performance, analyze conditions, offer recommendations, and track progress.</li>
                  <li><strong>To Improve Maize Watch:</strong> Enhance features, develop new tools, and improve models (often using anonymized data).</li>
                  <li><strong>For Communication:</strong> Send updates, alerts, and respond to inquiries.</li>
                  <li><strong>For Security:</strong> Ensure platform integrity, prevent fraud, and comply with legal duties.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">3. Data Sharing and Disclosure:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li><strong>With Your Consent:</strong> Data is shared only with parties you approve (e.g., consultants).</li>
                  <li><strong>Service Providers:</strong> Only trusted providers under strict agreements.</li>
                  <li><strong>Aggregated/Anonymized Data:</strong> Used for research or benchmarking without revealing identities.</li>
                  <li><strong>Legal Requirements:</strong> Disclosed only when legally necessary.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">4. Data Security:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>Encryption (in transit & at rest)</li>
                  <li>Strict access controls</li>
                  <li>Regular security audits</li>
                  <li>Secure data backups</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">5. Your Choices and Rights:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>Access, update, or correct your data anytime</li>
                  <li>Request a copy of your data (data portability)</li>
                  <li>Request data deletion (subject to legal retention)</li>
                  <li>Opt-out of non-essential communications</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">6. Data Retention:</h3>
                <p>
                  Your data is retained while your account is active and for a reasonable period afterward to comply with obligations and ensure continuity.
                </p>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">7. Changes to This Privacy Information:</h3>
                <p>
                  Updates to this Privacy Information will be posted on our website or communicated appropriately. Please review it periodically.
                </p>
              </div>
              
            </div>

            
          </div>
        </div>
      )}

 {termsModalOpen && (
        <div data-aos="fade" className="fixed inset-0 bg-black bg-opacity-90 backdrop-blur-sm flex items-center justify-center z-50">
          <div data-aos="fade-up" data-aos-delay="100" className="bg-(--color-dgreen) rounded-lg w-full max-w-lg mx-4 p-6 relative">
            <button 
              onClick={() => setTermsModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={25}  className='text-(--color-white) cursor-pointer hover:text-(--color-llgreen) ease-in-out duration-250'/>
            </button>
            
            <div className="flex items-center gap-2 mb-4">
              <div className="rounded-full">
                <img 
                  src="/web-public/public/maizewatchlogo.png" 
                  alt="Maize Watch Icon" 
                  className="h-10 w-10"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/24";
                  }}
                />
              </div>
              <span className="text-[#61983f] text-lg font-bold uppercase tracking-wider">Maize Watch</span>
            </div>
            
            <div className="space-y-6 text-sm text-white max-h-[70vh] overflow-y-auto px-4">
              <h2 className="text-xl font-bold text-left mb-4">Terms of Use</h2>

              <p>
                Welcome to Maize Watch. By accessing or using our platform, services, and related tools, you agree to comply with and be bound by these Terms of Use. If you do not agree with any part of these terms, please do not use Maize Watch.
              </p>

              <div>
                <h3 className="font-semibold text-base mb-1">1. Use of the Platform:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>You may only use Maize Watch for lawful purposes and in accordance with these terms.</li>
                  <li>You are responsible for maintaining the confidentiality of your account credentials and all activities under your account.</li>
                  <li>You agree not to misuse the platform, interfere with its security or functionality, or attempt unauthorized access to any part of the system.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">2. Data Ownership and Usage:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>You retain full ownership of your farm data and sensor information.</li>
                  <li>By using Maize Watch, you grant us permission to analyze your data to provide personalized insights and improve platform performance.</li>
                  <li>We will not share your identifiable data without your explicit consent, as outlined in our Privacy Policy.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">3. Intellectual Property:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>All content on Maize Watch, including visualizations, software, text, graphics, and logos, is the property of Maize Watch or its licensors.</li>
                  <li>You may not reproduce, distribute, modify, or create derivative works without our written permission.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">4. Account Termination:</h3>
                <p>
                  We reserve the right to suspend or terminate your access to Maize Watch at any time if you violate these terms, abuse the platform, or engage in any behavior that disrupts service for other users.
                </p>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">5. Disclaimers:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>Maize Watch provides data-based insights to support agricultural decisions. Final decisions regarding farming practices remain your responsibility.</li>
                  <li>We do not guarantee specific yield outcomes or profitability as agricultural success depends on many uncontrollable factors.</li>
                  <li>The platform is provided “as-is” and “as available” without warranties of any kind.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">6. Limitation of Liability:</h3>
                <p>
                  To the extent permitted by law, Maize Watch shall not be liable for any indirect, incidental, or consequential damages arising from your use of the platform, including data loss, yield loss, or farm-related decisions made based on our analytics.
                </p>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">7. Updates to the Terms:</h3>
                <p>
                  We may update these Terms of Use from time to time. Material changes will be communicated through our platform or via email. Continued use of Maize Watch means you accept the updated terms.
                </p>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}